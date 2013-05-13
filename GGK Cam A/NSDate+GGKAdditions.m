//
//  NSDate+GGKAdditions.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "NSDate+GGKAdditions.h"

@implementation NSDate (GGKAdditions)

+ (NSString *)ggk_dayHourMinuteSecondStringForTimeInterval:(NSTimeInterval)theTimeInterval
{
    NSInteger theNumberOfSecondsInAMinute = 60;
    NSInteger theNumberOfSecondsInAnHour = theNumberOfSecondsInAMinute * 60;
    NSInteger theNumberOfSecondsInADay = theNumberOfSecondsInAnHour * 24;
    
    // Round to the nearest second.
    NSInteger theRemainderInSecondsInteger = round(theTimeInterval);
    
    // Get days, then remaining hours, minutes, and seconds.
    NSInteger theNumberOfDays = theRemainderInSecondsInteger / theNumberOfSecondsInADay;
    theRemainderInSecondsInteger = theRemainderInSecondsInteger % theNumberOfSecondsInADay;
    NSInteger theNumberOfHours = theRemainderInSecondsInteger / theNumberOfSecondsInAnHour;
    theRemainderInSecondsInteger = theRemainderInSecondsInteger % theNumberOfSecondsInAnHour;
    NSInteger theNumberOfMinutes = theRemainderInSecondsInteger / theNumberOfSecondsInAMinute;
    theRemainderInSecondsInteger = theRemainderInSecondsInteger % theNumberOfSecondsInAMinute;
    NSInteger theNumberOfSeconds = theRemainderInSecondsInteger;
    NSString *aString = [NSString stringWithFormat:@"%3d:%2d:%2d:%2d", theNumberOfDays, theNumberOfHours, theNumberOfMinutes, theNumberOfSeconds];
    return aString;
}

@end
