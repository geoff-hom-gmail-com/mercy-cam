//
//  NSString+GGKAdditions.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GGKAdditions)

// Return the receiver, perhaps in singular form: If the given integer is 1, then remove any trailing s.
// It may seem easier to have a method adding an s, but most of the time, words with numbers will be plural.
- (NSString *)ggk_stringPerhapsWithoutS:(NSInteger)thePluralityInteger;

@end
