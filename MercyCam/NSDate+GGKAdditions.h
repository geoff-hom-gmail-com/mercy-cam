//
//  NSDate+GGKAdditions.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (GGKAdditions)

// Return a string in DDD:HH:MM:SS format for the given time interval (i.e., number of seconds). (Note: The interval is rounded to the nearest second.)
+ (NSString *)ggk_dayHourMinuteSecondStringForTimeInterval:(NSTimeInterval)theTimeInterval;

@end
