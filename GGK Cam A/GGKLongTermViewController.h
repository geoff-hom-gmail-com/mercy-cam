//
//  GGKLongTermViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/17/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// Story: User reads about taking photos of a long term. User reads about the long-term timer for saving power by dimming the screen, hiding the camera preview, etc. User can set the long-term timer.

#import "GGKViewController.h"

#import "GGKTimeUnits.h"
#import "GGKTimeUnitsTableViewController.h"
#import <UIKit/UIKit.h>

// The default number of time units to use for waiting.
extern const NSInteger GGKLongTermDefaultNumberOfTimeUnitsInteger;

// The default time unit to use for waiting.
extern const GGKTimeUnit GGKLongTermDefaultTimeUnit;

extern const NSInteger GGKLongTermMaximumNumberOfTimeUnitsInteger;

extern const NSInteger GGKLongTermMinimumNumberOfTimeUnitsInteger;

// For KVO on that property.
extern NSString *GGKLongTermNumberOfTimeUnitsKeyPathString;

// Key for storing the time unit to use for waiting.
extern NSString *GGKLongTermNumberOfTimeUnitsKeyString;

// For KVO on that property.
extern NSString *GGKLongTermTimeUnitKeyPathString;

// Key for storing the time unit to use for waiting.
extern NSString *GGKLongTermTimeUnitKeyString;

@interface GGKLongTermViewController : GGKViewController <GGKTimeUnitsTableViewControllerDelegate, UITextFieldDelegate>

// How many seconds/minutes/etc. to wait.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) NSInteger numberOfTimeUnitsInteger;

// Number of time units to wait.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsTextField;

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units to 1. User sees singular text for that time unit.
// The time unit to use to wait.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitButton;

// The time unit to use (seconds/minutes/etc.) for waiting.
// Could retrieve from user defaults each time, but want flexibility to assign without a key.
@property (nonatomic, assign) GGKTimeUnit timeUnit;
// Override.
- (void)dealloc;
// Override.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// Override.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
// So, note which text field is being edited. (To know whether to shift the screen up when the keyboard shows.)

- (void)textFieldDidEndEditing:(UITextField *)textField;
// So, if an invalid value was entered, then use the previous value. Also, note that no text field is being edited now.

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// So, dismiss the keyboard.

- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// So, store the selected time unit and dismiss the popover.

// Override.
- (void)viewDidLoad;

@end
