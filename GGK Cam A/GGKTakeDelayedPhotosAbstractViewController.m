//
//  GGKTakeDelayedPhotosAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosAbstractViewController.h"

#import "NSDate+GGKAdditions.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger = 1;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger = 0;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger = 0;

NSString *GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString = @"numberOfPhotosToTakeInteger";

NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString = @"numberOfTimeUnitsBetweenPhotosInteger";

NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString = @"numberOfTimeUnitsToInitiallyWaitInteger";

NSString *GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString = @"timeUnitBetweenPhotosTimeUnit";

NSString *GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString = @"timeUnitForTheInitialWaitTimeUnit";

@interface GGKTakeDelayedPhotosAbstractViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// This timer goes off when an additional photo is to be taken. Need this property to invalidate later.
@property (nonatomic, strong) NSTimer *betweenPhotosTimer;

// Story: User taps button. Popover appears. User makes selection in popover. User sees updated button.
// The button the user tapped to display the popover.
@property (nonatomic, strong) UIButton *currentPopoverButton;

// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;


// The number of seconds that have passed while waiting to take a photo. (Either an initial wait or between photos.)
@property (nonatomic, assign) NSInteger numberOfSecondsPassedInteger;



// This timer goes off every second, so the user can get visual feedback. Need this property to invalidate later.
@property (nonatomic, strong) NSTimer *updateUITimer;

- (void)keyboardWillHide:(NSNotification *)theNotification;
// So, shift the view back to normal.

- (void)keyboardWillShow:(NSNotification *)theNotification;
// So, shift the view up, if necessary.

// Set the title for the given button to the given time unit, accounting for plurality (e.g., second(s)).
- (void)setTitleForButton:(UIButton *)theButton withTimeUnit:(GGKTimeUnit)theTimeUnit ofPlurality:(NSInteger)thePluralityInteger;

@end

@implementation GGKTakeDelayedPhotosAbstractViewController

- (IBAction)cancelTimer
{
    [self updateToAllowStartTimer];
}

- (void)captureManagerDidTakePhoto:(id)sender
{
    [super captureManagerDidTakePhoto:sender];
    
    if (self.numberOfPhotosRemainingToTake == 0) {
        
        [self updateToAllowStartTimer];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString];
    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString];
    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString];
    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString];
    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString];
}

- (void)getSavedTimerSettings
{
    // The order of retrieval is important, as the assigned properties may be under KVO and refer to one another. In particular, updating a time unit may update it's corresponding string. That string also depends on the number of time units.
    
    // Template for subclasses.
    //    self.numberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:AKey];
    //    self.timeUnitForTheInitialWaitTimeUnit
    //    self.numberOfPhotosToTakeInteger
    //    self.numberOfTimeUnitsBetweenPhotosInteger
    //    self.timeUnitBetweenPhotosTimeUnit
}

- (void)handleInitialWaitDone
{
    NSLog(@"handleInitialWaitDone");
    [self.initialWaitTimer invalidate];
    self.initialWaitTimer = nil;
    
    // well, we want to stop the initial-wait timer.
    // and take a photo
    // if there's a between-photos timer, start that
}

//- (void)handleOneSecondTimerFired
//{
//    NSNumber *theSecondsWaitedNumber = @([self.numberOfTimeUnitsInitiallyWaitedLabel.text integerValue] + 1);
//    self.numberOfTimeUnitsInitiallyWaitedLabel.text = [theSecondsWaitedNumber stringValue];
//    if ([theSecondsWaitedNumber floatValue] >= self.numberOfSecondsToInitiallyWait) {
//
//        [self.oneSecondRepeatingTimer invalidate];
//        self.oneSecondRepeatingTimer = nil;
//        [self startTakingPhotos];
//    }
//}


