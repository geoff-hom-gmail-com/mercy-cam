//
//  GGKDelayedSpacedPhotosModel.m
//  MercyCam
//
//  Created by Geoff Hom on 8/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKDelayedSpacedPhotosModel.h"

// Keys for saving data.
NSString *GGKDelayedSpacedPhotosDelayTimeUnitIntegerKeyString = @"Take advanced delayed photos: time unit to use to initially wait.";
NSString *GGKDelayedSpacedPhotosNumberOfPhotosToTakeIntegerKeyString = @"Take advanced delayed photos: number of photos.";
NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToDelayIntegerKeyString = @"Take advanced delayed photos: number of time units to initially wait.";
NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToSpaceIntegerKeyString = @"Take advanced delayed photos: number of time units between photos.";
NSString *GGKDelayedSpacedPhotosSpaceTimeUnitIntegerKeyString = @"Take advanced delayed photos: time unit to use between photos.";

@implementation GGKDelayedSpacedPhotosModel
// Custom accessors.
- (GGKTimeUnit)delayTimeUnit {
    NSInteger anInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKDelayedSpacedPhotosDelayTimeUnitIntegerKeyString];
    GGKTimeUnit theDelayTimeUnit = anInteger;
    return theDelayTimeUnit;
}
- (void)setDelayTimeUnit:(GGKTimeUnit)theDelayTimeUnit {
    NSInteger anInteger = theDelayTimeUnit;
    [[NSUserDefaults standardUserDefaults] setInteger:anInteger forKey:GGKDelayedSpacedPhotosDelayTimeUnitIntegerKeyString];
}
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
- (GGKTimeUnit)spaceTimeUnit {
    NSInteger anInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKDelayedSpacedPhotosSpaceTimeUnitIntegerKeyString];
    GGKTimeUnit theSpaceTimeUnit = anInteger;
    return theSpaceTimeUnit;
}
- (void)setSpaceTimeUnit:(GGKTimeUnit)theSpaceTimeUnit {
    NSInteger anInteger = theSpaceTimeUnit;
    [[NSUserDefaults standardUserDefaults] setInteger:anInteger forKey:GGKDelayedSpacedPhotosSpaceTimeUnitIntegerKeyString];
}

- (BOOL)doStartTimer {
    BOOL doStartTimerBOOL = NO;
    if (self.numberOfTimeUnitsToDelayInteger > 0) {
        doStartTimerBOOL = YES;
    }
    return doStartTimerBOOL;
}
- (BOOL)doStopTimer {
    // possible values for delay, space: 0, 0: no timer; x, 0: stop timer after first wait; 0, y: stop after last (2nd to last?) photo taken; x, y: same as 0, y.
    // If ....
    BOOL doStopTimerBOOL = ??;
    return doStopTimerBOOL;
}


// Seconds to wait to take next photo. Relative to trigger start (for first photo) or time of previous photo (for later photos).
// Subclasses should override.

// First photo: delay. Later photos: space.
- (NSInteger)numberOfSecondsToWaitInteger {
//    return 0;
}

- (void)takePhoto {
    [super takePhoto];
    if (self.numberOfPhotosTakenInteger == 1 && self.numberOfTimeUnitsToDelayInteger == 0 && self.numberOfTimeUnitsToSpaceInteger > 0) {
        [self startTimer];
    }
}
@end
