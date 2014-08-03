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

- (void)handleTimerFired {
    UIScreen *aScreen = [UIScreen mainScreen];
    self.previousBrightnessFloat = aScreen.brightness;
    aScreen.brightness = 0.0;
    [self.delegate longTermModelTimerDidFire:self];
    
    // do in delegate?
    self.cameraPreviewView.hidden = YES;
    self.overlayView.hidden = NO;
}

- (void)startTimer {
    // stop any previous timer? is this the place to do this?
    [self.timer invalidate];
    self.timer = nil;
    
    // For testing.
    //    self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger = 5;
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger target:self selector:@selector(handleLongTermTimerFired) userInfo:nil repeats:NO];
    self.timer = aTimer;
}

@end
