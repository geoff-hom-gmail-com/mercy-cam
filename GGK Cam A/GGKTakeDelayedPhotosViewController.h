//
//  GGKSimpleDelayedPhotoViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKCaptureManager.h"

// The default number of photos to take.
extern const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger;

// The default number of seconds to initially wait.
extern const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger;

// Key for storing the number of photos to take.
extern NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString;

// Key for storing the number of seconds to initially wait.
extern NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;

@interface GGKTakeDelayedPhotosViewController : UIViewController <GGKCaptureManagerDelegate, UITextFieldDelegate>

// Tap to see camera roll. This button shows the most-recent photo in the roll. 
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;

// Tap to cancel the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *cancelTimerButton;

// For displaying when the focus is continuous or locked. (Displays "locked" only when both focus and exposure are locked. Otherwise, displays "continuous" or "locking.")
@property (nonatomic, strong) IBOutlet UILabel *focusLabel;

// Story: User taps "Start timer." User sees label below appear and increment with each photo taken. User implicitly understands when photos are taken, how many photos remain, and how long it will take.
@property (nonatomic, weak) IBOutlet UILabel *numberOfPhotosTakenLabel;

// Number of photos to take for a given tap of the shutter button.
@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;

// Number of seconds to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfSecondsToInitiallyWaitTextField;

// Story: User taps "Start timer." User sees label below appear and increment with each second. User implicitly understands that the timer has started and when the first photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *numberOfSecondsWaitedLabel;

// In "Wait X seconds, then take Y photos," it's "photos." But may be singular or plural.
@property (weak, nonatomic) IBOutlet UILabel *photosLabel;

// In "Wait X seconds, then take Y photos," it's "seconds, then take." But may be singular or plural.
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;

// Tap to start the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;

// To let user know, visually, that the timer started.
@property (weak, nonatomic) IBOutlet UILabel *timerStartedLabel;

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

// Cancel the timer and don't take any more photos.
- (IBAction)cancelTimer;

- (void)captureManagerDidTakePhoto:(id)sender;
// So, show the most-recent photo thumbnail. If more photos to be taken, do that.

// Story: User taps on a button (touch down). User hears a sound, giving her more feedback that she pressed it.
- (IBAction)playButtonSound;

// Start the timer to take photos.
- (IBAction)startTimer;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
// So, note which text field is being edited. (To know whether to shift the screen up when the keyboard shows.)

- (void)textFieldDidEndEditing:(UITextField *)textField;
// So, if an invalid value was entered, then use the previous value. Also, note that no text field is being edited now.

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// So, dismiss the keyboard.

// View camera roll.
- (IBAction)viewPhotos;

@end
