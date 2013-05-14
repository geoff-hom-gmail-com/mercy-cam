//
//  GGKTakeDelayedPhotosAbstractViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// Abstract class for taking delayed photos. It should include most of what you need. Subclasses should work by blanking out features rather than adding them, so add new features here. 

#import "GGKTakePhotoAbstractViewController.h"
#import "GGKTimeUnits.h"
#import "GGKTimeUnitsTableViewController.h"

extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger;

extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger;

extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger;

// For KVO on that property.
extern NSString *GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString;

// For KVO on that property.
extern NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString;

// For KVO on that property.
extern NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString;

// For KVO on that property.
extern NSString *GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString;

// For KVO on that property.
extern NSString *GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString;

@interface GGKTakeDelayedPhotosAbstractViewController : GGKTakePhotoAbstractViewController <GGKTimeUnitsTableViewControllerDelegate, UITextFieldDelegate>

// Story: User sets number of photos to 1. User sees "1 photo…" instead of "1 photos…."
// The label following the number-of-photos-to-take text field.
@property (weak, nonatomic) IBOutlet UILabel *afterNumberOfPhotosTextFieldLabel;

// Tap to cancel the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *cancelTimerButton;

// For displaying when the focus is continuous or locked. (Displays "locked" only when both focus and exposure are locked. Otherwise, displays "continuous" or "locking.")
@property (nonatomic, strong) IBOutlet UILabel *focusLabel;

// Timer to wait before the first photo is taken.
// Story: User taps cancel. No more photos taken.
@property (nonatomic, strong) NSTimer *initialWaitTimer;

// Story: User enters a value greater than the max. The value is replaced with the max.
// The max is arbitrary and for cosmetic reasons and keeping edge cases simple.
@property (nonatomic, assign) NSInteger maximumNumberOfPhotosInteger;

// Story: User enters a value greater than the max. The value is replaced with the max.
// The max is arbitrary and for cosmetic reasons and keeping edge cases simple.
@property (nonatomic, assign) NSInteger maximumNumberOfTimeUnitsBetweenPhotosInteger;

// Story: User enters a value greater than the max. The value is replaced with the max.
// The max is arbitrary and for cosmetic reasons and keeping edge cases simple.
@property (nonatomic, assign) NSInteger maximumNumberOfTimeUnitsToInitiallyWaitInteger;

// The number of photos remaining to take.
@property (nonatomic, assign) NSInteger numberOfPhotosRemainingToTake;

// Story: User taps "Start timer." User sees label below appear and increment with each photo taken. User implicitly understands when photos are taken, how many photos remain, and how long it will take.
@property (nonatomic, weak) IBOutlet UILabel *numberOfPhotosTakenLabel;

// How many photos to have taken when all the timers are done.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) NSInteger numberOfPhotosToTakeInteger;

// The key (in user defaults) for the number of photos to take.
@property (nonatomic, strong) NSString *numberOfPhotosToTakeKeyString;

// Number of photos to take for a given tap of the shutter button.
@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;

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
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;

// Story: User taps "Start timer." Regardless of how long-term the timer parameters are, the user understands that the timer has started and is still working (because of the counter in seconds). She also understands when the next photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *timeRemainingUntilNextPhotoLabel;

// The time unit to use (seconds/minutes/etc.) for waiting between photos.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) GGKTimeUnit timeUnitBetweenPhotosTimeUnit;

// The time unit to use (seconds/minutes/etc.) for the initial wait.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) GGKTimeUnit timeUnitForTheInitialWaitTimeUnit;

// The key (in user defaults) for the time unit for waiting between photos.
@property (nonatomic, strong) NSString *timeUnitBetweenPhotosKeyString;

// The key (in user defaults) for the time unit for the initial wait.
@property (nonatomic, strong) NSString *timeUnitForInitialWaitKeyString;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units between photos to 1. User sees singular text for that time unit.
// The type of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsBetweenPhotosButton;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units to initially wait to 1. User sees singular text for that time unit.
// The type of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsToInitiallyWaitButton;


// Update UI to take photos again.
- (IBAction)cancelTimer;

// Override.
- (void)captureManagerDidTakePhoto:(id)sender;
// So, if no more photos to take, then reset the UI for starting the timer again.

// Override.
- (void)dealloc;

// Retrieve the timer settings from user defaults.
// Stub.
- (void)getSavedTimerSettings;

// Story: User starts timer and leaves. User returns and glances at the screen for only a second or two. User still gets feedback that the app is running properly.
// Stub.
- (void)handleUpdateUITimerFired;

// Override.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// Override.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

// Update UI to allow canceling. Start timer for updating UI.
// Partial stub: Subclasses should start timer for initial wait.
- (IBAction)startTimer;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
// So, note which text field is being edited. (To know whether to shift the screen up when the keyboard shows.)

- (void)textFieldDidEndEditing:(UITextField *)textField;
// So, if an invalid value was entered, then use the previous value. Also, note that no text field is being edited now.

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// So, dismiss the keyboard.

- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// So, store the selected time unit and dismiss the popover.

// Update the labels showing the timers counting up and down.
- (void)updateTimerLabels;

// Story: User sees UI and knows to wait for photos to be taken, or to tap "Cancel."
- (void)updateToAllowCancelTimer;

// Story: User sees UI and knows she can tap "Start timer."
- (void)updateToAllowStartTimer;

// Override.
- (void)viewDidLoad;



// Story: The initial wait time has passed. The app starts taking photos, respecting any between-photo settings.
- (void)handleInitialWaitDone;







@end