- (void)handleUpdateUITimerFired
{
    // increment stuff
    self.numberOfSecondsPassedInteger += 1;
//    self.numberOfSecondsUntilNextPhotoInteger -= 1;
//    self.numberOfPhotosRemainingToTake = ??;
    
    [self updateTimerLabels];
    // update UI
    
    
    
    // do stuff if applicable
    // if enough seconds and initial wait, then set counters for between-photo and take first photo (which will increment that label)
    // if enough seconds and between photos, then reset certain counters and take photo
    // need to handle edge case: between timer = 0 (set no counters here, but if 0 after first photo in capture manager, take another photo?)
    // after the first photo is taken, then the between-photo counters would be set
    
    
    
    
    
    // Initial wait: Show how many time units have passed.
    // what's the most robust way to tell whether we're between photos or initial wait?
    // 0 to x
    
    // if it's seconds, it shouldn't have a decimal (either initially or while counting)
    
    if (self.timeUnitForInitialWaitKeyString != nil) {
        
        CGFloat theNumberOfTimeUnitsPassedFloat;
        if (self.initialWaitTimer == nil) {
            
            NSInteger theNumberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
            theNumberOfTimeUnitsPassedFloat = theNumberOfTimeUnitsToInitiallyWaitInteger;
        } else {
            
            GGKTimeUnit theTimeUnitToInitiallyWait = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitForInitialWaitKeyString];
            NSInteger theNumberOfSecondsInTimeUnit = [GGKTimeUnits numberOfSecondsInTimeUnit:theTimeUnitToInitiallyWait];
            theNumberOfTimeUnitsPassedFloat = self.numberOfSecondsPassedInteger / theNumberOfSecondsInTimeUnit;
            
            //temp; testing
//            CGFloat aFloat = theNumberOfTimeUnitsAlreadyWaitedFloat;
            
            // Truncate to nearest decimal. 
            theNumberOfTimeUnitsPassedFloat = floorf(theNumberOfTimeUnitsPassedFloat * 10) / 10;
//            NSLog(@"test1: unitsWaited:%f, unitsWaitedPreRound:%f, secRemain:%f", theNumberOfTimeUnitsAlreadyWaitedFloat, aFloat, theNumberOfSecondsRemainingFloat);
        }
        self.numberOfTimeUnitsInitiallyWaitedLabel.text = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsPassedFloat];
    }
    
    // updates between-photos label, if timer exists (only for adv photos)
    // 0 to y, then repeat
    
    
    // Between photos: Show how many time units have passed.
}

- (void)keyboardWillHide:(NSNotification *)theNotification {
	
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = 0;
    
    NSDictionary* theUserInfo = [theNotification userInfo];
    NSTimeInterval keyboardAnimationDurationTimeInterval = [ theUserInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue ];
    [UIView animateWithDuration:keyboardAnimationDurationTimeInterval animations:^{
        
        self.view.frame = newFrame;
    }];
}

- (void)keyboardWillShow:(NSNotification *)theNotification {
    
    // Shift the view so that the active text field can be seen above the keyboard. We do this by comparing where the keyboard will end up vs. where the text field is. If a shift is needed, we shift the entire view up, synced with the keyboard shifting into place.
    
    NSDictionary *theUserInfo = [theNotification userInfo];
    CGRect keyboardFrameEndRect = [theUserInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	keyboardFrameEndRect = [self.view convertRect:keyboardFrameEndRect fromView:nil];
    CGFloat keyboardTop = keyboardFrameEndRect.origin.y;
    CGFloat activeTextFieldBottom = CGRectGetMaxY(self.activeTextField.frame);
    CGFloat overlap = activeTextFieldBottom - keyboardTop;
    CGFloat margin = 10;
    CGFloat amountToShift = overlap + margin;
    if (amountToShift > 0) {
        
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = newFrame.origin.y - amountToShift;
        NSTimeInterval keyboardAnimationDurationTimeInterval = [ theUserInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue ];
        [UIView animateWithDuration:keyboardAnimationDurationTimeInterval animations:^{
            
            self.view.frame = newFrame;
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString]) {
        
        NSString *aString = @"";
        switch (self.captureManager.focusAndExposureStatus) {
                
            case GGKCaptureManagerFocusAndExposureStatusContinuous:
                aString = @"Continuous";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocking:
                aString = @"Locking…";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocked:
                aString = @"Locked";
                break;
                
            default:
                break;
        }
        self.focusLabel.text = [NSString stringWithFormat:@"Focus:\n  %@", aString];
    } else if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString]) {
        
        self.numberOfTimeUnitsToInitiallyWaitTextField.text = [NSString stringWithFormat:@"%d", self.numberOfTimeUnitsToInitiallyWaitInteger];
    } else if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString]) {
        
        [self setTitleForButton:self.timeUnitsToInitiallyWaitButton withTimeUnit:self.timeUnitForTheInitialWaitTimeUnit ofPlurality:self.numberOfTimeUnitsToInitiallyWaitInteger];
        
    } else if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString]) {
        
        self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%d", self.numberOfPhotosToTakeInteger];
        
        // do more here; check take del photos KVO
        WILO
        
    } else if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString]) {
        
        self.numberOfTimeUnitsBetweenPhotosTextField.text = [NSString stringWithFormat:@"%d", self.numberOfTimeUnitsBetweenPhotosInteger];
    } else if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString]) {
        
        [self setTitleForButton:self.timeUnitsBetweenPhotosButton withTimeUnit:self.timeUnitBetweenPhotosTimeUnit ofPlurality:self.numberOfTimeUnitsBetweenPhotosInteger];
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender {
    
    if ([theSegue.identifier hasPrefix:@"ShowTimeUnitsSelector"]) {
        
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        
        GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)self.currentPopoverController.contentViewController;
        aTimeUnitsTableViewController.delegate = self;
        
        // Set the current time unit.
        GGKTimeUnit theCurrentTimeUnit;
        if (theSender == self.timeUnitsToInitiallyWaitButton) {
            
            theCurrentTimeUnit = self.timeUnitForTheInitialWaitTimeUnit;
        } else {
            
            theCurrentTimeUnit = self.timeUnitBetweenPhotosTimeUnit;
        }
        aTimeUnitsTableViewController.currentTimeUnit = theCurrentTimeUnit;
        
        // Note which button was tapped, to update later.
        self.currentPopoverButton = theSender;
    }
}

