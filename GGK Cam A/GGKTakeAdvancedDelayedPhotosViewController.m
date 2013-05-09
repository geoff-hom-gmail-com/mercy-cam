//
//  GGKTakeAdvancedDelayedPhotosViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeAdvancedDelayedPhotosViewController.h"
#import "NSUserDefaults+GGKAdditions.h"

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger = 5;

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger = 7;

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger = 10;

const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit = GGKTimeUnitSeconds;

const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit = GGKTimeUnitSeconds;

NSString *GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString = @"Take advanced delayed photos: number of photos.";

NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString = @"Take advanced delayed photos: number of time units between photos.";

NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString = @"Take advanced delayed photos: number of time units to initially wait.";

NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString = @"Take advanced delayed photos: time unit to use between photos.";

NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString = @"Take advanced delayed photos: time unit to use to initially wait.";

@interface GGKTakeAdvancedDelayedPhotosViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// Story: User taps button. Popover appears. User makes selection in popover. User sees updated button.
// The button the user tapped to display the popover.
@property (nonatomic, strong) UIButton *currentPopoverButton;

// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;

- (void)keyboardWillHide:(NSNotification *)theNotification;
// So, shift the view back to normal.

- (void)keyboardWillShow:(NSNotification *)theNotification;
// So, shift the view up, if necessary.

// Override.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
// So, note which text field is being edited. (To know whether to shift the screen up when the keyboard shows.)

- (void)textFieldDidEndEditing:(UITextField *)textField;
// So, if an invalid value was entered, then use the previous value. Also, note that no text field is being edited now.

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// So, dismiss the keyboard.

// Story: User sees UI and knows to wait for photos to be taken, or to tap "Cancel."
- (void)updateForAllowingCancelTimer;

// Story: User sees UI and knows she can tap "Start timer."
- (void)updateForAllowingStartTimer;

// Set timer settings to those most-recently used.
- (void)updateSettings;

@end

@implementation GGKTakeAdvancedDelayedPhotosViewController

