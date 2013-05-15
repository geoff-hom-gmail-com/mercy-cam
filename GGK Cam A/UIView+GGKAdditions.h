//
//  UIView+GGKAdditions.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GGKAdditions)

// Set the receiver's x-coordinate so the receiver's horizontal center matches the given view's.
- (void)ggk_alignHorizontalCenterWithView:(UIView *)theView;

// Set the receiver's x-coordinate so its left edge matches the given view's.
- (void)ggk_alignLeftEdgeWithView:(UIView *)theView;

// Set the receiver's x-coordinate so its right edge matches the given view's.
- (void)ggk_alignRightEdgeWithView:(UIView *)theView;

// Set the receiver's y-coordinate so the receiver's vertical center matches the given view's.
- (void)ggk_alignVerticalCenterWithView:(UIView *)theView;

// Set the receiver's y-coordinate so the gap between the receiver's bottom edge and its parent view's bottom edge is the given gap.
- (void)ggk_makeBottomGap:(CGFloat)theGap;

// Set the receiver's x-coordinate so the gap between the receiver's left edge and its parent view's left edge is the given gap.
- (void)ggk_makeLeftGap:(CGFloat)theGap;

// Set the receiver's x-coordinate so the gap between the receiver's right edge and its parent view's right edge is the given gap.
- (void)ggk_makeRightGap:(CGFloat)theGap;

// Set the receiver's width to the given value.
- (void)ggk_makeWidth:(CGFloat)theFloat;

// Set the receiver's y-coordinate so the receiver is above the given view by the given gap.
- (void)ggk_placeAboveView:(UIView *)theView gap:(CGFloat)theGap;

// Set the receiver's origin to the given point.
- (void)ggk_placeAtPoint:(CGPoint)thePoint;

// Set the receiver's y-coordinate so the receiver is below the given view by the given gap.
- (void)ggk_placeBelowView:(UIView *)theView gap:(CGFloat)theGap;

// Set the receiver's x-coordinate so the receiver is right of the given view by the given gap.
- (void)ggk_placeRightOfView:(UIView *)theView gap:(CGFloat)theGap;

@end
