//
//  GGKTakePhotoAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKAbstractPhotoViewController.h"

#import "GGKSavedPhotoViewController.h"
#import "GGKSavedPhotosManager.h"
#import "GGKUtilities.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation GGKAbstractPhotoViewController
- (void)dealloc {
    [self.takePhotoModel destroyCaptureSession];
}
- (IBAction)handleCancelTimerTapped {
    [self stopOneSecondRepeatingTimer];
    self.model.appMode = GGKAppModePlanning;
    [self updateUI];
}
- (void)handleEnoughTimePassedToTakePhoto {
    [self takePhoto];
    // In subclass, determine whether to stop timer.
    
    // if delayed only, then stop timer here.
    // if spaced and this will be last photo, stop timer.
    
    // if spaced and not last photo, need to set how many seconds to wait again
    
}
- (void)handleOneSecondTimerFired {
    // Each tick of this timer is 1 sec, so we can use that both to show how much time has passed and to determine if enough time has passed.
    self.takePhotoModel.numberOfSecondsWaitedInteger++;
    // notify delegate to do this?
    [self updateTimerUI];
    // shouldn't this be like [self.model numberOfSecondsToWaitInteger]?
    if (self.takePhotoModel.numberOfSecondsWaitedInteger == [self.takePhotoModel numberOfSecondsToWaitInteger]) {
        // and this one... we need the flash... use another delegate method? like takePhotoModelWillTakePhoto?
        [self takePhoto];
        if (![self.takePhotoModel timerIsNeeded]) {
            [self.takePhotoModel stopOneSecondRepeatingTimer];
        }
    }
}
// Stub.
- (void)updateTimerUI {
}

// Should override.
// Seconds to wait to take photo. When seconds waited matches this, handleEnoughTimePassedToTakePhoto is called.
- (NSInteger)numberOfSecondsToWaitInteger {
    return 0;
}
- (IBAction)handleTriggerButtonTapped:(id)sender {
    self.model.appMode = GGKAppModeShooting;
    [self updateUI];
    [self.takePhotoModel startTrigger];
}
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer {
    CGPoint theTapPoint = [theTapGestureRecognizer locationInView:theTapGestureRecognizer.view];
    CGPoint theCaptureDevicePoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:theTapPoint];
    [self.takePhotoModel handleUserTappedAtDevicePoint:theCaptureDevicePoint];
}
- (void)handleViewDidDisappearFromUser {
    [super handleViewDidDisappearFromUser];
    [self.takePhotoModel stopCaptureSession];
}
- (void)handleViewWillAppearToUser {
    [super handleViewWillAppearToUser];
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
    [self.takePhotoModel unlockFocus];
    [self.takePhotoModel startCaptureSession];
}
- (void)imagePickerController:(UIImagePickerController *)theImagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)theInfoDictionary {
    // An image picker controller is also a navigation controller. So, we'll push a view controller with the image onto the image picker controller.
    // Was going to use a push segue in the storyboard, for clarity. However, this VC is abstract and not instantiated from the storyboard, so that doesn't work.
    // Note that the image picker is assumed to be 320 x 480, as set in the storyboard.
    GGKSavedPhotoViewController *aSavedPhotoViewController = (GGKSavedPhotoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SavedPhotoViewController"];
    UIImage *anImage = theInfoDictionary[UIImagePickerControllerOriginalImage];
    // instantiateViewControllerWithIdentifier: doesn't result in viewDidLoad being called. However, viewDidLoad will be called sometime after pushViewController:.
    aSavedPhotoViewController.image = anImage;
    [theImagePickerController pushViewController:aSavedPhotoViewController animated:YES];
}
- (GGKTakePhotoModel *)makeTakePhotoModel {
    GGKTakePhotoModel *theTakePhotoModel = [[GGKTakePhotoModel alloc] init];
    return theTakePhotoModel;
}
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)theOperation fromViewController:(UIViewController *)theFromVC toViewController:(UIViewController *)theToVC {
    if ((theOperation == UINavigationControllerOperationPush) && (theFromVC == self)) {
        [self.takePhotoModel destroyCaptureSession];
        self.captureVideoPreviewLayer.session = nil;
    }
    if ((theOperation == UINavigationControllerOperationPop) && (theToVC == self)) {
        [self.takePhotoModel makeCaptureSession];
        self.captureVideoPreviewLayer.session = self.takePhotoModel.captureSession;
    }
    if ((theOperation == UINavigationControllerOperationPop) && (theFromVC == self)) {
        self.navigationController.delegate = nil;
    }
    return nil;
}
- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender {
    if ([theSegue.identifier hasPrefix:@"ShowSavedPhotos"]) {
        // Story: User took photos. User can view thumbnails quickly. (Can't delete saved photos like in Apple's camera app. Apple doesn't allow.)
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        // Set up an image picker controller.
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            // Tried creating image-picker controller in storyboard. Worked in iOS 6, but in iOS 7 resulted in only a blank screen.
            UIImagePickerController *anImagePickerController = [[UIImagePickerController alloc] init];
            anImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            anImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            anImagePickerController.delegate = self;
            anImagePickerController.allowsEditing = NO;
            self.currentPopoverController.contentViewController = anImagePickerController;
        }
    } else {
        [super prepareForSegue:theSegue sender:theSender];
    }
}

//- (void)startTimer {
//    self.takePhotoModel.numberOfSecondsWaitedInteger = 0;
//    // Start a timer to count seconds.
//    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleOneSecondTimerFired) userInfo:nil repeats:YES];
//    self.takePhotoModel.oneSecondRepeatingTimer = aTimer;
//}

