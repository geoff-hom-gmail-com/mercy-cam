//
//  GGKLongTermViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/17/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKLongTermViewController.h"

#import "NSNumber+GGKAdditions.h"

const NSInteger GGKLongTermDefaultNumberOfTimeUnitsInteger = 2;

const GGKTimeUnit GGKLongTermDefaultTimeUnit = GGKTimeUnitHours;

const NSInteger GGKLongTermMaximumNumberOfTimeUnitsInteger = 999;

const NSInteger GGKLongTermMinimumNumberOfTimeUnitsInteger = 0;

NSString *GGKLongTermNumberOfTimeUnitsKeyPathString = @"numberOfTimeUnitsInteger";

NSString *GGKLongTermNumberOfTimeUnitsKeyString = @"Long-term: Number of time units.";

NSString *GGKLongTermTimeUnitKeyPathString = @"timeUnit";

NSString *GGKLongTermTimeUnitKeyString = @"Long-term: Time unit.";

@interface GGKLongTermViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;

// Retrieve the timer settings from user defaults.
- (void)getSavedTimerSettings;

@end

@implementation GGKLongTermViewController
- (void)dealloc {
    [self removeObserver:self forKeyPath:GGKLongTermNumberOfTimeUnitsKeyPathString];
    [self removeObserver:self forKeyPath:GGKLongTermTimeUnitKeyPathString];
}
- (void)getSavedTimerSettings
{
    // The order of retrieval is important, as the assigned properties may be under KVO and refer to one another. In particular, updating a time unit may update it's corresponding string. That string also depends on the number of time units.
    
    self.numberOfTimeUnitsInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermNumberOfTimeUnitsKeyString];
    self.timeUnit = (GGKTimeUnit)[[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermTimeUnitKeyString];
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:GGKLongTermNumberOfTimeUnitsKeyPathString]) {
        
        self.numberOfTimeUnitsTextField.text = [NSString stringWithFormat:@"%ld", (long)self.numberOfTimeUnitsInteger];
    } else if ([theKeyPath isEqualToString:GGKLongTermTimeUnitKeyPathString]) {
        
        [GGKTimeUnits setTitleForButton:self.timeUnitButton withTimeUnit:self.timeUnit ofPlurality:self.numberOfTimeUnitsInteger];
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
        aTimeUnitsTableViewController.currentTimeUnit = self.timeUnit;
    } else {
        
        [super prepareForSegue:theSegue sender:theSender];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
    self.activeTextField = theTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField
{
    self.activeTextField = nil;
    
    // Check the entered value. If not okay, set to an appropriate value. Store the value.
    
    NSInteger anOkayInteger = -1;
    NSString *theKey;
    
    NSInteger theCurrentInteger = [theTextField.text integerValue];
    if (theTextField == self.numberOfTimeUnitsTextField) {
        
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:GGKLongTermMinimumNumberOfTimeUnitsInteger maximum:GGKLongTermMaximumNumberOfTimeUnitsInteger];
        theKey = GGKLongTermNumberOfTimeUnitsKeyString;
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
    // Store the time unit.
    
    GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)sender;
    GGKTimeUnit theCurrentTimeUnit = aTimeUnitsTableViewController.currentTimeUnit;
    NSInteger anOkayInteger = theCurrentTimeUnit;
        
    // Set the new value, then update the entire UI.
    [[NSUserDefaults standardUserDefaults] setInteger:anOkayInteger forKey:GGKLongTermTimeUnitKeyString];
    [self getSavedTimerSettings];
    
    [self.currentPopoverController dismissPopoverAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Observe changes to the timer settings.
    [self addObserver:self forKeyPath:GGKLongTermNumberOfTimeUnitsKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:GGKLongTermTimeUnitKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    
    [self getSavedTimerSettings];
}

@end
