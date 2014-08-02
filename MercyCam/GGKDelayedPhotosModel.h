//
//  GGKDelayedPhotosModel.h
//  MercyCam
//
//  Created by Geoff Hom on 7/19/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoModel.h"

// Keys for saving data.
extern NSString *GGKDelayedPhotosNumberOfPhotosToTakeIntegerKeyString;
extern NSString *GGKDelayedPhotosNumberOfSecondsToWaitIntegerKeyString;

@interface GGKDelayedPhotosModel : GGKTakePhotoModel
//@property (assign, nonatomic) NSInteger numberOfPhotosTakenInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfPhotosToTakeInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfSecondsToWaitInteger;
//@property (assign, nonatomic) NSInteger numberOfSecondsWaitedInteger;

// Override.
// If a delay requested, return yes.
- (BOOL)doStartTimer;
@end
