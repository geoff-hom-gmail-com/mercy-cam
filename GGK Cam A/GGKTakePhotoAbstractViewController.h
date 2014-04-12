//
//  GGKTakePhotoAbstractViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// An abstract class to facilitate taking a photo. The storyboard/Nib is up to the subclass. The user can see the camera preview in a view. She can tap the preview to focus. She can see the most-recent photo on a button; tapping that button shows the camera roll. 

#import "GGKCaptureManager.h"
#import "GGKViewController.h"

// Key path for doing KVO on the capture manager's focus-and-exposure-status.
extern NSString *GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString;

@class GGKSavedPhotosManager;
@interface GGKTakePhotoAbstractViewController : GGKViewController <GGKCaptureManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
// Live stream from camera is shown here.
@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
// Tap to see camera roll. This button is labeled with the most-recent photo in the roll.
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
// For creating the capture session and managing the capture device.
@property (nonatomic, strong) GGKCaptureManager *captureManager;
// For working with photos in the camera roll.
@property (nonatomic, strong) GGKSavedPhotosManager *savedPhotosManager;
// Show the most-recent photo thumbnail.
- (void)captureManagerDidTakePhoto:(id)sender;
// Override.
- (void)dealloc;
// Notify capture manager.
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer;
// Override.
- (void)handleViewDidDisappearFromUser;
// Override.
- (void)handleViewWillAppearToUser;
// Show the image in the popover.
- (void)imagePickerController:(UIImagePickerController *)theImagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)theInfoDictionary;
// Watching for several things: 1) If pushing onto this VC, destroy the capture session so it won't snapshot. 2) If popping to this VC, create a capture session to offset 1). 3) If this VC will be popped, nil this VC as the NC delegate. (-dealloc is too late.)
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;
// KVO. Story: User can see when the focus and exposure is locked.
// Stub; but it catches the KVO for the capture manager's focus-and-exposure-status.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
// Override.
- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)sender;
// Take a photo. Includes feedback via sound and a flash on the screen.
- (IBAction)takePhoto;
// Rotate the camera preview to the device's orientation. Resize the preview view.
- (void)updatePreviewOrientation;
// Override.
- (void)viewDidLoad;
@end
