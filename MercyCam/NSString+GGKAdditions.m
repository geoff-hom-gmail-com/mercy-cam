//
//  NSString+GGKAdditions.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "NSString+GGKAdditions.h"

@implementation NSString (GGKAdditions)

- (NSString *)ggk_stringPerhapsWithoutS:(NSInteger)thePluralityInteger
{
    NSString *aString = [self copy];
    if (thePluralityInteger == 1) {
        
        NSUInteger theLastIndex = [self length] - 1;
        unichar aChar = [self characterAtIndex:theLastIndex];
        if (aChar == 's') {
            
            // Remove "s."
            aString = [self substringToIndex:theLastIndex];
        }
    }
    return aString;
}

@end
