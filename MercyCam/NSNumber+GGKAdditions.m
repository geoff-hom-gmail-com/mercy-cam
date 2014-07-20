//
//  NSNumber+GGKAdditions.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/10/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "NSNumber+GGKAdditions.h"

@implementation NSNumber (GGKAdditions)

+ (NSInteger)ggk_integerBoundedByRange:(NSInteger)theCurrentInteger minimum:(NSInteger)theMinimumInteger maximum:(NSInteger)theMaximumInteger {
    NSInteger anInteger = theCurrentInteger;
    if (theCurrentInteger < theMinimumInteger) {
        anInteger = theMinimumInteger;
    } else if (theCurrentInteger > theMaximumInteger) {
        anInteger = theMaximumInteger;
    }
    return anInteger;
}

@end
