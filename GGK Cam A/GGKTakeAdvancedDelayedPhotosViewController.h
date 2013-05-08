//
//  GGKTakeAdvancedDelayedPhotosViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGKCaptureManager.h"
#import "GGKTimeUnitsTableViewController.h"

// The default number of photos to take.
extern const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger;

// The default number of time units between each photo.
extern const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger;

// The default number of time units to initially wait.
extern const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger;

// The default time unit to use between each photo.
extern const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit;

// The default time unit to use for the initial wait.
extern const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit;

// Key for storing the number of photos to take.
extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString;

// Key for storing the number of time units between each photo.
extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString;

// Key for storing the number of time units to initially wait.
extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString;

// Key for storing the time unit to use between each photo.
extern NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString;

// Key for storing the time unit to use for the initial wait.
extern NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString;

@interface GGKTakeAdvancedDelayedPhotosViewController : UIViewController <GGKCaptureManagerDelegate, GGKTimeUnitsTableViewControllerDelegate, UITextFieldDelegate>

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

// Number of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsBetweenPhotosTextField;

// Number of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToInitiallyWaitTextField;

// Story: User taps "Start timer." User sees label below; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that the timer has started and can estimate when the first photo will be taken. 
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsInitiallyWaitedLabel;

// Story: User taps "Start timer." After the first photo, user sees label below; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that another photo will be taken eventually and can estimate when that will be.
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsWaitedBetweenPhotosLabel;

// Story: User sets number of photos to 1. User sees "1 photo with" instead of "1 photos with."
// Text is normally "photos with," but it may be singular.
@property (weak, nonatomic) IBOutlet UILabel *photosWithLabel;

// Tap to start the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;

// Story: User taps "Start timer." Regardless of how long-term the timer parameters are, the user understands that the timer has started and is still working (because of the counter in seconds). She also understands when the next photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *timeRemainingUntilNextPhotoLabel;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units between photos to 1. User sees singular text for that time unit.
// The type of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsBetweenPhotosButton;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units to initially wait to 1. User sees singular text for that time unit.
// The type of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsToInitiallyWaitButton;

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

- (void)captureManagerDidTakePhoto:(id)sender;
// So, show the most-recent photo thumbnail.

// Story: User taps on a button (touch down). User hears a sound, giving her more feedback that she pressed it.
- (IBAction)playButtonSound;

- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// So, update the appropriate button and dismiss the popover.

// Story: User took photos. User viewed photos. User decided to delete some photos.
// So, let the user view the taken photos and (optionally) remove them.
// (Oops: Can't delete saved photos like in Apple's camera app. Apple doesn't allow.)
// New story: User took photos. User can check thumbnails quickly. Would probably like to tap a thumbnail and see a larger view. Can tap "Back" in popover to see thumbnails again.
- (IBAction)viewPhotos;

@end
