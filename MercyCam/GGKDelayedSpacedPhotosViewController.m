//
//  GGKTakeAdvancedDelayedPhotosViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKDelayedSpacedPhotosViewController.h"

#import "GGKDelayedSpacedPhotosModel.h"
#import "GGKUtilities.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger = 5;
const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger = 7;
const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger = 10;
const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit = GGKTimeUnitSeconds;
const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit = GGKTimeUnitSeconds;

//NSString *GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString = @"Take advanced delayed photos: number of photos.";
//NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString = @"Take advanced delayed photos: number of time units between photos.";
//NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString = @"Take advanced delayed photos: number of time units to initially wait.";
//NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString = @"Take advanced delayed photos: time unit to use between photos.";
//NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString = @"Take advanced delayed photos: time unit to use to initially wait.";

@implementation GGKDelayedSpacedPhotosViewController

// Override.
- (NSInteger)numberOfSecondsToWaitInteger {
    // well, if photos taken = 0, this is delay seconds
    // else, it's the space time
    return self.delayedPhotosModel.numberOfSecondsToWaitInteger;
}

- (void)handleOneSecondTimerFired {
    
    NSInteger theNumberOfSecondsWaitedInteger = self.takePhotoModel.numberOfSecondsWaitedInteger;
    NSInteger theNumberOfSecondsToWaitInteger;
//    theNumberOfSecondsToWaitInteger = self.delayedPhotosModel.numberOfSecondsToWaitInteger
    //    theNumberOfSecondsToWaitInteger = self.takePhotosModel.numberOfSecondsToWaitInteger
    theNumberOfSecondsToWaitInteger = // either delay time or space time
    if (theNumberOfSecondsWaitedInteger == theNumberOfSecondsToWaitInteger) {
        <#statements#>
    }
    //
    
    NSInteger theNumberOfSecondsWaitedInteger = self.takePhotoModel.numberOfSecondsWaitedInteger;
    self.numberOfSecondsWaitedLabel.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfSecondsWaitedInteger];
    [self.numberOfSecondsWaitedLabel setNeedsDisplay];
    }
}

//- (void)handleOneSecondTimerFired {
//    self.numberOfSecondsPassedInteger += 1;
//    [self updateTimerLabels];
//    // If enough time has passed, take a photo. Then set the counters for waiting between photos.
//    // Note that using == instead of >= works properly if seconds-to-wait is 0, as it skips taking a photo here (and takes it instead after the capture manager returns).
//    if (self.numberOfSecondsPassedInteger == self.numberOfTotalSecondsToWaitInteger) {
//
//        // If the first photo, then show the photos label and the between-photos label.
//        if (self.numberOfPhotosTakenInteger == 0) {
//
//            self.numberOfPhotosTakenLabel.hidden = NO;
//            self.numberOfTimeUnitsWaitedBetweenPhotosLabel.hidden = NO;
//
//            // The first time the between-photos label is shown, it should show 0. Subsequently, 0 will also be when the between-photos time for the previous photo has passed, and we want to show that value instead. So we'll initialize at 0 here, only.
//            // If time is in seconds, then we don't need/want decimal precision.
//            NSString *aString = (self.timeUnitBetweenPhotosTimeUnit == GGKTimeUnitSeconds) ? @"0" : @"0.0";
//            self.numberOfTimeUnitsWaitedBetweenPhotosLabel.text = aString;
//        }
//
//        self.numberOfSecondsPassedInteger = 0;
//        self.numberOfTotalSecondsToWaitInteger = self.numberOfTimeUnitsBetweenPhotosInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:self.timeUnitBetweenPhotosTimeUnit];
//
//        // We'll take the photo last, in case there's something there that causes significant delay.
//        [self takePhoto];
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender {
    if ([theSegue.identifier hasPrefix:@"ShowTimeUnitsSelector"]) {
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)self.currentPopoverController.contentViewController;
        aTimeUnitsTableViewController.delegate = self;
        // Set the current time unit.
        GGKTimeUnit theCurrentTimeUnit;
        if (theSender == self.timeUnitToDelayButton) {
            theCurrentTimeUnit = self.delayedSpacedPhotosModel.delayTimeUnit;
        } else if (theSender == self.timeUnitToSpaceButton) {
            theCurrentTimeUnit = self.delayedSpacedPhotosModel.spaceTimeUnit;
        }
        aTimeUnitsTableViewController.currentTimeUnit = theCurrentTimeUnit;
        // Note which button was tapped, to update later.
        self.currentPopoverButton = theSender;
    } else {
        [super prepareForSegue:theSegue sender:theSender];
    }
}
- (void)takePhotoModelDidTakePhoto:(id)sender {
    [super takePhotoModelDidTakePhoto:sender];
    // If all photos taken, stop. Else, if still in shooting mode, take another photo. So, we can stop photo taking by changing the mode.
    if (self.takePhotoModel.numberOfPhotosTakenInteger >= self.delayedSpacedPhotosModel.numberOfPhotosToTakeInteger) {
        self.model.appMode = GGKAppModePlanning;
        [self updateUI];
    } else if (self.model.appMode == GGKAppModeShooting) {
        [self takePhoto];
    }
}

