//
//  GGKTakePhotoViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKCaptureManager.h"

// Not using UIImagePickerControllerDelegate now, but may if we let the user do more than view thumbnails.
@interface GGKTakePhotoViewController : UIViewController <GGKCaptureManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Tap to see camera roll. This button is labeled with the most-recent photo in the roll.
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;

// (For testing.) Report whether currently exposing.
@property (strong, nonatomic) IBOutlet UILabel *exposingLabel;

// (For testing.) Report the current exposure mode.
@property (strong, nonatomic) IBOutlet UILabel *exposureModeLabel;

// (For testing.) Report the current exposure point-of-interest.
@property (strong, nonatomic) IBOutlet UILabel *exposurePointOfInterestLabel;

// (For testing.) Report the current focus mode.
@property (strong, nonatomic) IBOutlet UILabel *focusModeLabel;

// (For testing.) Report the current focus point-of-interest.
@property (strong, nonatomic) IBOutlet UILabel *focusPointOfInterestLabel;

// (For testing.) Report whether currently focusing.
@property (strong, nonatomic) IBOutlet UILabel *focusingLabel;

// Tap to take a photo.
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;

// For displaying a context-sensitive tip.
@property (nonatomic, strong) IBOutlet UILabel *tipLabel;

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

// (For testing.) Report the current white-balance mode.
@property (strong, nonatomic) IBOutlet UILabel *whiteBalanceModeLabel;

// (For testing.) Report whether currently white balancing.
@property (strong, nonatomic) IBOutlet UILabel *whiteBalancingLabel;

- (void)captureManagerDidTakePhoto:(id)sender;
// So, show the most-recent photo thumbnail.

// Story: User taps on a button (touch down). User hears a sound, giving her more feedback that she pressed it.
- (IBAction)playButtonSound;

// Take a photo.
- (IBAction)takePhoto;

// Story: User took photos. User viewed photos. User decided to delete some photos.
// So, let the user view the taken photos and (optionally) remove them.
// (Oops: Can't delete saved photos like in Apple's camera app. Apple doesn't allow.)
// New story: User took photos. User can check thumbnails quickly. Would probably like to tap a thumbnail and see a larger view. Can tap "Back" in popover to see thumbnails again.
- (IBAction)viewPhotos;

@end