- (void)setTitleForButton:(UIButton *)theButton withTimeUnit:(GGKTimeUnit)theTimeUnit ofPlurality:(NSInteger)thePluralityInteger
{
    NSString *theTimeUnitString = [GGKTimeUnits stringForTimeUnit:theTimeUnit];
    theTimeUnitString = [theTimeUnitString ggk_stringPerhapsWithoutS:thePluralityInteger];
    [theButton setTitle:theTimeUnitString forState:UIControlStateNormal];
    [theButton setTitle:theTimeUnitString forState:UIControlStateDisabled];
}

- (IBAction)startTimer
{
    [self updateToAllowCancelTimer];
    
    if (self.numberOfTimeUnitsToInitiallyWaitKeyString != nil && self.timeUnitForInitialWaitKeyString != nil) {
        
        NSInteger theNumberOfTimeUnitsToInitiallyWait = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
        GGKTimeUnit theTimeUnitToInitiallyWait = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitForInitialWaitKeyString];
        NSInteger theNumberOfSecondsInTimeUnit = [GGKTimeUnits numberOfSecondsInTimeUnit:theTimeUnitToInitiallyWait];
        NSInteger theNumberOfSecondsToInitiallyWait = theNumberOfTimeUnitsToInitiallyWait * theNumberOfSecondsInTimeUnit;
        
        // Set countdown timer.
        NSString *aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsToInitiallyWait];
        self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
    }
    
    self.numberOfSecondsPassedInteger = 0;
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleUpdateUITimerFired) userInfo:nil repeats:YES];
    // rename to oneSecondTimer?
    self.updateUITimer = aTimer;
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
    
    self.activeTextField = theTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField
{    
    self.activeTextField = nil;
    
    // Behavior depends on which text field was edited.
    // Check the entered value. If not okay, set to an appropriate value. Store the value.
    
    NSInteger anOkayInteger = -1;
    NSString *theKey;
    
    NSInteger theCurrentInteger = [theTextField.text integerValue];
    if (theTextField == self.numberOfTimeUnitsToInitiallyWaitTextField) {
        
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger maximum:self.maximumNumberOfTimeUnitsToInitiallyWaitInteger];
        theKey = self.numberOfTimeUnitsToInitiallyWaitKeyString;
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger maximum:self.maximumNumberOfPhotosInteger];
        theKey = self.numberOfPhotosToTakeKeyString;
    } else if (theTextField == self.numberOfTimeUnitsBetweenPhotosTextField) {
        
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger maximum:self.maximumNumberOfTimeUnitsBetweenPhotosInteger];
        theKey = self.numberOfTimeUnitsBetweenPhotosKeyString;
    }
    
    // Set the new value, then update.
    [[NSUserDefaults standardUserDefaults] setInteger:anOkayInteger forKey:theKey];
    [self getSavedTimerSettings];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender
{
    // Store the time unit for the proper setting.
    
    GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)sender;
    GGKTimeUnit theCurrentTimeUnit = aTimeUnitsTableViewController.currentTimeUnit;
    NSInteger anOkayInteger = theCurrentTimeUnit;
    
    NSString *theKey;
    if (self.currentPopoverButton == self.timeUnitsToInitiallyWaitButton) {
        
        theKey = self.timeUnitForInitialWaitKeyString;
    } else if (self.currentPopoverButton == self.timeUnitsBetweenPhotosButton) {
        
        theKey = self.timeUnitBetweenPhotosKeyString;
    }
    
    // Set the new value, then update the entire UI.
    [[NSUserDefaults standardUserDefaults] setInteger:anOkayInteger forKey:theKey];
    [self getSavedTimerSettings];
    
    [self.currentPopoverController dismissPopoverAnimated:YES];
}

