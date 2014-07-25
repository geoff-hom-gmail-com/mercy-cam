//
//  GGKTakePhotoAbstractViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// An abstract class to facilitate taking a photo. The storyboard/Nib is up to the subclass. The user can see the camera preview in a view. She can tap the preview to focus. She can see the most-recent photo on a button; tapping that button shows the camera roll. 

#import "GGKTakePhotoModel.h"
#import "GGKViewController.h"

@class GGKSavedPhotosManager;

@interface GGKAbstractPhotoViewController : GGKViewController <GGKTakePhotoModelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
// Tap to trigger the main action (e.g., take a photo, start photo timer).
@property (weak, nonatomic) IBOutlet UIButton *bottomTriggerButton;
// Live stream from camera is shown here.
@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
// Tap to see camera roll. This button is labeled with the most-recent photo in the roll.
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
// For showing camera preview to the user, and for converting taps to device space.
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;
// Same as bottom trigger, but along left side for convenience.
@property (weak, nonatomic) UIButton *leftTriggerButton;
// Proxy button gives frame for rotated button.
@property (weak, nonatomic) IBOutlet UIButton *proxyLeftTriggerButton;
@property (weak, nonatomic) IBOutlet UIButton *proxyRightTriggerButton;
// Same as bottom trigger, but along right side for convenience.
@property (weak, nonatomic) UIButton *rightTriggerButton;
// To use the camera roll.
@property (nonatomic, strong) GGKSavedPhotosManager *savedPhotosManager;
// To take photos via a capture session.
@property (nonatomic, strong) GGKTakePhotoModel *takePhotoModel;
// For displaying a context-sensitive tip. (E.g., about focus state.)
@property (nonatomic, strong) IBOutlet UILabel *tipLabel;
// Override.
- (void)dealloc;
// Called after user taps a trigger button.
// Stub.
- (IBAction)handleTriggerButtonTapped:(id)sender;
// Notify take-photo model.
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer;
// Override.
- (void)handleViewDidDisappearFromUser;
// Override.
- (void)handleViewWillAppearToUser;
// Show the image in the popover.
- (void)imagePickerController:(UIImagePickerController *)theImagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)theInfoDictionary;
// Watching for several things: 1) If pushing onto this VC, destroy the capture session so it won't snapshot. 2) If popping to this VC, create a capture session to offset 1). 3) If this VC will be popped, nil this VC as the NC delegate. (-dealloc is too late.)
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;
// Override.
// User tapped camera-roll button. User sees thumbnails in popover.
- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)sender;
// Take a photo. Includes feedback via sound and a flash on the screen.
- (void)takePhoto;
// Show the most recent photo thumbnail.
- (void)takePhotoModelDidTakePhoto:(id)sender;
// User sees current focus-and-exposure status. Also, she sees her options.
- (void)takePhotoModelFocusAndExposureStatusDidChange:(id)sender;
// Rotate the camera preview to the device's orientation. Resize the preview view.
- (void)updatePreviewOrientation;
// Override.
// Update things after constraints have been applied.
// Device orientation may have changed. Make sure preview layer matches.
- (void)viewDidLayoutSubviews;
// Override.
- (void)viewDidLoad;
@end
