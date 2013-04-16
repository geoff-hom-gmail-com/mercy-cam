//
//  GGKTakePhotoViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GGKCaptureManager.h"
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

// For converting the tap point to device space.
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

// For retaining the popover and its content view controller.
@property (strong, nonatomic) UIPopoverController *savedPhotosPopoverController;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

// UIViewController override. For stopping the capture session. And removing observers.
- (void)dealloc;

// Story: User taps on object. Focus and exposure auto-adjust and lock there. User taps again in view. Focus and exposure return to continuous. (If the user taps again before both focus and exposure lock, then the new tap will be the POI and both will relock.)
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer;

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// So, update the image in the button for showing the camera roll. If another photo is supposed to be taken, do it.

// (For camera debugging.) KVO. We want to see the camera's status in real-time.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// Show most-recent photo from camera roll on button for viewing camera roll.
- (void)showMostRecentPhotoOnButton;

// (For testing.) Show the current camera settings.
- (void)updateCameraDebugLabels;

@end

@implementation GGKTakePhotoViewController

- (void)dealloc
{
    [self.captureManager.session stopRunning];
    [self removeObserver:self forKeyPath:@"captureManager.device.focusMode"];
    [self removeObserver:self forKeyPath:@"captureManager.device.exposureMode"];
    
    if (GGKDebugCamera) {
        
        if (self.captureManager.device != nil) {
            
//            [self removeObserver:self forKeyPath:@"captureManager.device.focusMode"];
//            [self removeObserver:self forKeyPath:@"captureManager.device.exposureMode"];
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

- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer
{
    AVCaptureDevice *aCaptureDevice = self.captureManager.device;
    if (aCaptureDevice == nil) {
        
        NSLog(@"GGK warning: No capture-device input.");
    } else {
        
        if (aCaptureDevice.focusMode != AVCaptureFocusModeLocked ||
            aCaptureDevice.exposureMode != AVCaptureExposureModeLocked) {
            
            CGPoint theTapPoint = [theTapGestureRecognizer locationInView:self.videoPreviewView];
            CGPoint theConvertedTapPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:theTapPoint];
            [self.captureManager focusAtPoint:theConvertedTapPoint];
        } else {
            
            [self.captureManager unlockFocus];
        }
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{    
    [self showMostRecentPhotoOnButton];
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
        }
    }
    
    if ([theKeyPath isEqualToString:@"captureManager.device.focusMode"] ||
        [theKeyPath isEqualToString:@"captureManager.device.exposureMode"]) {
        
        AVCaptureDevice *aCaptureDevice = self.captureManager.device;
        if (aCaptureDevice.focusMode == AVCaptureFocusModeLocked && aCaptureDevice.exposureMode == AVCaptureExposureModeLocked) {
            
            self.tipLabel.text = ToUnlockFocusTipString;
        } else {
            
            self.tipLabel.text = ToFocusTipString;
        }
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (IBAction)playButtonSound
{
    [self.soundModel playButtonTapSound];
}

- (void)showMostRecentPhotoOnButton
{    
    // Show thumbnail on button for showing camera roll.
    void (^showPhotoOnButton)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *photoAsset, NSUInteger index, BOOL *stop) {
        
        // End of enumeration is signalled by asset == nil.
        if (photoAsset == nil) {
            
            return;
        }
        
        CGImageRef aPhotoThumbnailImageRef = [photoAsset thumbnail];
        UIImage *aPhotoImage = [UIImage imageWithCGImage:aPhotoThumbnailImageRef];
        [self.cameraRollButton setImage:aPhotoImage forState:UIControlStateNormal];
        
        // If we don't the title to nil, it still shows along the edge.
        [self.cameraRollButton setTitle:nil forState:UIControlStateNormal];
    };
    
    // Show thumbnail of most-recent photo in group on button for showing camera roll.
    void (^showMostRecentPhotoInGroupOnButton)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        
        // If no photos, skip.
        [ group setAssetsFilter:[ALAssetsFilter allPhotos] ];
        NSInteger theNumberOfPhotos = [group numberOfAssets];
        if (theNumberOfPhotos < 1) {
            
            return;
        }
        
        NSIndexSet *theMostRecentPhotoIndexSet = [NSIndexSet indexSetWithIndex:(theNumberOfPhotos - 1)];
        [group enumerateAssetsAtIndexes:theMostRecentPhotoIndexSet options:0 usingBlock:showPhotoOnButton];
    };
    
    // If no photos, show this text.
    [self.cameraRollButton setTitle:@"Saved photos" forState:UIControlStateNormal];
    
    ALAssetsLibrary *theAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [theAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:showMostRecentPhotoInGroupOnButton failureBlock:^(NSError *error) {
        
        NSLog(@"Warning: Couldn't see saved photos.");
    }];
}

- (IBAction)takePhoto
{    
    NSLog(@"SDPVC takePhoto called");
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureManager.session.outputs[0];
    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
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
    
    if (aCaptureConnection != nil) {
        
        [aCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:aCaptureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer != NULL) {
                
                NSData *theImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *theImage = [[UIImage alloc] initWithData:theImageData];
                UIImageWriteToSavedPhotosAlbum(theImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
    } else {
        
        NSLog(@"GGK warning: aCaptureConnection nil");
        UIImageWriteToSavedPhotosAlbum(nil, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
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
    CGPoint aPoint = aCaptureDevice.focusPointOfInterest;
    self.focusPointOfInterestLabel.text = [NSString stringWithFormat:@"Foc. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
    aPoint = aCaptureDevice.exposurePointOfInterest;
    self.exposurePointOfInterestLabel.text = [NSString stringWithFormat:@"Exp. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.soundModel = [[GGKSoundModel alloc] init];
    
    // Set up the camera.
    GGKCaptureManager *theCaptureManager = [[GGKCaptureManager alloc] init];
    [theCaptureManager setUpSession];
    self.captureManager = theCaptureManager;
        
    // Add camera preview.
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureManager.session];
    aCaptureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    CALayer *viewLayer = self.videoPreviewView.layer;
    [viewLayer addSublayer:aCaptureVideoPreviewLayer];
    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
    
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [self.captureManager.session startRunning];
    }];
    
    // Story: User taps on object. Focus locks there. User taps again in view. Focus returns to continuous.
    UITapGestureRecognizer *aSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTappedInCameraView:)];
    aSingleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.videoPreviewView addGestureRecognizer:aSingleTapGestureRecognizer];
    
    // Set up the tip label.
    self.tipLabel.text = ToFocusTipString;
    [self addObserver:self forKeyPath:@"captureManager.device.focusMode" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"captureManager.device.exposureMode" options:NSKeyValueObservingOptionNew context:nil];
    
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
//            [self addObserver:self forKeyPath:@"captureManager.device.focusMode" options:NSKeyValueObservingOptionNew context:nil];
//            [self addObserver:self forKeyPath:@"captureManager.device.exposureMode" options:NSKeyValueObservingOptionNew context:nil];
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        // UIImagePickerController browser on iPad must be presented in a popover.
        
        UIImagePickerController *anImagePickerController = [[UIImagePickerController alloc] init];
        anImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        anImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        anImagePickerController.delegate = self;
        anImagePickerController.allowsEditing = NO;
        
        UIPopoverController *aPopoverController = [[UIPopoverController alloc] initWithContentViewController:anImagePickerController];
        [aPopoverController presentPopoverFromRect:self.cameraRollButton.bounds inView:self.cameraRollButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.savedPhotosPopoverController = aPopoverController;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.appWillEnterForegroundObserver == nil) {
        
        self.appWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [self viewWillAppear:animated];
        }];
    }
    
    [self showMostRecentPhotoOnButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.appWillEnterForegroundObserver != nil) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self.appWillEnterForegroundObserver name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

@end
