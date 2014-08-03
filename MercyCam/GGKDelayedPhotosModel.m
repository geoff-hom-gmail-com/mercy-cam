//
//  GGKDelayedPhotosModel.m
//  MercyCam
//
//  Created by Geoff Hom on 7/19/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKDelayedPhotosModel.h"

// Keys for saving data.
NSString *GGKDelayedPhotosNumberOfPhotosToTakeIntegerKeyString = @"Take delayed photos: number of photos";
NSString *GGKDelayedPhotosNumberOfSecondsToWaitIntegerKeyString = @"Take delayed photos: number of seconds to initially wait";

@implementation GGKDelayedPhotosModel
// Custom accessors.
- (NSInteger)numberOfPhotosToTakeInteger {
    NSInteger theNumberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKDelayedPhotosNumberOfPhotosToTakeIntegerKeyString];
    return theNumberOfPhotosToTakeInteger;
}
- (void)setNumberOfPhotosToTakeInteger:(NSInteger)theNumberOfPhotosToTakeInteger {
    [[NSUserDefaults standardUserDefaults] setInteger:theNumberOfPhotosToTakeInteger forKey:GGKDelayedPhotosNumberOfPhotosToTakeIntegerKeyString];
}
- (NSInteger)numberOfSecondsToWaitInteger {
    NSInteger theNumberOfSecondsToWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKDelayedPhotosNumberOfSecondsToWaitIntegerKeyString];
    return theNumberOfSecondsToWaitInteger;
}
- (void)setNumberOfSecondsToWaitInteger:(NSInteger)theNumberOfSecondsToWaitInteger {
    [[NSUserDefaults standardUserDefaults] setInteger:theNumberOfSecondsToWaitInteger forKey:GGKDelayedPhotosNumberOfSecondsToWaitIntegerKeyString];
}

- (BOOL)doStartTimer {
    BOOL doStartTimerBOOL = NO;
    if (self.numberOfSecondsToWaitInteger > 0) {
        doStartTimerBOOL = YES;
    }
    return doStartTimerBOOL;
}
- (BOOL)doStopTimer {
    BOOL doStopTimerBOOL = NO;
    if (self.numberOfPhotosTakenInteger > 0) {
        doStopTimerBOOL = YES;
    }
    return doStopTimerBOOL;
}
@end
