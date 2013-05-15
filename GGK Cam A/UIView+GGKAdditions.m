//
//  UIView+GGKAdditions.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "UIView+GGKAdditions.h"

@implementation UIView (GGKAdditions)

- (void)ggk_alignHorizontalCenterWithView:(UIView *)theView
{
    self.center = CGPointMake(theView.center.x, self.center.y);
}

- (void)ggk_alignLeftEdgeWithView:(UIView *)theView
{
    CGSize aSize = self.frame.size;
    self.frame = CGRectMake(theView.frame.origin.x, self.frame.origin.y, aSize.width, aSize.height);
}

- (void)ggk_alignRightEdgeWithView:(UIView *)theView
{
    CGSize aSize = self.frame.size;
    CGFloat theNewXFloat = theView.frame.origin.x + theView.frame.size.width - aSize.width;
    self.frame = CGRectMake(theNewXFloat, self.frame.origin.y, aSize.width, aSize.height);
}

- (void)ggk_alignVerticalCenterWithView:(UIView *)theView
{
    self.center = CGPointMake(self.center.x, theView.center.y);
}

- (void)ggk_makeBottomGap:(CGFloat)theGap
{
    CGSize aSize = self.frame.size;
    CGFloat theNewYFloat = self.superview.frame.size.height - theGap - aSize.height;
    self.frame = CGRectMake(self.frame.origin.x, theNewYFloat, aSize.width, aSize.height);
}

- (void)ggk_makeLeftGap:(CGFloat)theGap
{
    CGSize aSize = self.frame.size;
    self.frame = CGRectMake(theGap, self.frame.origin.y, aSize.width, aSize.height);
}

- (void)ggk_makeRightGap:(CGFloat)theGap
{
    CGSize aSize = self.frame.size;
    CGFloat theNewXFloat = self.superview.frame.size.width - theGap - aSize.width;
    self.frame = CGRectMake(theNewXFloat, self.frame.origin.y, aSize.width, aSize.height);
}

- (void)ggk_makeWidth:(CGFloat)theFloat
{
    CGPoint theOriginPoint = self.frame.origin;
    self.frame = CGRectMake(theOriginPoint.x, theOriginPoint.y, theFloat, self.frame.size.height);
}

- (void)ggk_placeAboveView:(UIView *)theView gap:(CGFloat)theGap
{
    CGSize aSize = self.frame.size;
    CGFloat theNewYFloat = theView.frame.origin.y - theGap - aSize.height;
    self.frame = CGRectMake(self.frame.origin.x, theNewYFloat, aSize.width, aSize.height);
}

- (void)ggk_placeAtPoint:(CGPoint)thePoint
{
    CGSize aSize = self.frame.size;
    self.frame = CGRectMake(thePoint.x, thePoint.y, aSize.width, aSize.height);
}

- (void)ggk_placeBelowView:(UIView *)theView gap:(CGFloat)theGap
{
    CGSize aSize = self.frame.size;
    CGFloat theNewYFloat = theView.frame.origin.y + theView.frame.size.height + theGap;
    self.frame = CGRectMake(self.frame.origin.x, theNewYFloat, aSize.width, aSize.height);
}

- (void)ggk_placeRightOfView:(UIView *)theView gap:(CGFloat)theGap
{
    CGSize aSize = self.frame.size;
    CGFloat theNewXFloat = theView.frame.origin.x + theView.frame.size.width + theGap;
    self.frame = CGRectMake(theNewXFloat, self.frame.origin.y, aSize.width, aSize.height);
}

@end
