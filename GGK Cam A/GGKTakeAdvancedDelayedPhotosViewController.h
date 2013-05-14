//
//  GGKTakeAdvancedDelayedPhotosViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosAbstractViewController.h"
#import "GGKTimeUnits.h"

// The default number of photos to take.
extern const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger;

// The default number of time units between each photo.
extern const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger;

// The default number of time units to initially wait.
extern const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger;

// The default time unit to use between each photo.
extern const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit;

// The default time unit to use for the initial wait.
extern const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit;

// Key for storing the number of photos to take.
extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString;

// Key for storing the number of time units between each photo.
extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString;

// Key for storing the number of time units to initially wait.
extern NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString;

// Key for storing the time unit to use between each photo.
extern NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString;

// Key for storing the time unit to use for the initial wait.
extern NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString;

@interface GGKTakeAdvancedDelayedPhotosViewController : GGKTakeDelayedPhotosAbstractViewController

// Override.
- (void)captureManagerDidTakePhoto:(id)sender;
// If there is time set between photos, then those timers will handle taking more photos. But if the time between photos is set to 0, and if more photos should be taken, then do that.

// Override.
- (void)getSavedTimerSettings;

// Override.
- (void)updateLayoutForLandscape;

// Override.
- (void)updateLayoutForPortrait;

// Override.
- (void)viewDidLoad;

@end
