//
//  GGKLongTermViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/17/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// Story: User reads about taking photos of a long term. User reads about the long-term timer for saving power by dimming the screen, hiding the camera preview, etc. User can set the long-term timer.

#import "GGKViewController.h"

#import "GGKTimeUnitsTableViewController.h"

@class GGKLongTermModel;

@interface GGKLongTermViewController : GGKViewController <GGKTimeUnitsTableViewControllerDelegate, UITextFieldDelegate>
// View explaining the long-term timer.
@property (weak, nonatomic) IBOutlet UIView *explanationView;
@property (strong, nonatomic) GGKLongTermModel *longTermModel;
// Number of time units to wait until dimming.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToWaitTextField;
// View showing the timer settings.
@property (weak, nonatomic) IBOutlet UIView *timerSettingsView;
// User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// User sets number of time units to 1. User sees singular text for that time unit.
// The time unit to use to wait.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitButton;
// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;
// Override.
// Prepare for time-unit selector.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
// Now that we can: Ensure we have a valid value.
- (void)textFieldDidEndEditing:(UITextField *)textField;
// Now that we can: Dismiss the keyboard.
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// Set the selected time unit, update UI and dismiss popover.
- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// Override.
- (void)updateUI;
// Override.
- (void)viewDidLoad;
@end
