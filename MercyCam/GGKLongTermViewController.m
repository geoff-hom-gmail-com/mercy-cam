//
//  GGKLongTermViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/17/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKLongTermViewController.h"

#import "GGKLongTermModel.h"
#import "NSNumber+GGKAdditions.h"

@implementation GGKLongTermViewController
- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender {
    if ([theSegue.identifier hasPrefix:@"ShowTimeUnitsSelector"]) {
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)self.currentPopoverController.contentViewController;
        aTimeUnitsTableViewController.delegate = self;
        // Set the current time unit.
        aTimeUnitsTableViewController.currentTimeUnit = self.longTermModel.timeUnit;
    } else {
        [super prepareForSegue:theSegue sender:theSender];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    // Ensure we have a valid value. Update model. Update view.
    NSInteger anOkayInteger;
    NSInteger theCurrentInteger = [theTextField.text integerValue];
    if (theTextField == self.numberOfTimeUnitsToWaitTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:999];
        self.longTermModel.numberOfTimeUnitsToWaitInteger = anOkayInteger;
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
    self.longTermModel.timeUnit = aTimeUnitsTableViewController.currentTimeUnit;
    [self updateUI];
    [self.currentPopoverController dismissPopoverAnimated:YES];
}
- (void)updateUI {
    [super updateUI];
    NSInteger theNumberOfTimeUnitsToWaitInteger = self.longTermModel.numberOfTimeUnitsToWaitInteger;
    self.numberOfTimeUnitsToWaitTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfTimeUnitsToWaitInteger];
    [GGKTimeUnits setTitleForButton:self.timeUnitButton withTimeUnit:self.longTermModel.timeUnit ofPlurality:self.longTermModel.numberOfTimeUnitsToWaitInteger];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.longTermModel = [[GGKLongTermModel alloc] init];
    self.explanationView.layer.cornerRadius = 3.0f;
    self.timerSettingsView.layer.cornerRadius = 3.0f;
}
@end
