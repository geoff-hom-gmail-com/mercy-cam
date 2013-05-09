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

// Not using UIImagePickerControllerDelegate now, but may if we let the user do more than view thumbnails.
@interface GGKTakePhotoAbstractViewController : GGKViewController <GGKCaptureManagerDelegate, UIImagePickerControllerDelegate>

// Tap to see camera roll. This button is labeled with the most-recent photo in the roll.
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;

// For creating the session and managing the capture device.
@property (nonatomic, strong) GGKCaptureManager *captureManager;

// For working with photos in the camera roll.
@property (nonatomic, strong) GGKSavedPhotosManager *savedPhotosManager;

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

- (void)captureManagerDidTakePhoto:(id)sender;
// So, show the most-recent photo thumbnail.

// Override.
- (void)dealloc;

// KVO. Story: User can see when the focus and exposure is locked.
// Stub; but it catches the KVO for the capture manager's focus-and-exposure-status.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// Take a photo. Includes feedback via sound and a flash on the screen.
- (IBAction)takePhoto;

// Override.
- (void)viewDidLoad;

// Story: User took photos. User viewed photos. User decided to delete some photos.
// So, let the user view the taken photos and (optionally) remove them.
// (Oops: Can't delete saved photos like in Apple's camera app. Apple doesn't allow.)
// New story: User took photos. User can check thumbnails quickly. 
- (IBAction)viewPhotos;

// Override.
- (void)viewWillAppear:(BOOL)animated;

@end
