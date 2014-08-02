//
//  GGKTakeAdvancedDelayedPhotosViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKAbstractPhotoViewController.h"
#import "GGKTimeUnitsTableViewController.h"

@class GGKDelayedSpacedPhotosModel;

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
//extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString;
//// Key for storing the number of time units between each photo.
//extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString;
//// Key for storing the number of time units to initially wait.
//extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString;
//// Key for storing the time unit to use between each photo.
//extern NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString;
//// Key for storing the time unit to use for the initial wait.
//extern NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString;

@interface GGKDelayedSpacedPhotosViewController : GGKAbstractPhotoViewController <GGKTimeUnitsTableViewControllerDelegate, UITextFieldDelegate>
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraRollButtonTopGapPortraitLayoutConstraint;
// Width depends on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelTimerButtonWidthLayoutConstraint;
// User taps button. Popover appears. She selects item in popover and sees updated button.
// Button displaying the popover.
@property (nonatomic, strong) UIButton *currentPopoverButton;
@property (strong, nonatomic) GGKDelayedSpacedPhotosModel *delayedSpacedPhotosModel;
// User taps trigger button. The number in the text field is how many photos are taken.
@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;
// Number of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToDelayTextField;
// Number of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToSpaceTextField;
// In "Wait __, then take __ photo(s)," it's "photo(s)."
// Story: User sets number of photos. User may see "photo" or "photos."
@property (weak, nonatomic) IBOutlet UILabel *photosLabel;
// Width depends on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyRightTriggerButtonWidthLayoutConstraint;
// User taps button. She can select seconds/minutes/hours/days/etc. from a popover. She taps selection and  button is updated.
// User sets number of time units to 1. She sees singular text for that time unit.
// The type of time unit to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitToDelayButton;
// User taps button. She can select seconds/minutes/hours/days/etc. from a popover. She taps selection and  button is updated.
// User sets number of time units to 1. She sees singular text for that time unit.
// The type of time unit to wait between each photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitToSpaceButton;
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerSettingsViewLeftGapPortraitLayoutConstraint;
// Override.
// Now that we can: Update timer labels. If enough time has passed, take a photo.
- (void)handleOneSecondTimerFired;
// Called after user taps a start-timer button.
// What: Either start taking photos or start timer to wait.
- (IBAction)handleTriggerButtonTapped:(id)sender;
// Override.
// Prepare for time-unit selector.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
// Override.
// Now that we can: If all photos taken, stop. Else, if spacing time is 0, take another photo.
- (void)takePhotoModelDidTakePhoto:(id)sender;
// Now that we can: Ensure we have a valid value.
- (void)textFieldDidEndEditing:(UITextField *)textField;
// Now that we can: Dismiss the keyboard.
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// Set the selected time unit, update UI and dismiss popover.
- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// Override.
- (void)updateLayoutForLandscape;
// Override.
- (void)updateLayoutForPortrait;
// Override.
- (void)viewDidLoad;
@end
