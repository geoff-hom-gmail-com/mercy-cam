//
//  GGKTakeDelayedPhotosAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosAbstractViewController.h"

#import "GGKTimeUnits.h"
#import "NSDate+GGKAdditions.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger = 1;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger = 0;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger = 0;

@interface GGKTakeDelayedPhotosAbstractViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// This timer goes off when an additional photo is to be taken. Need this property to invalidate later.
@property (nonatomic, strong) NSTimer *betweenPhotosTimer;

// This timer goes off every second, so the user can get visual feedback. Need this property to invalidate later.
@property (nonatomic, strong) NSTimer *updateUITimer;

- (void)keyboardWillHide:(NSNotification *)theNotification;
// So, shift the view back to normal.

- (void)keyboardWillShow:(NSNotification *)theNotification;
// So, shift the view up, if necessary.

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
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
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
    // Countdown timer: Update.
    NSTimer *theTimer;
    if (self.initialWaitTimer != nil) {
        
        theTimer = self.initialWaitTimer;
    } else if (self.betweenPhotosTimer != nil) {
        
        theTimer = self.betweenPhotosTimer;
    }
    NSTimeInterval theNumberOfSecondsRemainingTimeInterval = [theTimer.fireDate timeIntervalSinceNow];
    NSString *aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsRemainingTimeInterval];
    self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
    
    
    // update initial wait label, if timer exists
    // this updates as seconds for del photos
    // updates as decimal for adv photos
    // 0 to x
    
    // updates between-photos label, if timer exists (only for adv photos)
    // 0 to y, then repeat; can we query the timer? well we can get the next fire date and the interval date
    
    // do this only if the time unit key isn't nil?
    //WILO
    // Initial wait: Show how many time units have passed.
    NSInteger theNumberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
    CGFloat theNumberOfTimeUnitsAlreadyWaitedFloat;
    if (self.initialWaitTimer == nil) {
        
        theNumberOfTimeUnitsAlreadyWaitedFloat = theNumberOfTimeUnitsToInitiallyWaitInteger;
    } else {
        
        CGFloat theNumberOfSecondsRemainingFloat = [self.initialWaitTimer.fireDate timeIntervalSinceNow];
        CGFloat theNumberOfTimeUnitsRemainingFloat;
        
        GGKTimeUnit theTimeUnitToInitiallyWait = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitForInitialWaitKeyString];
        NSInteger theNumberOfSecondsInTimeUnit = [GGKTimeUnits numberOfSecondsInTimeUnit:theTimeUnitToInitiallyWait];
        
        theNumberOfTimeUnitsAlreadyWaitedFloat = theNumberOfTimeUnitsToInitiallyWaitInteger - theNumberOfTimeUnitsRemainingFloat;
    }
    self.numberOfTimeUnitsInitiallyWaitedLabel.text = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsAlreadyWaitedFloat];
    
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

