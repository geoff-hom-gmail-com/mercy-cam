//
//  GGKModel.m
//  Mercy Cam
//
//  Created by Geoff Hom on 7/6/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKModel.h"

@implementation GGKModel
- (id)init {
    self = [super init];
    if (self) {
        self.appMode = GGKAppModePlanning;
    }
    return self;
}
@end
