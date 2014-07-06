//
//  GGKTimeUnits.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/11/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

// The currently selected time unit.
typedef enum {
    GGKTimeUnitSeconds,
    GGKTimeUnitMinutes,
    GGKTimeUnitHours,
    GGKTimeUnitDays
} GGKTimeUnit;

// String corresponding to the time unit for days.
extern NSString *GGKTimeUnitDaysString;

// String corresponding to the time unit for hours.
extern NSString *GGKTimeUnitHoursString;

// String corresponding to the time unit for minutes.
extern NSString *GGKTimeUnitMinutesString;

// String corresponding to the time unit for seconds.
extern NSString *GGKTimeUnitSecondsString;

@interface GGKTimeUnits : NSObject

// Return the number of seconds per the given time unit.
+ (NSInteger)numberOfSecondsInTimeUnit:(GGKTimeUnit)theTimeUnit;

// Return the number of given time units in the given interval. Note: The answer is truncated to the nearest decimal.
+ (CGFloat)numberOfTimeUnitsInTimeInterval:(NSTimeInterval)theTimeInterval timeUnit:(GGKTimeUnit)theTimeUnit;

// Set the title for the given button to the given time unit, accounting for plurality (e.g., second(s)).
+ (void)setTitleForButton:(UIButton *)theButton withTimeUnit:(GGKTimeUnit)theTimeUnit ofPlurality:(NSInteger)thePluralityInteger;

// Return the string corresponding to the given time unit. E.g., "seconds."
+ (NSString *)stringForTimeUnit:(GGKTimeUnit)theTimeUnit;

// Return the time unit corresponding to the given string. If no match, return the one for "seconds."
//+ (GGKTimeUnit)timeUnitForString:(NSString *)theTimeUnitString;

@end
