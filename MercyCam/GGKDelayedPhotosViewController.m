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
- (void)handleViewDidDisappearFromUser {
    [super handleViewDidDisappearFromUser];
    [self.takePhotoModel stopOneSecondRepeatingTimer];
    // Will stop photo taking.
    self.takePhotoModel.mode = GGKTakePhotoModelModePlanning;
}
- (GGKTakePhotoModel *)makeTakePhotoModel {
    GGKDelayedPhotosModel *theDelayedPhotosModel = [[GGKDelayedPhotosModel alloc] init];
    return theDelayedPhotosModel;
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
- (void)updateTimerUI {
    [super updateTimerUI];
    self.numberOfSecondsWaitedLabel.text = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfSecondsWaitedInteger];
    [self.numberOfSecondsWaitedLabel setNeedsDisplay];
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
    NSArray *aLabelArray = @[self.numberOfPhotosTakenLabel, self.numberOfSecondsWaitedLabel];
    if (self.takePhotoModel.mode == GGKTakePhotoModelModePlanning) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = YES;
        }
        self.cancelTimerButton.enabled = NO;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = YES;
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
        for (UILabel *aLabel in aLabelArray) {
            aLabel.hidden = NO;
            aLabel.text = @"0";
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delayedPhotosModel = (GGKDelayedPhotosModel *)self.takePhotoModel;
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
