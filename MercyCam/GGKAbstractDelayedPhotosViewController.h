//
//  GGKTakeDelayedPhotosAbstractViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// Abstract class for taking delayed photos. It should include most of what you need. Subclasses should work by blanking out features rather than adding them, so add new features here. 

// DEPRECATE?

#import "GGKAbstractPhotoViewController.h"
#import "GGKTimeUnits.h"
#import "GGKTimeUnitsTableViewController.h"

extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger;
extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger;
extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger;

// For KVO on that property.
extern NSString *GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString;
extern NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString;
extern NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString;
extern NSString *GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString;
extern NSString *GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString;

@interface GGKAbstractDelayedPhotosViewController : GGKAbstractPhotoViewController <GGKTimeUnitsTableViewControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

// Story: User sets number of photos to 1. User sees "1 photo…" instead of "1 photos…."
// The label following the number-of-photos-to-take text field.
@property (weak, nonatomic) IBOutlet UILabel *afterNumberOfPhotosTextFieldLabel;

// Tap to cancel the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *cancelTimerButton;

// Story: User enters a value greater than the max. The value is replaced with the max.
// The max is arbitrary and for cosmetic reasons and keeping edge cases simple.
@property (nonatomic, assign) NSInteger maximumNumberOfPhotosInteger;

// Story: User enters a value greater than the max. The value is replaced with the max.
// The max is arbitrary and for cosmetic reasons and keeping edge cases simple.
@property (nonatomic, assign) NSInteger maximumNumberOfTimeUnitsBetweenPhotosInteger;

// Story: User enters a value greater than the max. The value is replaced with the max.
// The max is arbitrary and for cosmetic reasons and keeping edge cases simple.
@property (nonatomic, assign) NSInteger maximumNumberOfTimeUnitsToInitiallyWaitInteger;

//// Story: User taps "Start timer." User sees label below appear and increment with each photo taken. User implicitly understands when photos are taken, how many photos remain, and how long it will take.
//@property (nonatomic, weak) IBOutlet UILabel *numberOfPhotosTakenLabel;

// How many photos to have taken when all the timers are done.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) NSInteger numberOfPhotosToTakeInteger;

// The key (in user defaults) for the number of photos to take.
@property (nonatomic, strong) NSString *numberOfPhotosToTakeKeyString;

// Number of photos to take for a given tap of the shutter button.
//@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;

// How many seconds/minutes/etc. to wait between photos.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) NSInteger numberOfTimeUnitsBetweenPhotosInteger;

// The key (in user defaults) for the number of time units to wait between photos.
@property (nonatomic, strong) NSString *numberOfTimeUnitsBetweenPhotosKeyString;

// Number of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsBetweenPhotosTextField;

// Story: User taps "Start timer." After the first photo, user sees label below; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that another photo will be taken eventually and can estimate when that will be.
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsWaitedBetweenPhotosLabel;

// Story: User taps "Start timer." User sees label below; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that the timer has started and can estimate when the first photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsInitiallyWaitedLabel;

// How many seconds/minutes/etc. to wait between photos.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) NSInteger numberOfTimeUnitsToInitiallyWaitInteger;

// The key (in user defaults) for the number of time units to initially wait.
@property (nonatomic, strong) NSString *numberOfTimeUnitsToInitiallyWaitKeyString;

// Number of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToInitiallyWaitTextField;
// Tap to start the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *startTimerBottomButton;
// Button along left edge of screen. Created in code.
// We want vertical/rotated text, so the button is rotated via its transform property. Layout constraints won't work with rotated buttons. However, the storyboard has a proxy button that maintains the proper frame (via constraints).
@property (weak, nonatomic) UIButton *startTimerLeftButton;
// Gives frame for actual rotated button.
@property (weak, nonatomic) IBOutlet UIButton *startTimerLeftProxyButton;
// Button along right edge of screen. Created in code.
// We want vertical/rotated text, so the button is rotated via its transform property. Layout constraints won't work with rotated buttons. However, the storyboard has a proxy button that maintains the proper frame (via constraints).
@property (weak, nonatomic) UIButton *startTimerRightButton;
// Gives frame for actual rotated button.
@property (weak, nonatomic) IBOutlet UIButton *startTimerRightProxyButton;
// Story: User taps "Start timer." Regardless of how long-term the timer parameters are, the user understands that the timer has started and is still working (because of the counter in seconds). She also understands when the next photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *timeRemainingUntilNextPhotoLabel;

// The key (in user defaults) for the time unit for waiting between photos.
@property (nonatomic, strong) NSString *timeUnitBetweenPhotosKeyString;

// The time unit to use (seconds/minutes/etc.) for waiting between photos.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) GGKTimeUnit timeUnitBetweenPhotosTimeUnit;

// The key (in user defaults) for the time unit for the initial wait.
@property (nonatomic, strong) NSString *timeUnitForInitialWaitKeyString;

// The time unit to use (seconds/minutes/etc.) for the initial wait.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) GGKTimeUnit timeUnitForTheInitialWaitTimeUnit;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units between photos to 1. User sees singular text for that time unit.
// The type of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsBetweenPhotosButton;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units to initially wait to 1. User sees singular text for that time unit.
// The type of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsToInitiallyWaitButton;
// View showing the timer settings.
@property (weak, nonatomic) IBOutlet UIView *timerSettingsView;

// Override.
- (void)dealloc;

// One of our gesture recognizers is for taps but also allows them through. Allow that recognizer to work with other recognizers (e.g., the tap-to-focus recognizer).
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

// Retrieve the timer settings from user defaults.
// Stub.
- (void)getSavedTimerSettings;
// Override.
- (void)handleViewWillAppearToUser;
// Override.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// So, store the selected time unit and dismiss the popover.

// Update the labels showing the timers counting up and down.
- (void)updateTimerLabels;

// Override.
// Update things after constraints have been applied. (E.g., rotate buttons.)
- (void)viewDidLayoutSubviews;
// Override.
- (void)viewDidLoad;
@end
