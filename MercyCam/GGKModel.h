//
//  GGKModel.h
//  Mercy Cam
//
//  Created by Geoff Hom on 7/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>


// App mode.
// Planning: default.
// Shooting: user takes photo or starts photo timer.
typedef NS_ENUM(NSInteger, GGKAppMode) {
    GGKAppModePlanning,
    GGKAppModeShooting
};

@interface GGKModel : NSObject
@property (assign, nonatomic) GGKAppMode appMode;
// Override.
- (id)init;
@end
