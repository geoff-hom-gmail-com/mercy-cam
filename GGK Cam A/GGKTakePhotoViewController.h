//
//  GGKTakePhotoViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

@interface GGKTakePhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Tap to see camera roll. This button is labeled with the most-recent photo in the roll.
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

// (For testing.) Report the current exposure mode.
@property (strong, nonatomic) IBOutlet UILabel *exposureModeLabel;

// (For testing.) Report the current exposure point-of-interest.
@property (strong, nonatomic) IBOutlet UILabel *exposurePointOfInterestLabel;

// (For testing.) Report the current focus mode.
@property (strong, nonatomic) IBOutlet UILabel *focusModeLabel;

// (For testing.) Report the current focus point-of-interest.
@property (strong, nonatomic) IBOutlet UILabel *focusPointOfInterestLabel;

// (For testing.) Report the current white-balance mode.
@property (strong, nonatomic) IBOutlet UILabel *whiteBalanceModeLabel;

// UIViewController override. For stopping the capture session.
- (void)dealloc;

// Story: User taps on a button (touch down). User hears a sound, giving her more feedback that she pressed it.
- (IBAction)playButtonSound;

// Take a photo.
- (IBAction)takePhoto;

// Story: User took photos. User viewed photos. User decided to delete some photos.
// So, let the user view the taken photos and (optionally) remove them.
- (IBAction)viewPhotos;

// Story: View will appear to user. User sees updated view.
// UIViewController override. Listen for app coming from background/lock. Update view.
// Whether the view appears from another view in this app or from the app entering the foreground, the user should see an updated view. -viewWillAppear: is called for the former but not the latter. So, we listen for UIApplicationWillEnterForegroundNotification (and stop listening in -viewWillDisappear:).
- (void)viewWillAppear:(BOOL)animated;

// UIViewController override. Undo anything from -viewWillAppear:.
- (void)viewWillDisappear:(BOOL)animated;

@end