- (void)stopOneSecondRepeatingTimer {
    [self.takePhotoModel.oneSecondRepeatingTimer invalidate];
    self.takePhotoModel.oneSecondRepeatingTimer = nil;
}

//- (void)takePhoto {
//    [self playButtonSound];
//    [self.takePhotoModel takePhoto];
//    // Give visual feedback that photo was taken: Flash the screen.
//    UIView *aFlashView = [[UIView alloc] initWithFrame:self.cameraPreviewView.frame];
//    aFlashView.backgroundColor = [UIColor whiteColor];
//    aFlashView.alpha = 0.8f;
//    [self.view addSubview:aFlashView];
//    [UIView animateWithDuration:0.6f animations:^{
//        aFlashView.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [aFlashView removeFromSuperview];
//    }];
//}



- (void)takePhotoModelDidTakePhoto:(id)sender {
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}
- (void)takePhotoModelFocusAndExposureStatusDidChange:(id)sender {
    NSString *aString = @"";
    switch (self.takePhotoModel.focusAndExposureStatus) {
        case GGKTakePhotoModelFocusAndExposureStatusContinuous:
            // User learns about autofocus and how to focus on an object.
            aString = @"Focus mode: Autofocus on center. To focus elsewhere, tap there.";
            break;
        case GGKTakePhotoModelFocusAndExposureStatusLocking:
            // User knows camera is in process of locking focus.
            aString = @"Locking focus …";
            break;
        case GGKTakePhotoModelFocusAndExposureStatusLocked:
            // User learns the focus is locked. User learns how to unlock.
            aString = @"Focus: LOCKED. To unlock, tap anywhere in the view.";
            break;
        default:
            break;
    }
    self.tipLabel.text = aString;
}
- (void)takePhotoModelWillTakePhoto:(id)sender {
    [self playButtonSound];
    // Give visual feedback that photo was taken: Flash the screen.
    UIView *aFlashView = [[UIView alloc] initWithFrame:self.cameraPreviewView.frame];
    aFlashView.backgroundColor = [UIColor whiteColor];
    aFlashView.alpha = 0.8f;
    [self.view addSubview:aFlashView];
    [UIView animateWithDuration:0.6f animations:^{
        aFlashView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [aFlashView removeFromSuperview];
    }];
}

- (void)updatePreviewOrientation {
    self.captureVideoPreviewLayer.frame = self.cameraPreviewView.bounds;
    self.captureVideoPreviewLayer.connection.videoOrientation = [self.takePhotoModel properCaptureVideoOrientation];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [GGKUtilities matchFrameOfRotated90View:self.leftTriggerButton withView:self.proxyLeftTriggerButton];
    [GGKUtilities matchFrameOfRotated90View:self.rightTriggerButton withView:self.proxyRightTriggerButton];
    [self updatePreviewOrientation];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelTimerButton.layer.cornerRadius = 3.0f;
    self.timerSettingsView.layer.cornerRadius = 3.0f;
    self.tipLabel.layer.cornerRadius = 3.0f;
    // Make side buttons. We want vertical/rotated text, so the buttons are rotated. Rotation doesn't work with constraints; no constraints means we have to make the button in code. However, the storyboard has proxy buttons: proper frame (via constraints) but horizontal text.
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    aButton.titleLabel.font = self.proxyLeftTriggerButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.proxyLeftTriggerButton];
    self.leftTriggerButton = aButton;
    aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    aButton.titleLabel.font = self.proxyRightTriggerButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.proxyRightTriggerButton];
    self.rightTriggerButton = aButton;
    NSString *aButtonTitleString = [self.bottomTriggerButton titleForState:UIControlStateNormal];
    for (UIButton *aButton in @[self.leftTriggerButton, self.rightTriggerButton]) {
        aButton.backgroundColor = [UIColor whiteColor];
        [aButton setTitle:aButtonTitleString forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(playButtonSound) forControlEvents:UIControlEventTouchDown];
        [aButton addTarget:self action:@selector(handleTriggerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:aButton];
    }
    self.proxyLeftTriggerButton.hidden = YES;
    self.proxyRightTriggerButton.hidden = YES;
    // Add border to trigger buttons.
    NSArray *aButtonArray = @[self.leftTriggerButton, self.rightTriggerButton, self.bottomTriggerButton];
    for (UIButton *aButton in aButtonArray) {
        [GGKUtilities addBorderOfColor:[UIColor clearColor] toView:aButton];
    }
    self.savedPhotosManager = [[GGKSavedPhotosManager alloc] init];
    // Set up camera: add tap-to-focus to the view, add the preview layer and make the capture session.
    // Story: User taps on object. Focus locks there. User taps again in view. Focus returns to continuous.
    UITapGestureRecognizer *aSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTappedInCameraView:)];
    aSingleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.cameraPreviewView addGestureRecognizer:aSingleTapGestureRecognizer];
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    aCaptureVideoPreviewLayer.frame = self.cameraPreviewView.bounds;
    [self.cameraPreviewView.layer addSublayer:aCaptureVideoPreviewLayer];
    
    GGKTakePhotoModel *theTakePhotoModel = [self makeTakePhotoModel];
//    GGKTakePhotoModel *theTakePhotoModel = [[GGKTakePhotoModel alloc] init];
    
    theTakePhotoModel.delegate = self;
    [theTakePhotoModel makeCaptureSession];
    aCaptureVideoPreviewLayer.session = theTakePhotoModel.captureSession;
    self.takePhotoModel = theTakePhotoModel;
    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
    // Watch for push onto this VC. If so, capture session will snapshot (undesired).
    self.navigationController.delegate = self;
}




@end
