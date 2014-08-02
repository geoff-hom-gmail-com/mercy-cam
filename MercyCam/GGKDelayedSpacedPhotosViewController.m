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
- (void)getSavedTimerSettings {
//    [super getSavedTimerSettings];
}
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
//    NSArray *aTextFieldArray = @[self.numberOfPhotosToTakeTextField, self.numberOfSecondsToWaitTextField];
//    if (self.model.appMode == GGKAppModePlanning) {
//        for (UIButton *aButton in aTriggerButtonArray) {
//            aButton.enabled = YES;
//        }
//        self.cancelTimerButton.enabled = NO;
//        for (UITextField *aTextField in aTextFieldArray) {
//            aTextField.enabled = YES;
//        }
//        self.numberOfSecondsWaitedLabel.hidden = YES;
//        self.numberOfPhotosTakenLabel.hidden = YES;
//    } else if (self.model.appMode == GGKAppModeShooting) {
//        for (UIButton *aButton in aTriggerButtonArray) {
//            aButton.enabled = NO;
//        }
//        self.cancelTimerButton.enabled = YES;
//        for (UITextField *aTextField in aTextFieldArray) {
//            aTextField.enabled = NO;
//        }
//        self.numberOfSecondsWaitedLabel.hidden = NO;
//        self.numberOfSecondsWaitedLabel.text = @"0";
//        self.numberOfPhotosTakenLabel.hidden = NO;
//        self.numberOfPhotosTakenLabel.text = @"";
//    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delayedSpacedPhotosModel = [[GGKDelayedSpacedPhotosModel alloc] init];
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
