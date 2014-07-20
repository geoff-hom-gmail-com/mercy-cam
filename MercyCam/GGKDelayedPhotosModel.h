//
//  GGKDelayedPhotosModel.h
//  MercyCam
//
//  Created by Geoff Hom on 7/19/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys for saving data.
extern NSString *GGKDelayedPhotosNumberOfPhotosToTakeIntegerKeyString;
extern NSString *GGKDelayedPhotosNumberOfSecondsToWaitIntegerKeyString;

@interface GGKDelayedPhotosModel : NSObject
@property (assign, nonatomic) NSInteger numberOfPhotosTakenInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfPhotosToTakeInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfSecondsToWaitInteger;
@property (assign, nonatomic) NSInteger numberOfSecondsWaitedInteger;
// Timer goes off each second and serves two purposes: 1) UI can be updated each second, so user can get visual feedback. 2) We can track how many seconds have passed, to know when to take a photo.
// Need this property to invalidate the timer later.
@property (nonatomic, strong) NSTimer *oneSecondRepeatingTimer;

@end
