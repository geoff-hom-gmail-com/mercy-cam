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

// The number of photos that have been taken since the user tapped "Start timer."
@property (nonatomic, assign) NSInteger numberOfPhotosTakenInteger;

// The number of seconds that have passed while waiting to take a photo. (Either an initial wait or between photos.)
@property (nonatomic, assign) NSInteger numberOfSecondsPassedInteger;

// The total number of seconds to wait before taking a photo. (Either an initial wait or between photos.)
@property (nonatomic, assign) NSInteger numberOfTotalSecondsToWaitInteger;

// This timer goes off each second, which conveniently serves two purposes. 1) The UI can be updated every second, so the user can get visual feedback. 2) We can track how many seconds have passed, to know when to take a photo.
// Need this property to invalidate the timer later.
@property (nonatomic, strong) NSTimer *oneSecondRepeatingTimer;

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
    
    // If all photos taken, stop.
    // Else, if the wait time between photos is 0, then take another photo right away.
    if (self.numberOfPhotosTakenInteger >= self.numberOfPhotosToTakeInteger) {
        
        [self updateToAllowStartTimer];
    } else if (self.numberOfTotalSecondsToWaitInteger == 0 && [self.oneSecondRepeatingTimer isValid]) {
        
        [self takePhoto];
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


- (void)handleOneSecondTimerFired
{
    self.numberOfSecondsPassedInteger += 1;
    
    [self updateTimerLabels];

    // do stuff if applicable
    // need to handle edge case: between timer = 0 (set no counters here, but if 0 after first photo in capture manager, take another photo?)
    
    // If enough time has passed, take a photo. Then set the counters for waiting between photos.
    if (self.numberOfSecondsPassedInteger == self.numberOfTotalSecondsToWaitInteger) {
        
        // If the first photo, then show the photos label and the between-photos label.
        if (self.numberOfPhotosTakenInteger == 0) {
            
            self.numberOfPhotosTakenLabel.hidden = NO;
            self.numberOfTimeUnitsWaitedBetweenPhotosLabel.hidden = NO;
            
            // The first time the between-photos label is shown, it should show 0. Subsequently, 0 will also be when the between-photos time for the previous photo has passed, and we want to show that value instead. So we'll initialize at 0 here, only.
            // If time is in seconds, then we don't need/want decimal precision.
            NSString *aString = (self.timeUnitBetweenPhotosTimeUnit == GGKTimeUnitSeconds) ? @"0" : @"0.0";
            self.numberOfTimeUnitsWaitedBetweenPhotosLabel.text = aString;
        }
        
        self.numberOfSecondsPassedInteger = 0;
        self.numberOfTotalSecondsToWaitInteger = self.numberOfTimeUnitsBetweenPhotosInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:self.timeUnitBetweenPhotosTimeUnit];
        
        // If the between-photos time to wait is 0, then we'll just keep taking photos, so we'll stop the timer.
//        if (self.numberOfTotalSecondsToWaitInteger == 0) {
//            
//            [self.oneSecondRepeatingTimer invalidate];
//            self.oneSecondRepeatingTimer = nil;
//        }
        
        // We'll take the photo last, in case there's something there that causes significant delay.
        [self takePhoto];
    }
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
        
        // "photo(s)."
        NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:self.numberOfPhotosToTakeInteger];
        self.afterNumberOfPhotosTextFieldLabel.text = [NSString stringWithFormat:@"%@ with", aPhotosString];
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
        GGKTimeUnit theCurrentTimeUnit = (theSender == self.timeUnitsToInitiallyWaitButton) ? self.timeUnitForTheInitialWaitTimeUnit : self.timeUnitBetweenPhotosTimeUnit;
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
    // Update UI.
    
    self.startTimerButton.enabled = NO;
    self.cancelTimerButton.enabled = YES;
    
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = NO;
    self.timeUnitsToInitiallyWaitButton.enabled = NO;
    self.numberOfPhotosToTakeTextField.enabled = NO;
    self.numberOfTimeUnitsBetweenPhotosTextField.enabled = NO;
    self.timeUnitsBetweenPhotosButton.enabled = NO;
    
    // Show initial-wait label. If time is in seconds, then we don't need/want decimal precision.
    NSString *aString = (self.timeUnitForTheInitialWaitTimeUnit == GGKTimeUnitSeconds) ? @"0" : @"0.0";
    self.numberOfTimeUnitsInitiallyWaitedLabel.text = aString;
    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = NO;
    
    // Show countdown label.
    NSInteger theNumberOfSecondsToInitiallyWait = self.numberOfTimeUnitsToInitiallyWaitInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:self.timeUnitForTheInitialWaitTimeUnit];
    aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsToInitiallyWait];
    self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
    self.timeRemainingUntilNextPhotoLabel.hidden = NO;
    
    self.numberOfPhotosTakenInteger = 0;
    self.numberOfTotalSecondsToWaitInteger = theNumberOfSecondsToInitiallyWait;
    self.numberOfSecondsPassedInteger = 0;
    
    // Start the timer.
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleOneSecondTimerFired) userInfo:nil repeats:YES];
    self.oneSecondRepeatingTimer = aTimer;
}

