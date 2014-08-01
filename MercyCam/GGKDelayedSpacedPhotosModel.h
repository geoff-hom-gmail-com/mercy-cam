//
//  GGKDelayedSpacedPhotosModel.h
//  MercyCam
//
//  Created by Geoff Hom on 8/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys for saving data.
extern NSString *GGKDelayedSpacedPhotosNumberOfPhotosToTakeIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToDelayIntegerKeyString;
extern NSString *GGKDelayedSpacedPhotosNumberOfTimeUnitsToSpaceIntegerKeyString;

@interface GGKDelayedSpacedPhotosModel : NSObject
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfPhotosToTakeInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfTimeUnitsToDelayInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfTimeUnitsToSpaceInteger;
@end
