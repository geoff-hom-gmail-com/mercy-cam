//
//  GGKLongTermModel.h
//  MercyCam
//
//  Created by Geoff Hom on 8/3/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GGKTimeUnits.h"

// Keys for saving data.
extern NSString *GGKLongTermNumberOfTimeUnitsToWaitIntegerKeyString;
extern NSString *GGKLongTermTimeUnitIntegerKeyString;

@protocol GGKLongTermModelDelegate
// Sent after the timer fired.
- (void)longTermModelTimerDidFire:(id)sender;
@end

@interface GGKLongTermModel : NSObject
@property (weak, nonatomic) id <GGKLongTermModelDelegate> delegate;
// Number of time units to wait until dimming.
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfTimeUnitsToWaitInteger;
// The time unit to use (seconds/minutes/etc.) for waiting.
// Custom accessors.
@property (nonatomic, assign) GGKTimeUnit timeUnit;
// User taps "Start timer" to take photos. The long-term timer also starts. When it fires, the screen dims to save power. The timer resets whenever the user taps the screen.
// Need for invalidating.
@property (nonatomic, strong) NSTimer *timer;

// Dim the screen and hide the camera preview. Also, block taps from going through (in case the user accidentally taps Cancel, for example).
- (void)handleTimerFired;

// Start a timer for dimming the screen (and hiding the camera preview) after awhile.
- (void)startTimer;
@end
