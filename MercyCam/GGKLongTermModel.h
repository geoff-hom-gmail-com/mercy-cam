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
// The screen brightness before dimming. Need for restoring.
@property (nonatomic, assign) CGFloat previousBrightnessFloat;
// The time unit to use (seconds/minutes/etc.) for waiting.
// Custom accessors.
@property (nonatomic, assign) GGKTimeUnit timeUnit;
// User taps trigger to take photos. Long-term timer also starts. When it fires, the screen dims to save power. The timer resets whenever the user taps the screen.
// Need for invalidating.
@property (nonatomic, strong) NSTimer *timer;
// Override.
- (void)dealloc;
// Notify delegate.
- (void)handleTimerFired;
// Start a timer to dim the screen.
- (void)startTimer;
- (void)stopTimer;
@end