- (void)takePhotoModelWillTakePhoto:(id)sender {
    [super takePhotoModelWillTakePhoto:sender];
    self.numberOfPhotosTakenLabel.text = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfPhotosTakenInteger];
    [self.numberOfPhotosTakenLabel setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    // Ensure we have a valid value. Update model. Update view.
    NSInteger anOkayInteger;
    NSInteger theCurrentInteger = [theTextField.text integerValue];
    if (theTextField == self.numberOfTimeUnitsToDelayTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:999];
        self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger = anOkayInteger;
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:1 maximum:999];
        self.delayedSpacedPhotosModel.numberOfPhotosToTakeInteger = anOkayInteger;
    } else if (theTextField == self.numberOfTimeUnitsToSpaceTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:999];
        self.delayedSpacedPhotosModel.numberOfTimeUnitsToSpaceInteger = anOkayInteger;
    }
    [self updateUI];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender {
    // Set time unit.
    GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)sender;
    GGKTimeUnit theCurrentTimeUnit = aTimeUnitsTableViewController.currentTimeUnit;
    if (self.currentPopoverButton == self.timeUnitToDelayButton) {
        self.delayedSpacedPhotosModel.delayTimeUnit = theCurrentTimeUnit;
    } else if (self.currentPopoverButton == self.timeUnitToSpaceButton) {
        self.delayedSpacedPhotosModel.spaceTimeUnit = theCurrentTimeUnit;
    }
    [self updateUI];
    [self.currentPopoverController dismissPopoverAnimated:YES];
}
- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    self.cancelTimerButtonWidthLayoutConstraint.constant = 174;
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 217;
}
- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    self.cancelTimerButtonWidthLayoutConstraint.constant = 66;
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 80;
}
- (void)updateTimerUI {
    [super updateTimerUI];
    NSString *aString;
    // It's usually space waited, unless 0 photos taken and delay > 0.
    if (self.takePhotoModel.numberOfPhotosTakenInteger == 0 && self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger > 0) {
        if (self.delayedSpacedPhotosModel.delayTimeUnit == GGKTimeUnitSeconds) {
            aString = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfSecondsWaitedInteger];
        } else {
            CGFloat theNumberOfTimeUnitsWaitedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.takePhotoModel.numberOfSecondsWaitedInteger timeUnit:self.delayedSpacedPhotosModel.delayTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsWaitedFloat];
        }
        self.numberOfTimeUnitsDelayedLabel.text = aString;
    } else {
        if (self.delayedSpacedPhotosModel.spaceTimeUnit == GGKTimeUnitSeconds) {
            aString = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfSecondsWaitedInteger];
        } else {
            CGFloat theNumberOfTimeUnitsWaitedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.takePhotoModel.numberOfSecondsWaitedInteger timeUnit:self.delayedSpacedPhotosModel.spaceTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsWaitedFloat];
        }
        self.numberOfTimeUnitsSpacedLabel.text = aString;
    }
    // Countdown label.
    // Time-to-wait may be 0, in which time passed will be greater.
    NSInteger theNumberOfSecondsUntilNextPhotoInteger = MAX([self.takePhotoModel numberOfSecondsToWaitInteger], self.takePhotoModel.numberOfSecondsWaitedInteger) - self.takePhotoModel.numberOfSecondsWaitedInteger;
    NSString *aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsUntilNextPhotoInteger];
    self.timeUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
}
- (void)updateUI {
    [super updateUI];
    // Wait __, then take"
    NSInteger theNumberOfTimeUnitsToDelayInteger = self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger;
    self.numberOfTimeUnitsToDelayTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfTimeUnitsToDelayInteger];
    [GGKTimeUnits setTitleForButton:self.timeUnitToDelayButton withTimeUnit:self.delayedSpacedPhotosModel.delayTimeUnit ofPlurality:self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger];
    // "__ photos, with"
    NSInteger theNumberOfPhotosToTakeInteger = self.delayedSpacedPhotosModel.numberOfPhotosToTakeInteger;
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfPhotosToTakeInteger];
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theNumberOfPhotosToTakeInteger];
    self.photosLabel.text = [NSString stringWithFormat:@"%@ with", aPhotosString];
    // "__ between each photo."
    NSInteger theNumberOfTimeUnitsToSpaceInteger = self.delayedSpacedPhotosModel.numberOfTimeUnitsToSpaceInteger;
    self.numberOfTimeUnitsToSpaceTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfTimeUnitsToSpaceInteger];
    [GGKTimeUnits setTitleForButton:self.timeUnitToSpaceButton withTimeUnit:self.delayedSpacedPhotosModel.spaceTimeUnit ofPlurality:self.delayedSpacedPhotosModel.numberOfTimeUnitsToSpaceInteger];
    // Update UI for current mode.
    NSArray *aTriggerButtonArray = @[self.bottomTriggerButton, self.leftTriggerButton, self.rightTriggerButton];
    NSArray *aTextFieldArray = @[self.numberOfPhotosToTakeTextField, self.numberOfTimeUnitsToDelayTextField, self.numberOfTimeUnitsToSpaceTextField];
    NSArray *aTimeUnitButtonArray = @[self.timeUnitToDelayButton, self.timeUnitToSpaceButton];
    NSArray *aLabelArray = @[self.numberOfPhotosTakenLabel, self.numberOfTimeUnitsDelayedLabel, self.numberOfTimeUnitsSpacedLabel, self.timeUntilNextPhotoLabel];
    if (self.takePhotoModel.mode == GGKTakePhotoModelModePlanning) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = YES;
        }
        self.cancelTimerButton.enabled = NO;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = YES;
        }
        for (UIButton *aButton in aTimeUnitButtonArray) {
            aButton.enabled = YES;
        }
        for (UILabel *aLabel in aLabelArray) {
            aLabel.hidden = YES;
        }
    } else if (self.takePhotoModel.mode == GGKTakePhotoModelModeShooting) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = NO;
        }
        self.cancelTimerButton.enabled = YES;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = NO;
        }
        for (UIButton *aButton in aTimeUnitButtonArray) {
            aButton.enabled = NO;
        }
        for (UILabel *aLabel in aLabelArray) {
            aLabel.hidden = NO;
        }
        self.numberOfTimeUnitsDelayedLabel.text = @"0";
        self.numberOfPhotosTakenLabel.text = @"0";
        self.numberOfTimeUnitsSpacedLabel.text = @"0";
        self.timeUntilNextPhotoLabel.text = @"Next photo:";
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delayedSpacedPhotosModel = (GGKDelayedSpacedPhotosModel *)self.takePhotoModel;
    // Orientation-specific layout constraints.
    self.portraitOnlyLayoutConstraintArray = @[self.cameraRollButtonTopGapPortraitLayoutConstraint, self.timerSettingsViewLeftGapPortraitLayoutConstraint];
    // Camera roll's top neighbor: top layout guide.
    NSDictionary *aDictionary = @{@"topGuide":self.topLayoutGuide, @"cameraRollButton":self.cameraRollButton, @"timerSettingsView":self.timerSettingsView};
    NSArray *anArray1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[cameraRollButton]" options:0 metrics:nil views:aDictionary];
    // Camera roll's right neighbor: timer-settings view.
    NSArray *anArray2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[cameraRollButton]-[timerSettingsView]" options:0 metrics:nil views:aDictionary];
    self.landscapeOnlyLayoutConstraintArray = @[anArray1[0], anArray2[0]];
}
@end
