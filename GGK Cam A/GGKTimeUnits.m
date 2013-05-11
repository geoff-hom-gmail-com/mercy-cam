//
//  GGKTimeUnits.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/11/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTimeUnits.h"

NSString *GGKTimeUnitDaysString = @"days";

NSString *GGKTimeUnitHoursString = @"hours";

NSString *GGKTimeUnitMinutesString = @"minutes";

NSString *GGKTimeUnitSecondsString = @"seconds";

@implementation GGKTimeUnits

+ (NSInteger)numberOfSecondsInTimeUnit:(GGKTimeUnit)theTimeUnit
{
    NSInteger theNumberOfSecondsInAMinute = 60;
    NSInteger theNumberOfMinutesInAnHour = 60;
    NSInteger theNumberOfHoursInADay = 24;
    
    NSInteger theNumberOfSeconds;
    switch (theTimeUnit) {
            
        case GGKTimeUnitSeconds:
            theNumberOfSeconds = 1;
            break;
            
        case GGKTimeUnitMinutes:
            theNumberOfSeconds = theNumberOfSecondsInAMinute;
            break;
            
        case GGKTimeUnitHours:
            theNumberOfSeconds = theNumberOfMinutesInAnHour * theNumberOfSecondsInAMinute;
            break;
            
        case GGKTimeUnitDays:
            theNumberOfSeconds = theNumberOfHoursInADay * theNumberOfMinutesInAnHour * theNumberOfSecondsInAMinute;
            break;
            
        default:
            break;
    }
    return theNumberOfSeconds;
}

+ (NSString *)stringForTimeUnit:(GGKTimeUnit)theTimeUnit
{
    NSString *aTimeUnitString;
    switch (theTimeUnit) {
            
        case GGKTimeUnitSeconds:
            aTimeUnitString = GGKTimeUnitSecondsString;
            break;
            
        case GGKTimeUnitMinutes:
            aTimeUnitString = GGKTimeUnitMinutesString;
            break;
            
        case GGKTimeUnitHours:
            aTimeUnitString = GGKTimeUnitHoursString;
            break;
            
        case GGKTimeUnitDays:
            aTimeUnitString = GGKTimeUnitDaysString;
            break;
            
        default:
            break;
    }
    return aTimeUnitString;
}

+ (GGKTimeUnit)timeUnitForString:(NSString *)theTimeUnitString
{
    GGKTimeUnit theTimeUnit = GGKTimeUnitSeconds;
    if ([theTimeUnitString isEqualToString:GGKTimeUnitSecondsString]) {
        
        theTimeUnit = GGKTimeUnitSeconds;
    } else if ([theTimeUnitString isEqualToString:GGKTimeUnitMinutesString]) {
        
        theTimeUnit = GGKTimeUnitMinutes;
    } else if ([theTimeUnitString isEqualToString:GGKTimeUnitHoursString]) {
        
        theTimeUnit = GGKTimeUnitHours;
    } else if ([theTimeUnitString isEqualToString:GGKTimeUnitDaysString]) {
        
        theTimeUnit = GGKTimeUnitDays;
    }
    return theTimeUnit;
}

@end
