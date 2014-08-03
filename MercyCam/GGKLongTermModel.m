//
//  GGKLongTermModel.m
//  MercyCam
//
//  Created by Geoff Hom on 8/3/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKLongTermModel.h"

// Keys for saving data.
NSString *GGKLongTermNumberOfTimeUnitsToWaitIntegerKeyString = @"Long-term: Number of time units.";
NSString *GGKLongTermTimeUnitIntegerKeyString = @"Long-term: Time unit.";

@implementation GGKLongTermModel
// Custom accessors.
- (NSInteger)numberOfTimeUnitsToWaitInteger {
    NSInteger theNumberOfTimeUnitsToWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermNumberOfTimeUnitsToWaitIntegerKeyString];
    return theNumberOfTimeUnitsToWaitInteger;
}
- (void)setNumberOfTimeUnitsToWaitInteger:(NSInteger)theNumberOfTimeUnitsToWaitInteger {
    [[NSUserDefaults standardUserDefaults] setInteger:theNumberOfTimeUnitsToWaitInteger forKey:GGKLongTermNumberOfTimeUnitsToWaitIntegerKeyString];
}
- (GGKTimeUnit)timeUnit {
    NSInteger anInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermTimeUnitIntegerKeyString];
    GGKTimeUnit theTimeUnit = anInteger;
    return theTimeUnit;
}
- (void)setTimeUnit:(GGKTimeUnit)theTimeUnit {
    NSInteger anInteger = theTimeUnit;
    [[NSUserDefaults standardUserDefaults] setInteger:anInteger forKey:GGKLongTermTimeUnitIntegerKeyString];
}

- (void)dealloc {
    [self stopTimer];
}
- (void)handleTimerFired {
    [self.delegate longTermModelTimerDidFire:self];
}
- (void)startTimer {
    NSInteger theNumberOfSecondsToWaitToDimScreenInteger = self.numberOfTimeUnitsToWaitInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:self.timeUnit];
//    NSLog(@"LTM secToWaitToDimScreen: %ld", (long)theNumberOfSecondsToWaitToDimScreenInteger);
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:theNumberOfSecondsToWaitToDimScreenInteger target:self selector:@selector(handleTimerFired) userInfo:nil repeats:NO];
    self.timer = aTimer;
}
- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}
@end
