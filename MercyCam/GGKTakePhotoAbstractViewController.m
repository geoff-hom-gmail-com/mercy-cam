//
//  GGKTakePhotoAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoAbstractViewController.h"

#import "GGKSavedPhotoViewController.h"
#import "GGKSavedPhotosManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

NSString *GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString = @"captureManager.focusAndExposureStatus";
@interface GGKTakePhotoAbstractViewController ()
// For showing camera preview to the user, and for converting taps to device space.
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;
@end
@implementation GGKTakePhotoAbstractViewController
- (void)captureManagerDidTakePhoto:(id)sender {
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}
- (void)dealloc {
    [self.captureManager.session stopRunning];
    [self removeObserver:self forKeyPath:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString];
}
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer {
    CGPoint theTapPoint = [theTapGestureRecognizer locationInView:theTapGestureRecognizer.view];
    CGPoint theCaptureDevicePoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:theTapPoint];
    [self.captureManager handleUserTappedAtDevicePoint:theCaptureDevicePoint];
}
- (void)handleViewDidDisappearFromUser {
    [super handleViewDidDisappearFromUser];
    [self.captureManager.session stopRunning];
}
- (void)handleViewWillAppearToUser {
    [super handleViewWillAppearToUser];
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
    [self.captureManager unlockFocus];
    [self.captureManager startSession];
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
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)theOperation fromViewController:(UIViewController *)theFromVC toViewController:(UIViewController *)theToVC {
    if ((theOperation == UINavigationControllerOperationPush) && (theFromVC == self)) {
        [self.captureManager destroySession];
        self.captureVideoPreviewLayer.session = nil;
    }
    if ((theOperation == UINavigationControllerOperationPop) && (theToVC == self)) {
        [self.captureManager makeSession];
        self.captureVideoPreviewLayer.session = self.captureManager.session;
    }
    if ((theOperation == UINavigationControllerOperationPop) && (theFromVC == self)) {
        self.navigationController.delegate = nil;
    }
    return nil;
}
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([theKeyPath isEqualToString:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString]) {
// Template for subclasses.
//        switch (self.captureManager.focusAndExposureStatus) {
//            case GGKCaptureManagerFocusAndExposureStatusContinuous:
//                break;
//            case GGKCaptureManagerFocusAndExposureStatusLocking:
//                break;
//            case GGKCaptureManagerFocusAndExposureStatusLocked:
//                break;
//            default:
//                break;
//        }
    } else {
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
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
- (IBAction)takePhoto {
    [self playButtonSound];
    [self.captureManager takePhoto];
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
    self.captureVideoPreviewLayer.connection.videoOrientation = [self.captureManager properCaptureVideoOrientation];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updatePreviewOrientation];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.savedPhotosManager = [[GGKSavedPhotosManager alloc] init];
    // Report focus (and exposure) status in real time.
    [self addObserver:self forKeyPath:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    // Set up the camera: add tap-to-focus to the view, add the preview layer and make the capture session.
    // Story: User taps on object. Focus locks there. User taps again in view. Focus returns to continuous.
    UITapGestureRecognizer *aSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTappedInCameraView:)];
    aSingleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.cameraPreviewView addGestureRecognizer:aSingleTapGestureRecognizer];
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    aCaptureVideoPreviewLayer.frame = self.cameraPreviewView.bounds;
    [self.cameraPreviewView.layer addSublayer:aCaptureVideoPreviewLayer];
    GGKCaptureManager *theCaptureManager = [[GGKCaptureManager alloc] init];
    theCaptureManager.delegate = self;
    [theCaptureManager makeSession];
    aCaptureVideoPreviewLayer.session = theCaptureManager.session;
    self.captureManager = theCaptureManager;
    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
    // Watch for push onto this VC. If so, capture session will snapshot (undesired).
    self.navigationController.delegate = self;
}
@end
