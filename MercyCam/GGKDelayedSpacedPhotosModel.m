//
//  GGKDelayedSpacedPhotosModel.m
//  MercyCam
//
//  Created by Geoff Hom on 8/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKDelayedSpacedPhotosModel.h"

//NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString = @"Take advanced delayed photos: time unit to use between photos.";
//NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString = @"Take advanced delayed photos: time unit to use to initially wait.";

// Keys for saving data.
NSString *GGKDelayedSpacedPhotosNumberOfPhotosToTakeIntegerKeyString = @"Take advanced delayed photos: number of photos.";
NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToDelayIntegerKeyString = @"Take advanced delayed photos: number of time units to initially wait.";
NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToSpaceIntegerKeyString = @"Take advanced delayed photos: number of time units between photos.";

@implementation GGKDelayedSpacedPhotosModel
// Custom accessors.
- (NSInteger)numberOfPhotosToTakeInteger {
    NSInteger theNumberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKDelayedSpacedPhotosNumberOfPhotosToTakeIntegerKeyString];
    return theNumberOfPhotosToTakeInteger;
}
- (void)setNumberOfPhotosToTakeInteger:(NSInteger)theNumberOfPhotosToTakeInteger {
    [[NSUserDefaults standardUserDefaults] setInteger:theNumberOfPhotosToTakeInteger forKey:GGKDelayedSpacedPhotosNumberOfPhotosToTakeIntegerKeyString];
}
- (NSInteger)numberOfTimeUnitsToDelayInteger {
    NSInteger theNumberOfTimeUnitsToDelayInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKDelayedSpacedPhotosNumberOfTimeUnitsToDelayIntegerKeyString];
    return theNumberOfTimeUnitsToDelayInteger;
}
- (void)setNumberOfTimeUnitsToDelayInteger:(NSInteger)theNumberOfTimeUnitsToDelayInteger {
    [[NSUserDefaults standardUserDefaults] setInteger:theNumberOfTimeUnitsToDelayInteger forKey:GGKDelayedSpacedPhotosNumberOfTimeUnitsToDelayIntegerKeyString];
}
- (NSInteger)numberOfTimeUnitsToSpaceInteger {
    NSInteger theNumberOfTimeUnitsToSpaceInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKDelayedSpacedPhotosNumberOfTimeUnitsToSpaceIntegerKeyString];
    return theNumberOfTimeUnitsToSpaceInteger;
}
- (void)setNumberOfTimeUnitsToSpaceInteger:(NSInteger)theNumberOfTimeUnitsToSpaceInteger {
    [[NSUserDefaults standardUserDefaults] setInteger:theNumberOfTimeUnitsToSpaceInteger forKey:GGKDelayedSpacedPhotosNumberOfTimeUnitsToSpaceIntegerKeyString];
}
@end
