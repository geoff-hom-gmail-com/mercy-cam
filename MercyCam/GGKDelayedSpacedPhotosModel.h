//
//  GGKDelayedSpacedPhotosModel.h
//  MercyCam
//
//  Created by Geoff Hom on 8/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GGKTimeUnits.h"

// Keys for saving data.
extern NSString *GGKDelayedSpacedPhotosDelayTimeUnitIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfPhotosToTakeIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToDelayIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToSpaceIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosSpaceTimeUnitIntegerKeyString;

@interface GGKDelayedSpacedPhotosModel : NSObject
// The time unit to use (seconds/minutes/etc.) for the initial wait.
// Custom accessors.
@property (nonatomic, assign) GGKTimeUnit delayTimeUnit;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfPhotosToTakeInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfTimeUnitsToDelayInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfTimeUnitsToSpaceInteger;
// The time unit to use (seconds/minutes/etc.) for waiting between photos.
// Custom accessors.
@property (nonatomic, assign) GGKTimeUnit spaceTimeUnit;
@end