// Override. 
- (void)takePhoto
{
    self.numberOfPhotosTakenInteger += 1;
    self.numberOfPhotosTakenLabel.text = [NSString stringWithFormat:@"%d", self.numberOfPhotosTakenInteger];
    
    [super takePhoto];
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{    
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
    
    NSString *theKey = (self.currentPopoverButton == self.timeUnitsToInitiallyWaitButton) ? self.timeUnitForInitialWaitKeyString : self.timeUnitBetweenPhotosKeyString;
    
    // Set the new value, then update the entire UI.
    [[NSUserDefaults standardUserDefaults] setInteger:anOkayInteger forKey:theKey];
    [self getSavedTimerSettings];
    
    [self.currentPopoverController dismissPopoverAnimated:YES];
}

- (void)updateTimerLabels
{
    // Countdown label.
    // Time-to-wait may be 0, in which time passed will be greater.
    NSInteger theNumberOfSecondsUntilNextPhotoInteger = MAX(self.numberOfTotalSecondsToWaitInteger, self.numberOfSecondsPassedInteger) - self.numberOfSecondsPassedInteger;
    NSString *aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsUntilNextPhotoInteger];
    self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
    
    // Either initial-wait counter or between-photos counter.
    if (self.numberOfPhotosTakenInteger == 0) {
        
        NSString *aString;
        if (self.timeUnitForTheInitialWaitTimeUnit == GGKTimeUnitSeconds) {
            
            aString = [NSString stringWithFormat:@"%d", self.numberOfSecondsPassedInteger];
        } else {
            
            CGFloat theNumberOfTimeUnitsPassedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.numberOfSecondsPassedInteger timeUnit:self.timeUnitForTheInitialWaitTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsPassedFloat];
        }
        self.numberOfTimeUnitsInitiallyWaitedLabel.text = aString;
    } else {
        
        // what if it's set to wait 0 seconds between photos?
        NSString *aString;
        if (self.timeUnitBetweenPhotosTimeUnit == GGKTimeUnitSeconds) {
            
            aString = [NSString stringWithFormat:@"%d", self.numberOfSecondsPassedInteger];
        } else {
            
            CGFloat theNumberOfTimeUnitsPassedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.numberOfSecondsPassedInteger timeUnit:self.timeUnitBetweenPhotosTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsPassedFloat];
        }
        self.numberOfTimeUnitsWaitedBetweenPhotosLabel.text = aString;
    }
}

- (void)updateToAllowStartTimer
{
    self.startTimerButton.enabled = YES;
    self.cancelTimerButton.enabled = NO;
    
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = YES;
    self.timeUnitsToInitiallyWaitButton.enabled = YES;
    self.numberOfPhotosToTakeTextField.enabled = YES;
    self.numberOfTimeUnitsBetweenPhotosTextField.enabled = YES;
    self.timeUnitsBetweenPhotosButton.enabled = YES;
    
    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = YES;
    self.numberOfPhotosTakenLabel.hidden = YES;
    self.numberOfTimeUnitsWaitedBetweenPhotosLabel.hidden = YES;
    self.timeRemainingUntilNextPhotoLabel.hidden = YES;
    
    [self.oneSecondRepeatingTimer invalidate];
    self.oneSecondRepeatingTimer = nil;
    
    // Story: User set between-photo timer to 0, started timer, then stopped timer in the middle of taking photos. No more photos are taken. 
//    self.numberOfPhotosToTakeInteger = 0;
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
