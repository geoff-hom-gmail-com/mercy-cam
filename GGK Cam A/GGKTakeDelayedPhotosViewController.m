//
//  GGKSimpleDelayedPhotoViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKSavedPhotosManager.h"
#import "GGKTakeDelayedPhotosViewController.h"

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger = 3;

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger = 2;

NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString = @"Take delayed photos: number of photos";

NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString = @"Take delayed photos: number of seconds to initially wait";

@interface GGKTakeDelayedPhotosViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// For removing the observer later.
@property (nonatomic, strong) id appWillEnterForegroundObserver;

// For creating the session and managing the capture device.
@property (nonatomic, strong) GGKCaptureManager *captureManager;

// Story: The overall orientation (device/status-bar) is checked against the orientation of this app's UI. The user sees the UI in the correct orientation.
// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;

// Number of photos to take for a given push of the shutter.
@property (nonatomic, assign) NSInteger numberOfPhotosToTake;

// Number of seconds to wait before taking first photo.
@property (nonatomic, assign) CGFloat numberOfSecondsToInitiallyWait;

// This timer goes off every second, so the user can get visual feedback. When it's time to take photos, we need this to invalidate the timer.
@property (nonatomic, strong) NSTimer *oneSecondRepeatingTimer;

// For working with photos in the camera roll.
@property (nonatomic, strong) GGKSavedPhotosManager *savedPhotosManager;

// UIViewController override.
- (void)awakeFromNib;

// So, show the user how many seconds have passed. If enough have passed, start taking photos.
- (void)handleOneSecondTimerFired;

- (void)keyboardWillHide:(NSNotification *)theNotification;
// So, shift the view back to normal.

- (void)keyboardWillShow:(NSNotification *)theNotification;
// So, shift the view up, if necessary.

// KVO. Story: User can see when the focus/exposure is locked.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// Start taking photos, immediately.
- (void)startTakingPhotos;

// Story: User sees UI and knows to wait for photos to be taken, or to tap "Cancel."
- (void)updateForAllowingCancelTimer;

// Story: User sees UI and knows she can tap "Start timer."
- (void)updateForAllowingStartTimer;

// Story: When the user should see the UI in landscape, she does.
- (void)updateLayoutForLandscape;

// Story: When the user should see the UI in portrait, she does.
- (void)updateLayoutForPortrait;

// Set parameters to most-recently used.
- (void)updateSettings;

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

@implementation GGKTakeDelayedPhotosViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.isShowingLandscapeView = NO;
}

- (IBAction)cancelTimer {
    
    [self.oneSecondRepeatingTimer invalidate];
    self.oneSecondRepeatingTimer = nil;
    self.numberOfPhotosToTake = 0;
    [self updateForAllowingStartTimer];
}

- (void)captureManagerDidTakePhoto:(id)sender
{
//    NSLog(@"captureManagerDidTakePhoto");
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
    if (self.numberOfPhotosToTake > 0) {
        
        [self takePhoto];
    } else {
        
        [self updateForAllowingStartTimer];
    }
}