- (void)dealloc {
    
//    [self.captureManager.session stopRunning];
//    [self removeObserver:self forKeyPath:@"captureManager.focusAndExposureStatus"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    if ([theKeyPath isEqualToString:@"captureManager.focusAndExposureStatus"]) {
        
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

- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender {
    
    if ([theSegue.identifier isEqualToString:@"ShowTimeUnitsSelector1"] || [theSegue.identifier isEqualToString:@"ShowTimeUnitsSelector2"]) {
        
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        
        // Note which button was tapped, to update later.
        self.currentPopoverButton = theSender;
        
        GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)self.currentPopoverController.contentViewController;
        aTimeUnitsTableViewController.delegate = self;
        
        // Set current time unit.
        NSString *theCurrentTimeUnitString = [self.currentPopoverButton titleForState:UIControlStateNormal];
        aTimeUnitsTableViewController.currentTimeUnit = [GGKTimeUnitsTableViewController timeUnitForString:theCurrentTimeUnitString];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
    
    self.activeTextField = theTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    
    // Behavior depends on which text field was edited. Regardless, check the entered value. If not okay, set to an appropriate value. Store the value.
    
    NSString *theKey;
    id okayValue;
    
//    if (theTextField == self.numberOfSecondsToInitiallyWaitTextField) {
//        
//        theKey = GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;
//        okayValue = @([theTextField.text integerValue]);
//        
//        // The number of seconds to initially wait should be an integer, 0 to 99. If not, fix.
//        NSInteger okayValueInteger = [okayValue integerValue];
//        if (okayValueInteger < 0) {
//            
//            okayValue = @0;
//        } else if (okayValueInteger > 99) {
//            
//            okayValue = @99;
//        }
//    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
//        
//        theKey = GGKTakeDelayedPhotosNumberOfPhotosKeyString;
//        okayValue = @([theTextField.text integerValue]);
//        
//        // The number of photos should be from 1 to 99. If not, fix.
//        NSInteger okayValueInteger = [okayValue integerValue];
//        if (okayValueInteger < 1) {
//            
//            okayValue = @1;
//        } else if (okayValueInteger > 99) {
//            
//            okayValue = @99;
//        }
//    }
//    
//    // Since the entered value may have been converted, show the converted value.
//    theTextField.text = [okayValue stringValue];
//    
//    if (theTextField == self.numberOfSecondsToInitiallyWaitTextField || theTextField == self.numberOfPhotosToTakeTextField) {
//        
//        [self adjustStringsForPlurals];
//    }
//    
//    [[NSUserDefaults standardUserDefaults] setObject:okayValue forKey:theKey];
    
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender
{
    GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)sender;
    GGKTimeUnit theCurrentTimeUnit = aTimeUnitsTableViewController.currentTimeUnit;
    NSString *aTimeUnitsString = [GGKTimeUnitsTableViewController stringForTimeUnit:theCurrentTimeUnit];
    [self.currentPopoverButton setTitle:aTimeUnitsString forState:UIControlStateNormal];
    [self.currentPopoverButton setTitle:aTimeUnitsString forState:UIControlStateDisabled];

    [self.currentPopoverController dismissPopoverAnimated:YES];
}

- (void)updateForAllowingCancelTimer
{
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = NO;
    self.numberOfPhotosToTakeTextField.enabled = NO;
    self.numberOfTimeUnitsBetweenPhotosTextField.enabled = NO;
    self.numberOfTimeUnitsInitiallyWaitedLabel.text = @"0.0";
    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = NO;
    self.startTimerButton.enabled = NO;
    self.cancelTimerButton.enabled = YES;
}

- (void)updateForAllowingStartTimer
{
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

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
//    // The left margin.
//    CGFloat aMarginX1Float = 20;
//    
//    // The vertical gap between the end of one section and the start of another.
//    CGFloat theSectionGapFloat = 40;
//    
//    // The vertical gap between the end of one text and the start of another.
//    CGFloat theTextGapFloat = 30;
//    
//    // The vertical gap between a header and the next label.
//    CGFloat theHeaderGapFloat = 8;
//    
//    // First text for greeting. Centered horizontally.
//    CGSize aSize = self.greeting1Label.frame.size;
//    self.greeting1Label.frame = CGRectMake(153, theSectionGapFloat, aSize.width, aSize.height);
//    
//    // More text for the greeting.
//    CGRect aPreviousViewFrame = self.greeting1Label.frame;
//    CGFloat aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
//    aSize = self.greeting2Label.frame.size;
//    self.greeting2Label.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // More text for the greeting.
//    aPreviousViewFrame = self.greeting2Label.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
//    aSize = self.greeting3Label.frame.size;
//    self.greeting3Label.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // Header: "Rate us"
//    aPreviousViewFrame = self.greeting3Label.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGapFloat;
//    aSize = self.rateUsHeaderLabel.frame.size;
//    self.rateUsHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // Text for "Rate us"
//    aPreviousViewFrame = self.rateUsHeaderLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
//    aSize = self.rateUsTextLabel.frame.size;
//    self.rateUsTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // Button for "Rate us"
//    // The button should be at the end of the text. The button height is greater than the text, so we'll align the button top with the text top.
//    aPreviousViewFrame = self.rateUsTextLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y;
//    aSize = self.rateUsButton.frame.size;
//    self.rateUsButton.frame = CGRectMake(414, aYFloat, aSize.width, aSize.height);
//    
//    // Header: "Donate"
//    aPreviousViewFrame = self.rateUsTextLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGapFloat;
//    aSize = self.donateHeaderLabel.frame.size;
//    self.donateHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // First text for "Donate"
//    aPreviousViewFrame = self.donateHeaderLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
//    aSize = self.donateTextLabel.frame.size;
//    self.donateTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // More text for "Donate"
//    aPreviousViewFrame = self.donateTextLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
//    aSize = self.giveADollarLabel.frame.size;
//    self.giveADollarLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // Button for "Donate"
//    // The button should be at the end of the text. The button height is greater than the text, so we'll align the button top with the text top.
//    aPreviousViewFrame = self.giveADollarLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y;
//    aSize = self.giveADollarButton.frame.size;
//    self.giveADollarButton.frame = CGRectMake(469, aYFloat, aSize.width, aSize.height);
//    
//    // Stars for "Donate"
//    aPreviousViewFrame = self.giveADollarLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
//    aSize = self.starsLabel.frame.size;
//    self.starsLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // Header: "Give feedback"
//    aPreviousViewFrame = self.starsLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGapFloat;
//    aSize = self.giveFeedbackHeaderLabel.frame.size;
//    self.giveFeedbackHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // Text for "Give feedback"
//    aPreviousViewFrame = self.giveFeedbackHeaderLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
//    aSize = self.giveFeedbackTextLabel.frame.size;
//    self.giveFeedbackTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
//    
//    // Button for "Give feedback"
//    // Button bottom is aligned with text bottom.
//    aSize = self.emailTheCreatorsButton.frame.size;
//    aPreviousViewFrame = self.giveFeedbackTextLabel.frame;
//    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height - aSize.height;
//    self.emailTheCreatorsButton.frame = CGRectMake(446, aYFloat, aSize.width, aSize.height);
}

- (void)updateSettings
{
    NSInteger theNumberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger];
    self.numberOfTimeUnitsToInitiallyWaitTextField.text = [NSString stringWithFormat:@"%d", theNumberOfTimeUnitsToInitiallyWaitInteger];
    
    NSInteger theTimeUnitForTheInitialWaitInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit];
    NSString *theTimeUnitForTheInitialWaitString = [GGKTimeUnitsTableViewController stringForTimeUnit:(GGKTimeUnit)theTimeUnitForTheInitialWaitInteger];
    [self.timeUnitsToInitiallyWaitButton setTitle:theTimeUnitForTheInitialWaitString forState:UIControlStateNormal];
    [self.timeUnitsToInitiallyWaitButton setTitle:theTimeUnitForTheInitialWaitString forState:UIControlStateDisabled];
    
    NSInteger theNumberOfPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger];
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%d", theNumberOfPhotosInteger];
    
    // need to adjust photos plurality
    
    NSInteger theNumberOfTimeUnitsBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger];
    self.numberOfTimeUnitsBetweenPhotosTextField.text = [NSString stringWithFormat:@"%d", theNumberOfTimeUnitsBetweenPhotosInteger];
    
    NSInteger theTimeUnitBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit];
    NSString *theTimeUnitBetweenPhotosString = [GGKTimeUnitsTableViewController stringForTimeUnit:(GGKTimeUnit)theTimeUnitBetweenPhotosInteger];
    [self.timeUnitsBetweenPhotosButton setTitle:theTimeUnitBetweenPhotosString forState:UIControlStateNormal];
    [self.timeUnitsBetweenPhotosButton setTitle:theTimeUnitBetweenPhotosString forState:UIControlStateDisabled];        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Observe keyboard notifications to shift the screen up/down appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self updateSettings];
    
    [self updateForAllowingStartTimer];
}

@end
