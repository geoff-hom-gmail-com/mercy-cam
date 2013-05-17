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
#import <UIKit/UIKit.h>

// The default number of time units to use for waiting.
extern const NSInteger GGKLongTermDefaultNumberOfTimeUnitsInteger;

// The default time unit to use for waiting.
extern const GGKTimeUnit GGKLongTermDefaultTimeUnit;

// Key for storing the time unit to use for waiting.
extern NSString *GGKLongTermNumberOfTimeUnitsKeyString;

// Key for storing the time unit to use for waiting.
extern NSString *GGKLongTermTimeUnitKeyString;

@interface GGKLongTermViewController : GGKViewController

@end
