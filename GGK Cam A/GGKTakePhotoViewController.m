//
//  GGKTakePhotoViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKSavedPhotosManager.h"
#import "GGKTakePhotoViewController.h"

// Story: User sees tip. User learns how to focus on an object.
NSString *const ToFocusTipString = @"Tip: To focus on an object, tap it.";

// Story: User sees tip. User learns the focus is locked. User learns how to unlock.
NSString *const ToUnlockFocusTipString = @"Tip: The focus is locked. To unlock, tap anywhere in the view.";

@interface GGKTakePhotoViewController ()

// For removing the observer later.
@property (strong, nonatomic) id appWillEnterForegroundObserver;

// For creating the session and managing the capture device.
@property (strong, nonatomic) GGKCaptureManager *captureManager;

// Story: The overall orientation (device/status-bar) is checked against the orientation of this app's UI. The user sees the UI in the correct orientation.
// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;

// For working with photos in the camera roll.
@property (nonatomic, strong) GGKSavedPhotosManager *savedPhotosManager;

// UIViewController override.
- (void)awakeFromNib;

// UIViewController override. For stopping the capture session. And removing observers.
- (void)dealloc;

// KVO. We want to see the camera's status in real-time.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// (For testing.) Show the current camera settings.
- (void)updateCameraDebugLabels;

// Story: When the user should see the UI in landscape, she does.
- (void)updateLayoutForLandscape;

// Story: When the user should see the UI in portrait, she does.
- (void)updateLayoutForPortrait;

// Story: View will appear to user. User sees updated view.
// UIViewController override. Listen for app coming from background/lock. Update view.
// Whether the view appears from another view in this app or from the app entering the foreground, the user should see an updated view. -viewWillAppear: is called for the former but not the latter. So, we listen for UIApplicationWillEnterForegroundNotification (and stop listening in -viewWillDisappear:).
- (void)viewWillAppear:(BOOL)animated;

// UIViewController override. Undo anything from -viewWillAppear:.
- (void)viewWillDisappear:(BOOL)animated;

// UIViewController override.
// Story: Whether user rotates device in the app, or from the home screen, this method will be called. User sees UI in correct orientation.
- (void)viewWillLayoutSubviews;

@end

@implementation GGKTakePhotoViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.isShowingLandscapeView = NO;
}

- (void)captureManagerDidTakePhoto:(id)sender
{
    //    NSLog(@"captureManagerDidTakePhoto");
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}