- (void)dealloc {
    
    [self.captureManager.session stopRunning];
    [self removeObserver:self forKeyPath:@"captureManager.focusAndExposureStatus"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleOneSecondTimerFired
{
    NSNumber *theSecondsWaitedNumber = @([self.numberOfSecondsWaitedLabel.text integerValue] + 1);
    self.numberOfSecondsWaitedLabel.text = [theSecondsWaitedNumber stringValue];
    if ([theSecondsWaitedNumber floatValue] >= self.numberOfSecondsToInitiallyWait) {
        
        [self.oneSecondRepeatingTimer invalidate];
        self.oneSecondRepeatingTimer = nil;
        [self startTakingPhotos];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)keyboardWillHide:(NSNotification *)theNotification {
	
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = 0;
    
    NSDictionary* theUserInfo = [theNotification userInfo];
    NSTimeInterval keyboardAnimationDurationTimeInterval = [ theUserInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue ];
    [UIView animateWithDuration:keyboardAnimationDurationTimeInterval animations:^{
        
        self.view.frame = newFrame;
    }];
}

- (void)keyboardWillShow:(NSNotification *)theNotification {
    
    // Shift the view so that the active text field can be seen above the keyboard. We do this by comparing where the keyboard will end up vs. where the text field is. If a shift is needed, we shift the entire view up, synced with the keyboard shifting into place.
    
    NSDictionary *theUserInfo = [theNotification userInfo];
    CGRect keyboardFrameEndRect = [theUserInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	keyboardFrameEndRect = [self.view convertRect:keyboardFrameEndRect fromView:nil];
    CGFloat keyboardTop = keyboardFrameEndRect.origin.y;
    CGFloat activeTextFieldBottom = CGRectGetMaxY(self.activeTextField.frame);
    CGFloat overlap = activeTextFieldBottom - keyboardTop;
    CGFloat margin = 10;
    CGFloat amountToShift = overlap + margin;
    if (amountToShift > 0) {
        
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = newFrame.origin.y - amountToShift;
        NSTimeInterval keyboardAnimationDurationTimeInterval = [ theUserInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue ];
        [UIView animateWithDuration:keyboardAnimationDurationTimeInterval animations:^{
            
            self.view.frame = newFrame;
        }];
    } 
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:@"captureManager.focusAndExposureStatus"]) {
        
        NSString *aString = @"";
        switch (self.captureManager.focusAndExposureStatus) {
                
            case GGKCaptureManagerFocusAndExposureStatusContinuous:
                aString = @"Continuous";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocking:
                aString = @"Locking…";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocked:
                aString = @"Locked";
                break;
                
            default:
                break;
        }
        self.focusLabel.text = [NSString stringWithFormat:@"Focus:\n  %@", aString];
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (IBAction)playButtonSound
{
    GGKCamAppDelegate *aCamAppDelegate = (GGKCamAppDelegate *)[UIApplication sharedApplication].delegate;
    [aCamAppDelegate.soundModel playButtonTapSound];
}

- (void)startTakingPhotos
{
    if (self.numberOfPhotosToTake > 0) {
        
        [self takePhoto];
    }
}

- (IBAction)startTimer
{
    [self updateForAllowingCancelTimer];
    
    self.numberOfSecondsToInitiallyWait = [self.numberOfSecondsToInitiallyWaitTextField.text floatValue];
    self.numberOfPhotosToTake = [self.numberOfPhotosToTakeTextField.text integerValue];
    
    if (self.numberOfSecondsToInitiallyWait == 0) {
        
        [self startTakingPhotos];
    } else {
        
        NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleOneSecondTimerFired) userInfo:nil repeats:YES];
        self.oneSecondRepeatingTimer = aTimer;
    }
}

- (void)takePhoto
{    
//    NSLog(@"TDPVC takePhoto called");
    self.numberOfPhotosToTake -= 1;
    
    [self playButtonSound];
    [self.captureManager takePhoto];
    
    // Show number of photos taken.
    if (self.numberOfPhotosTakenLabel.hidden) {
        
        self.numberOfPhotosTakenLabel.text = @"0";
        self.numberOfPhotosTakenLabel.hidden = NO;
    }
    NSNumber *theNumberOfPhotosTakenNumber = @([self.numberOfPhotosTakenLabel.text integerValue] + 1);
    self.numberOfPhotosTakenLabel.text = [theNumberOfPhotosTakenNumber stringValue];
    
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

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
    
    self.activeTextField = theTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    
    // Behavior depends on which text field was edited. Regardless, check the entered value. If not okay, set to an appropriate value. Store the value.
    
    NSString *theKey;
    id okayValue;
    
    if (theTextField == self.numberOfSecondsToInitiallyWaitTextField) {
        
        theKey = GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;
        okayValue = @([theTextField.text integerValue]);
        
        // The number of seconds to initially wait should be an integer, 0 to 99. If not, fix.
        NSInteger okayValueInteger = [okayValue integerValue];
        if (okayValueInteger < 0) {
            
            okayValue = @0;
        } else if (okayValueInteger > 99) {
            
            okayValue = @99;
        }
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        
        theKey = GGKTakeDelayedPhotosNumberOfPhotosKeyString;
        okayValue = @([theTextField.text integerValue]);
        
        // The number of photos should be from 1 to 99. If not, fix.
        NSInteger okayValueInteger = [okayValue integerValue];
        if (okayValueInteger < 1) {
            
            okayValue = @1;
        } else if (okayValueInteger > 99) {
            
            okayValue = @99;
        }
    }
    
    // Set the new value, then update the entire UI.
    [[NSUserDefaults standardUserDefaults] setObject:okayValue forKey:theKey];
    [self updateSettings];
    
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)updateForAllowingCancelTimer
{
    self.numberOfSecondsToInitiallyWaitTextField.enabled = NO;
    self.numberOfPhotosToTakeTextField.enabled = NO;
    self.numberOfSecondsWaitedLabel.text = @"0";
    self.numberOfSecondsWaitedLabel.hidden = NO;
    self.startTimerButton.enabled = NO;
    self.cancelTimerButton.enabled = YES;
}

- (void)updateForAllowingStartTimer
{
    self.numberOfSecondsToInitiallyWaitTextField.enabled = YES;
    self.numberOfPhotosToTakeTextField.enabled = YES;
    self.numberOfSecondsWaitedLabel.hidden = YES;
    self.numberOfPhotosTakenLabel.hidden = YES;
    self.startTimerButton.enabled = YES;
    self.cancelTimerButton.enabled = NO;
}

- (void)updateLayoutForLandscape
{
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 804, 603);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.focusLabel.frame = CGRectMake(765, 8, 113, 50);
    
    CGFloat anX1 = 886;
    CGFloat aWidth = 130;
    self.startTimerButton.frame = CGRectMake(anX1, 8, aWidth, 451);
    
    self.cancelTimerButton.frame = CGRectMake(916, 466, 100, 60);
    
    self.cameraRollButton.frame = CGRectMake(anX1, 566, aWidth, aWidth);
}

- (void)updateLayoutForPortrait
{
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 644, 859);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.focusLabel.frame = CGRectMake(659, 8, 94, 38);
    
    CGFloat anX1 = 652;
    CGFloat aWidth = 108;
    self.startTimerButton.frame = CGRectMake(anX1, 54, aWidth, 674);
    
    self.cancelTimerButton.frame = CGRectMake(672, 735, 88, 60);
    
    self.cameraRollButton.frame = CGRectMake(anX1, 844, aWidth, aWidth);
}

- (void)updateSettings
{
    NSInteger theNumberOfSecondsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString ifNil:GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger];
    self.numberOfSecondsToInitiallyWaitTextField.text = [NSString stringWithFormat:@"%d", theNumberOfSecondsToInitiallyWaitInteger];
    
    // "second(s), then take"
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theNumberOfSecondsToInitiallyWaitInteger];
    self.secondsLabel.text = [NSString stringWithFormat:@"%@, then take", aSecondsString];
    
    NSInteger theNumberOfPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString ifNil:GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger];
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%d", theNumberOfPhotosInteger];
    
    // "photo(s)."
    NSInteger theNumberOfPhotosToTakeInteger = [self.numberOfPhotosToTakeTextField.text integerValue];
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theNumberOfPhotosToTakeInteger];
    self.photosLabel.text = [NSString stringWithFormat:@"%@.", aPhotosString];
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
    
    // Observe keyboard notifications to shift the screen up/down appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self updateSettings];
    
    [self updateForAllowingStartTimer];
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
