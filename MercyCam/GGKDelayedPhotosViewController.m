//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKDelayedPhotosViewController.h"

#import "GGKDelayedPhotosModel.h"
#import "GGKMercyCamAppDelegate.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"
#import "UIView+GGKAdditions.h"

@implementation GGKDelayedPhotosViewController
//- (IBAction)handleCancelTimerTapped {
//    [self stopOneSecondRepeatingTimer];
//    self.model.appMode = GGKAppModePlanning;
//    [self updateUI];
//}



// Override.
- (NSInteger)numberOfSecondsToWaitInteger {
    return self.delayedPhotosModel.numberOfSecondsToWaitInteger;
}
// Override.
- (BOOL)timerIsNeeded {
    BOOL theTimerIsNeeded = NO;
    if (self.delayedPhotosModel.numberOfSecondsToWaitInteger > 0) {
        theTimerIsNeeded = YES;
    }
    return theTimerIsNeeded;
}
// Override.
- (void)updateTimerUI {
    [super updateTimerUI];
    self.numberOfSecondsWaitedLabel.text = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfSecondsWaitedInteger];
    [self.numberOfSecondsWaitedLabel setNeedsDisplay];
}

- (void)handleViewDidDisappearFromUser {
    [super handleViewDidDisappearFromUser];
    [self stopOneSecondRepeatingTimer];
    // Will stop photo taking.
    self.model.appMode = GGKAppModePlanning;
}
//- (void)stopOneSecondRepeatingTimer {
//    [self.delayedPhotosModel.oneSecondRepeatingTimer invalidate];
//    self.delayedPhotosModel.oneSecondRepeatingTimer = nil;
//}
- (void)takePhoto {
    [super takePhoto];
    self.takePhotoModel.numberOfPhotosTakenInteger++;
    NSInteger theNumberOfPhotosTakenInteger = self.takePhotoModel.numberOfPhotosTakenInteger;
    self.numberOfPhotosTakenLabel.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfPhotosTakenInteger];
    [self.numberOfPhotosTakenLabel setNeedsDisplay];
}
- (void)takePhotoModelDidTakePhoto:(id)sender {
    [super takePhotoModelDidTakePhoto:sender];
    // If all photos taken, stop. Else, if still in shooting mode, take another photo. So, we can stop photo taking by changing the mode.
    if (self.takePhotoModel.numberOfPhotosTakenInteger >= self.delayedPhotosModel.numberOfPhotosToTakeInteger) {
        self.model.appMode = GGKAppModePlanning;
        [self updateUI];
    } else if (self.model.appMode == GGKAppModeShooting) {
        [self takePhoto];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    // Ensure we have a valid value. Update model. Update view.
    NSInteger anOkayInteger;
    NSInteger theCurrentInteger = [theTextField.text integerValue];
    if (theTextField == self.numberOfSecondsToWaitTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:99];
        self.delayedPhotosModel.numberOfSecondsToWaitInteger = anOkayInteger;
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:1 maximum:99];
        self.delayedPhotosModel.numberOfPhotosToTakeInteger = anOkayInteger;
    }
    [self updateUI];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 212;
}
- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 70;
}
- (void)updateUI {
    [super updateUI];
    // "Wait X second(s), then take"
    NSInteger theNumberOfSecondsToWaitInteger = self.delayedPhotosModel.numberOfSecondsToWaitInteger;
    self.numberOfSecondsToWaitTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfSecondsToWaitInteger];
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theNumberOfSecondsToWaitInteger];
    self.secondsLabel.text = [NSString stringWithFormat:@"%@, then take", aSecondsString];
    //  "Y photo(s)."
    NSInteger theNumberOfPhotosToTakeInteger = self.delayedPhotosModel.numberOfPhotosToTakeInteger;
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfPhotosToTakeInteger];
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theNumberOfPhotosToTakeInteger];
    self.photosLabel.text = [NSString stringWithFormat:@"%@.", aPhotosString];
    // Update UI for current mode.
    NSArray *aTriggerButtonArray = @[self.bottomTriggerButton, self.leftTriggerButton, self.rightTriggerButton];
    NSArray *aTextFieldArray = @[self.numberOfPhotosToTakeTextField, self.numberOfSecondsToWaitTextField];
    if (self.model.appMode == GGKAppModePlanning) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = YES;
        }
        self.cancelTimerButton.enabled = NO;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = YES;
        }
        self.numberOfSecondsWaitedLabel.hidden = YES;
        self.numberOfPhotosTakenLabel.hidden = YES;
    } else if (self.model.appMode == GGKAppModeShooting) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = NO;
        }
        self.cancelTimerButton.enabled = YES;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = NO;
        }
        self.numberOfSecondsWaitedLabel.hidden = NO;
        self.numberOfSecondsWaitedLabel.text = @"0";
        self.numberOfPhotosTakenLabel.hidden = NO;
        self.numberOfPhotosTakenLabel.text = @"";
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    GGKMercyCamAppDelegate *theAppDelegate = (GGKMercyCamAppDelegate *)[UIApplication sharedApplication].delegate;
    self.delayedPhotosModel = theAppDelegate.delayedPhotosModel;
    self.model.appMode = GGKAppModePlanning;
    // Orientation-specific layout constraints.
    self.portraitOnlyLayoutConstraintArray = @[self.proxyRightTriggerButtonTopGapPortraitLayoutConstraint, self.tipLabelRightGapPortraitLayoutConstraint];
    // Proxy right button's top neighbor: top layout guide.
    NSDictionary *aDictionary = @{@"topGuide":self.topLayoutGuide, @"rightProxy":self.proxyRightTriggerButton, @"tipLabel":self.tipLabel};
    NSArray *anArray1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[rightProxy]" options:0 metrics:nil views:aDictionary];
    // Tip label's right neighbor: right proxy button.
    NSArray *anArray2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[tipLabel]-[rightProxy]" options:0 metrics:nil views:aDictionary];
    self.landscapeOnlyLayoutConstraintArray = @[anArray1[0], anArray2[0]];
}
@end