- (void)updateTimerLabels
{
//    // Countdown label: Update.
//    NSInteger theNumberOfSecondsUntilNextPhotoInteger = self.numberOfTotalSecondsToWaitInteger - self.numberOfSecondsPassedInteger;
//    NSString *aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsUntilNextPhotoInteger];
//    self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
//    
//    // Either initial-wait counter or between-photos counter: Update.
//    if (self.numberOfPhotosTakenInteger == 0) {
//        
//        if (self.timeUnitForInitialWaitKeyString != nil) {
//            
//            GGKTimeUnit theCurrentTimeUnit = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitForInitialWaitKeyString];
//            CGFloat theNumberOfTimeUnitsPassedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.numberOfSecondsPassedInteger timeUnit:theCurrentTimeUnit];
//            self.numberOfTimeUnitsInitiallyWaitedLabel.text = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsPassedFloat];
//        }
//    } else {
//        
//        if (self.timeUnitBetweenPhotosKeyString != nil) {
//            
//            GGKTimeUnit theCurrentTimeUnit = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitBetweenPhotosKeyString];
//            CGFloat theNumberOfTimeUnitsPassedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.numberOfSecondsPassedInteger timeUnit:theCurrentTimeUnit];
//            self.numberOfTimeUnitsWaitedBetweenPhotosLabel.text = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsPassedFloat];
//        }
//    }
}

- (void)updateToAllowCancelTimer
{
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = NO;
    self.numberOfPhotosToTakeTextField.enabled = NO;
    self.numberOfTimeUnitsBetweenPhotosTextField.enabled = NO;
    
    // Set initial value for label. "Seconds" doesn't need decimal precision.
    if (self.timeUnitForInitialWaitKeyString != nil) {
        
        NSString *aString;
        GGKTimeUnit theTimeUnitForInitialWait = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitForInitialWaitKeyString];
        if (theTimeUnitForInitialWait == GGKTimeUnitSeconds) {
            
            aString = @"0";
        } else {
            
            aString = @"0.0";
        }
        self.numberOfTimeUnitsInitiallyWaitedLabel.text = aString;
    }
    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = NO;
    
    self.timeRemainingUntilNextPhotoLabel.hidden = NO;
    
    self.startTimerButton.enabled = NO;
    self.cancelTimerButton.enabled = YES;    
}

- (void)updateToAllowStartTimer
{
    [self.updateUITimer invalidate];
    self.updateUITimer = nil;
    [self.initialWaitTimer invalidate];
    self.initialWaitTimer = nil;
    [self.betweenPhotosTimer invalidate];
    self.betweenPhotosTimer = nil;
    self.numberOfPhotosRemainingToTake = 0;
    
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = YES;
    self.numberOfPhotosToTakeTextField.enabled = YES;
    self.numberOfTimeUnitsBetweenPhotosTextField.enabled = YES;
    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = YES;
    self.numberOfPhotosTakenLabel.hidden = YES;
    self.numberOfTimeUnitsWaitedBetweenPhotosLabel.hidden = YES;
    
    self.timeRemainingUntilNextPhotoLabel.hidden = YES;
    
    self.startTimerButton.enabled = YES;
    self.cancelTimerButton.enabled = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Observe keyboard notifications to shift the screen up/down appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.maximumNumberOfTimeUnitsToInitiallyWaitInteger = 999;
    self.maximumNumberOfPhotosInteger = 999;
    self.maximumNumberOfTimeUnitsBetweenPhotosInteger = 999;

    [self updateToAllowStartTimer];
    
    // Observe changes to the timer settings.
    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    
    // Template for subclasses.
    
    // Set keys.

//    [self getSavedTimerSettings];
}

@end