- (IBAction)startTimer
{
    [self updateToAllowCancelTimer];
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleUpdateUITimerFired) userInfo:nil repeats:YES];
    self.updateUITimer = aTimer;
    
    if (self.numberOfTimeUnitsToInitiallyWaitKeyString != nil && self.timeUnitForInitialWaitKeyString != nil) {
        
        NSInteger theNumberOfTimeUnitsToInitiallyWait = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
        GGKTimeUnit theTimeUnitToInitiallyWait = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitForInitialWaitKeyString];
        NSInteger theNumberOfSecondsInTimeUnit = [GGKTimeUnits numberOfSecondsInTimeUnit:theTimeUnitToInitiallyWait];
        NSInteger theNumberOfSecondsToInitiallyWait = theNumberOfTimeUnitsToInitiallyWait * theNumberOfSecondsInTimeUnit;
        
        // Set countdown timer.
        NSString *aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsToInitiallyWait];
        self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
        
        aTimer = [NSTimer scheduledTimerWithTimeInterval:theNumberOfSecondsToInitiallyWait target:self selector:@selector(handleInitialWaitDone) userInfo:nil repeats:NO];
        self.initialWaitTimer = aTimer;
    }
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
        theKey = self.numberOfTimeUnitsToInitiallyWaitKeyString; ;
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger maximum:self.maximumNumberOfPhotosInteger];
        theKey = self.numberOfPhotosToTakeKeyString;
    } else if (theTextField == self.numberOfTimeUnitsBetweenPhotosTextField) {
        
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger maximum:self.maximumNumberOfTimeUnitsBetweenPhotosInteger];
        theKey = self.numberOfTimeUnitsBetweenPhotosKeyString;
    }
    
    // Set the new value, then update the entire UI.
    [[NSUserDefaults standardUserDefaults] setInteger:anOkayInteger forKey:theKey];
    [self updateSettings];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)updateSettings
{
    // In "Wait X hours," it's X.
    NSInteger theNumberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
    self.numberOfTimeUnitsToInitiallyWaitTextField.text = [NSString stringWithFormat:@"%d", theNumberOfTimeUnitsToInitiallyWaitInteger];
    
    // In "Wait X hours," it's hours/minutes/etc.
    if (self.timeUnitForInitialWaitKeyString != nil) {
        
        NSInteger theTimeUnitForTheInitialWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitForInitialWaitKeyString];
        NSString *theTimeUnitForTheInitialWaitString = [GGKTimeUnits stringForTimeUnit:(GGKTimeUnit)theTimeUnitForTheInitialWaitInteger];
        theTimeUnitForTheInitialWaitString = [theTimeUnitForTheInitialWaitString ggk_stringPerhapsWithoutS:theNumberOfTimeUnitsToInitiallyWaitInteger];
        [self.timeUnitsToInitiallyWaitButton setTitle:theTimeUnitForTheInitialWaitString forState:UIControlStateNormal];
        [self.timeUnitsToInitiallyWaitButton setTitle:theTimeUnitForTheInitialWaitString forState:UIControlStateDisabled];
    }
    
    // In "take Y photos," it's Y.
    NSInteger theNumberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfPhotosToTakeKeyString];
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%d", theNumberOfPhotosToTakeInteger];
    
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theNumberOfPhotosToTakeInteger];
    self.afterNumberOfPhotosTextFieldLabel.text = [NSString stringWithFormat:@"%@ with", aPhotosString];
    
    // In "with Z minutes between each photo," it's Z.
    if (self.numberOfTimeUnitsBetweenPhotosKeyString != nil) {
        
        NSInteger theNumberOfTimeUnitsBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsBetweenPhotosKeyString];
        self.numberOfTimeUnitsBetweenPhotosTextField.text = [NSString stringWithFormat:@"%d", theNumberOfTimeUnitsBetweenPhotosInteger];
        
        // In "with Z minutes between each photo," it's minutes/seconds/etc.
        if (self.timeUnitBetweenPhotosKeyString != nil) {
            
            NSInteger theTimeUnitBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.timeUnitBetweenPhotosKeyString];
            NSString *theTimeUnitBetweenPhotosString = [GGKTimeUnits stringForTimeUnit:(GGKTimeUnit)theTimeUnitBetweenPhotosInteger];
            theTimeUnitBetweenPhotosString = [theTimeUnitBetweenPhotosString ggk_stringPerhapsWithoutS:theNumberOfTimeUnitsBetweenPhotosInteger];
            [self.timeUnitsBetweenPhotosButton setTitle:theTimeUnitBetweenPhotosString forState:UIControlStateNormal];
            [self.timeUnitsBetweenPhotosButton setTitle:theTimeUnitBetweenPhotosString forState:UIControlStateDisabled];
        }
    }
}

- (void)updateToAllowCancelTimer
{
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = NO;
    self.numberOfPhotosToTakeTextField.enabled = NO;
    self.numberOfTimeUnitsBetweenPhotosTextField.enabled = NO;
    self.numberOfTimeUnitsInitiallyWaitedLabel.text = @"0.0";
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
    
    self.maximumNumberOfTimeUnitsToInitiallyWaitInteger = 999;
    self.maximumNumberOfPhotosInteger = 999;
    self.maximumNumberOfTimeUnitsBetweenPhotosInteger = 999;

    // Observe keyboard notifications to shift the screen up/down appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    [self updateToAllowStartTimer];
}

@end
