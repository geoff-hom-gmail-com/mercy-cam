//
//  NSUserDefaults+GGKAdditions.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "NSUserDefaults+GGKAdditions.h"

@implementation NSUserDefaults (GGKAdditions)

- (NSInteger)ggk_integerForKey:(NSString *)theKey ifNil:(NSInteger)theAlternateInteger
{
    // Use -objectForKey to know for sure if the key wasn't found.
    NSInteger theInteger;
    NSNumber *aNumber = [self objectForKey:theKey];
    if (aNumber == nil) {
        
        theInteger = theAlternateInteger;
    } else {
        
        theInteger = [aNumber integerValue];
    }
    return theInteger;
}

@end
