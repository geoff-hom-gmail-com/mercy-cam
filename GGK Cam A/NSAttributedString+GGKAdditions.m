//
//  NSAttributedString+GGKAdditions.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/15/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "NSAttributedString+GGKAdditions.h"

@implementation NSAttributedString (GGKAdditions)

- (NSAttributedString *)ggk_attributedStringWithFont:(UIFont *)theFont
{
    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [aMutableAttributedString addAttribute:NSFontAttributeName value:theFont range:NSMakeRange(0, aMutableAttributedString.length)];
    return [aMutableAttributedString copy];
}

@end
