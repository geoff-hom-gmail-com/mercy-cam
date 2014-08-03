//
//  GGKTakeDelayedPhotosAbstractViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// Abstract class for taking delayed photos. It should include most of what you need. Subclasses should work by blanking out features rather than adding them, so add new features here. 

// DEPRECATE?

#import "GGKAbstractPhotoViewController.h"
#import "GGKTimeUnits.h"
#import "GGKTimeUnitsTableViewController.h"

//extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger;
//extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger;
//extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger;

// For KVO on that property.
//extern NSString *GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString;
//extern NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString;
//extern NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString;
//extern NSString *GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString;
//extern NSString *GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString;

@interface GGKAbstractDelayedPhotosViewController : GGKAbstractPhotoViewController < UIGestureRecognizerDelegate>

// Story: User taps button. User can select seconds/minutes/hours/days/etc. from a popover. User taps selection and the button is updated.
// Story: User sets number of time units to initially wait to 1. User sees singular text for that time unit.
// The type of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitsToInitiallyWaitButton;
// View showing the timer settings.
@property (weak, nonatomic) IBOutlet UIView *timerSettingsView;

// Override.
- (void)dealloc;

// One of our gesture recognizers is for taps but also allows them through. Allow that recognizer to work with other recognizers (e.g., the tap-to-focus recognizer).
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

// Retrieve the timer settings from user defaults.
// Stub.
- (void)getSavedTimerSettings;
// Override.
- (void)handleViewWillAppearToUser;

// Override.
- (void)viewDidLoad;
@end
