//
//  GGKDelayedSpacedPhotosModel.h
//  MercyCam
//
//  Created by Geoff Hom on 8/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoModel.h"

#import "GGKTimeUnits.h"

// Keys for saving data.
extern NSString *GGKDelayedSpacedPhotosDelayTimeUnitIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfPhotosToTakeIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToDelayIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToSpaceIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosSpaceTimeUnitIntegerKeyString;

@interface GGKDelayedSpacedPhotosModel : GGKTakePhotoModel
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
// Override.
// If a delay requested, return yes.
- (BOOL)doStartTimer;
// Override.
// Depends on values for delay and space.
- (BOOL)doStopTimer;
// Override.
// Usually it's the spacing. Unless first photo (and delay > 0).
- (NSInteger)numberOfSecondsToWaitInteger;
// Override.
// If delay = 0 but space > 0, then we should start the timer after the first photo here.
- (void)takePhoto;
@end