- (void)dealloc
{
    [self.captureManager.session stopRunning];
    [self removeObserver:self forKeyPath:@"captureManager.focusAndExposureStatus"];
    
    if (GGKDebugCamera) {
        
        if (self.captureManager.device != nil) {
            
            [self removeObserver:self forKeyPath:@"captureManager.device.focusMode"];
            [self removeObserver:self forKeyPath:@"captureManager.device.exposureMode"];
            [self removeObserver:self forKeyPath:@"captureManager.device.whiteBalanceMode"];
            [self removeObserver:self forKeyPath:@"captureManager.device.focusPointOfInterest"];
            [self removeObserver:self forKeyPath:@"captureManager.device.exposurePointOfInterest"];
            [self removeObserver:self forKeyPath:@"captureManager.device.adjustingFocus"];
            [self removeObserver:self forKeyPath:@"captureManager.device.adjustingExposure"];
            [self removeObserver:self forKeyPath:@"captureManager.device.adjustingWhiteBalance"];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL wasHandledSeparately = NO;
    if (GGKDebugCamera) {
        
        // To keep this simple, if any of our properties change, then report all of them.
        if ([theKeyPath isEqualToString:@"captureManager.device.focusMode"] ||
            [theKeyPath isEqualToString:@"captureManager.device.exposureMode"] ||
            [theKeyPath isEqualToString:@"captureManager.device.whiteBalanceMode"] ||
            [theKeyPath isEqualToString:@"captureManager.device.focusPointOfInterest"] ||
            [theKeyPath isEqualToString:@"captureManager.device.exposurePointOfInterest"] ||
            [theKeyPath isEqualToString:@"captureManager.device.adjustingFocus"] ||
            [theKeyPath isEqualToString:@"captureManager.device.adjustingExposure"] ||
            [theKeyPath isEqualToString:@"captureManager.device.adjustingWhiteBalance"]) {
            
            [self updateCameraDebugLabels];
            wasHandledSeparately = YES;
        }
    }
    
    if ([theKeyPath isEqualToString:@"captureManager.focusAndExposureStatus"]) {
        
        NSString *aString = @"";
        switch (self.captureManager.focusAndExposureStatus) {
                
            case GGKCaptureManagerFocusAndExposureStatusContinuous:
                aString = ToFocusTipString;
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocking:
                aString = @"Focusing…";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocked:
                aString = ToUnlockFocusTipString;
                break;
                
            default:
                break;
        }
        self.tipLabel.text = aString;
    } else if (!wasHandledSeparately) {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (IBAction)playButtonSound
{
    GGKCamAppDelegate *aCamAppDelegate = (GGKCamAppDelegate *)[UIApplication sharedApplication].delegate;
    [aCamAppDelegate.soundModel playButtonTapSound];
}

- (IBAction)takePhoto
{    
    [self.captureManager takePhoto];
    
    // Give visual feedback that photo was taken: Flash the screen.
    UIView *aFlashView = [[UIView alloc] initWithFrame:self.videoPreviewView.frame];
    aFlashView.backgroundColor = [UIColor whiteColor];
    aFlashView.alpha = 0.8f;
    [self.view addSubview:aFlashView];
    [UIView animateWithDuration:0.6f animations:^{
        
        aFlashView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        [aFlashView removeFromSuperview];
    }];
}

- (void)updateCameraDebugLabels
{
    AVCaptureDevice *aCaptureDevice = self.captureManager.device;
    NSString *aString = @"";
    switch (aCaptureDevice.focusMode) {
            
        case AVCaptureFocusModeAutoFocus:
            aString = @"auto.";
            break;
            
        case AVCaptureFocusModeContinuousAutoFocus:
            aString = @"cont.";
            break;
            
        case AVCaptureFocusModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.focusModeLabel.text = [NSString stringWithFormat:@"Foc. mode: %@", aString];
    
    switch (aCaptureDevice.exposureMode) {
            
        case AVCaptureExposureModeAutoExpose:
            aString = @"auto.";
            break;
            
        case AVCaptureExposureModeContinuousAutoExposure:
            aString = @"cont.";
            break;
            
        case AVCaptureExposureModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.exposureModeLabel.text = [NSString stringWithFormat:@"Exp. mode: %@", aString];
    
    switch (aCaptureDevice.whiteBalanceMode) {
            
        case AVCaptureWhiteBalanceModeAutoWhiteBalance:
            aString = @"auto.";
            break;
            
        case AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance:
            aString = @"cont.";
            break;
            
        case AVCaptureWhiteBalanceModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.whiteBalanceModeLabel.text = [NSString stringWithFormat:@"WB mode: %@", aString];
    
    aString = (aCaptureDevice.adjustingFocus) ? @"Yes" : @"No";
    self.focusingLabel.text = [NSString stringWithFormat:@"Focusing: %@", aString];
    
    aString = (aCaptureDevice.adjustingExposure) ? @"Yes" : @"No";
    self.exposingLabel.text = [NSString stringWithFormat:@"Exposing: %@", aString];
    
    aString = (aCaptureDevice.adjustingWhiteBalance) ? @"Yes" : @"No";
    self.whiteBalancingLabel.text = [NSString stringWithFormat:@"Wh. balancing: %@", aString];
    
    // Show points of interest, rounded to decimal (0.1).
    // Depending on the interface orientation, the coordinates may be reversed, mirrored, etc. However, tap-to-focus seems to be working, so I haven't worried about reporting the coordinates correctly.
    CGPoint aPoint = aCaptureDevice.focusPointOfInterest;
    self.focusPointOfInterestLabel.text = [NSString stringWithFormat:@"Foc. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
    aPoint = aCaptureDevice.exposurePointOfInterest;
    self.exposurePointOfInterestLabel.text = [NSString stringWithFormat:@"Exp. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
}

- (void)updateLayoutForLandscape
{
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 883, 662);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    CGFloat anX1 = 20;
    CGSize aSize = self.tipLabel.frame.size;
    self.tipLabel.frame = CGRectMake(anX1, 673, aSize.width, aSize.height);
    
    CGFloat anX2 = 891;
    CGFloat aWidth = 125;
    self.takePhotoButton.frame = CGRectMake(anX2, 8, aWidth, 513);
    
    self.cameraRollButton.frame = CGRectMake(anX2, 571, aWidth, aWidth);
    
    CGFloat anX3 = 530;
    CGFloat aY1 = 645;
    aSize = self.focusModeLabel.frame.size;
    self.focusModeLabel.frame = CGRectMake(anX3, aY1, aSize.width, aSize.height);

    CGFloat aY2 = 663;
    aSize = self.exposureModeLabel.frame.size;
    self.exposureModeLabel.frame = CGRectMake(anX3, aY2, aSize.width, aSize.height);

    CGFloat aY3 = 683;
    aSize = self.whiteBalanceModeLabel.frame.size;
    self.whiteBalanceModeLabel.frame = CGRectMake(anX3, aY3, aSize.width, aSize.height);

    CGFloat anX4 = 649;
    aSize = self.focusingLabel.frame.size;
    self.focusingLabel.frame = CGRectMake(anX4, aY1, aSize.width, aSize.height);

    aSize = self.exposingLabel.frame.size;
    self.exposingLabel.frame = CGRectMake(anX4, aY2, aSize.width, aSize.height);

    aSize = self.whiteBalancingLabel.frame.size;
    self.whiteBalancingLabel.frame = CGRectMake(anX4, aY3, aSize.width, aSize.height);

    CGFloat anX5 = 773;
    aSize = self.focusPointOfInterestLabel.frame.size;
    self.focusPointOfInterestLabel.frame = CGRectMake(anX5, 649, aSize.width, aSize.height);

    aSize = self.exposurePointOfInterestLabel.frame.size;
    self.exposurePointOfInterestLabel.frame = CGRectMake(anX5, 678, aSize.width, aSize.height);
}

- (void)updateLayoutForPortrait
{
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 675, 900);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    CGSize aSize = self.tipLabel.frame.size;
    self.tipLabel.frame = CGRectMake(33, 919, aSize.width, aSize.height);
    
    CGFloat anX1 = 682;
    CGFloat aWidth = 80;
    self.takePhotoButton.frame = CGRectMake(anX1, 8, aWidth, 814);
    
    self.cameraRollButton.frame = CGRectMake(anX1, 872, aWidth, aWidth);
    
    CGFloat anX2 = 7;
    CGFloat aY1 = 900;
    aSize = self.focusModeLabel.frame.size;
    self.focusModeLabel.frame = CGRectMake(anX2, aY1, aSize.width, aSize.height);
    
    CGFloat aY2 = 918;
    aSize = self.exposureModeLabel.frame.size;
    self.exposureModeLabel.frame = CGRectMake(anX2, aY2, aSize.width, aSize.height);
    
    CGFloat aY3 = 938;
    aSize = self.whiteBalanceModeLabel.frame.size;
    self.whiteBalanceModeLabel.frame = CGRectMake(anX2, aY3, aSize.width, aSize.height);
    
    CGFloat anX4 = 558;
    aSize = self.focusingLabel.frame.size;
    self.focusingLabel.frame = CGRectMake(anX4, aY1, aSize.width, aSize.height);
    
    aSize = self.exposingLabel.frame.size;
    self.exposingLabel.frame = CGRectMake(anX4, aY2, aSize.width, aSize.height);
    
    aSize = self.whiteBalancingLabel.frame.size;
    self.whiteBalancingLabel.frame = CGRectMake(anX4, aY3, aSize.width, aSize.height);
    
    CGFloat anX5 = 655;
    aSize = self.focusPointOfInterestLabel.frame.size;
    self.focusPointOfInterestLabel.frame = CGRectMake(anX5, 821, aSize.width, aSize.height);
    
    aSize = self.exposurePointOfInterestLabel.frame.size;
    self.exposurePointOfInterestLabel.frame = CGRectMake(anX5, 850, aSize.width, aSize.height);
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.savedPhotosManager = [[GGKSavedPhotosManager alloc] init];
    [self updateLayoutForPortrait];
    
    // Report focus (and exposure) status in real time.
    [self addObserver:self forKeyPath:@"captureManager.focusAndExposureStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    // Set up the camera.
    GGKCaptureManager *theCaptureManager = [[GGKCaptureManager alloc] init];
    theCaptureManager.delegate = self;
    [theCaptureManager setUpSession];
    [theCaptureManager addPreviewLayerToView:self.videoPreviewView];
    [theCaptureManager startSession];
    self.captureManager = theCaptureManager;
    
    // If not debugging, hide those labels. (They're shown by default so we can see them in the storyboard.) If debugging, set up KVO.
    if (!GGKDebugCamera) {
        
        self.focusModeLabel.hidden = YES;
        self.exposureModeLabel.hidden = YES;
        self.whiteBalanceModeLabel.hidden = YES;
        self.focusingLabel.hidden = YES;
        self.exposingLabel.hidden = YES;
        self.whiteBalancingLabel.hidden = YES;
        self.focusPointOfInterestLabel.hidden = YES;
        self.exposurePointOfInterestLabel.hidden = YES;
    } else {
        
        if (self.captureManager.device != nil) {
            
            [self updateCameraDebugLabels];
            
            // Tried adding observer to self.captureManager.device, but it didn't work.
            [self addObserver:self forKeyPath:@"captureManager.device.focusMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.exposureMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.whiteBalanceMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.focusPointOfInterest" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.exposurePointOfInterest" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (IBAction)viewPhotos
{
    [self.savedPhotosManager viewPhotosViaButton:self.cameraRollButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.appWillEnterForegroundObserver == nil) {
        
        self.appWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [self viewWillAppear:animated];
        }];
    }
    
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.appWillEnterForegroundObserver != nil) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self.appWillEnterForegroundObserver name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Using status-bar orientation, not device orientation. Seems to work.
    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(theInterfaceOrientation) && !self.isShowingLandscapeView) {
        
        [self updateLayoutForLandscape];
        self.isShowingLandscapeView = YES;
    } else if (UIInterfaceOrientationIsPortrait(theInterfaceOrientation) && self.isShowingLandscapeView) {
        
        [self updateLayoutForPortrait];
        self.isShowingLandscapeView = NO;
    }
}

@end
