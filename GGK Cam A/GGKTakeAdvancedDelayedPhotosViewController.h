//
//  GGKTakeAdvancedDelayedPhotosViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosAbstractViewController.h"
#import "GGKTimeUnits.h"
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

@interface GGKTakeAdvancedDelayedPhotosViewController : GGKTakeDelayedPhotosAbstractViewController <GGKTimeUnitsTableViewControllerDelegate, UITextFieldDelegate>

// Number of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsBetweenPhotosTextField;

// Story: User taps "Start timer." After the first photo, user sees label below; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that another photo will be taken eventually and can estimate when that will be.
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsWaitedBetweenPhotosLabel;

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

// Override.
- (void)captureManagerDidTakePhoto:(id)sender;
// If there is time set between photos, then those timers will handle taking more photos. But if the time between photos is set to 0, and if more photos should be taken, then do that.

// Override.
- (IBAction)startTimer;



// Override. For stopping the capture session. And removing observers.
- (void)dealloc;


- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// So, store the selected time unit and dismiss the popover.

// Override.
- (void)updateLayoutForLandscape;

// Override.
- (void)updateLayoutForPortrait;

// Override.
- (void)viewDidLoad;

@end
