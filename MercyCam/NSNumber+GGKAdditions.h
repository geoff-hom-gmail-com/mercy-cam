//
//  NSNumber+GGKAdditions.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/10/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (GGKAdditions)

// Return the given integer if it's within the given range. Else, return the closest end of the range.
+ (NSInteger)ggk_integerBoundedByRange:(NSInteger)theCurrentInteger minimum:(NSInteger)theMinimumInteger maximum:(NSInteger)theMaximumInteger;

@end
