//
//  GGKTakeAdvancedDelayedPhotosViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGKTimeUnitsTableViewController.h"

@interface GGKTakeAdvancedDelayedPhotosViewController : UIViewController <GGKTimeUnitsTableViewControllerDelegate>

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

// Number of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToInitiallyWaitTextField;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// The type of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsBetweenPhotosButton;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// The type of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsToInitiallyWaitButton;

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

// In "Wait X seconds, then take Y photos," it's "Wait."
@property (nonatomic, weak) IBOutlet UILabel *waitLabel;

// Story: User taps on a button (touch down). User hears a sound, giving her more feedback that she pressed it.
- (IBAction)playButtonSound;

- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// So, update the appropriate button and dismiss the popover.

@end
