//
//  NSAttributedString+GGKAdditions.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/15/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (GGKAdditions)

// Return a copy of the receiver, but with the font changed to the given one.
- (NSAttributedString *)ggk_attributedStringWithFont:(UIFont *)theFont;

@end
