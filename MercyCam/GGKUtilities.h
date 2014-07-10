//
//  GGKUtilities.h
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGKUtilities : NSObject

// deprecate
//+ (UIButton *)buttonWithTextRotated270WithButton:(UIButton *)theButton;

// Given a view whose transform is 270° counterclockwise, make that view's effective frame match the second view's frame. (Frame is undefined with transforms, so this uses center and bounds to achieve the desired effect.)
//+ (void)matchFrameOfRotated270View:(UIView *)theRotatedView withView:(UIView *)theTemplateView;

// Given a view whose transform is 90°, make that view's effective frame match the second view's frame. (Frame is undefined with transforms, so this uses center and bounds to achieve the desired effect.) Note that the frame will match whether the transform is -90° or +90°.
+ (void)matchFrameOfRotated90View:(UIView *)theRotatedView withView:(UIView *)theTemplateView;



// Add a rounded border of the given color to the given view.
+ (void)addBorderOfColor:(UIColor *)theColor toView:(UIView *)theView;
// Return a button with the given frame but text rotated 270°. The button is actually rotated, so the frame is relative. (Looks the same to the user.)
+ (UIButton *)buttonWithTextRotated270WithFrame:(CGRect)theFrame;
+ (UIButton *)buttonWithTextRotated90WithFrame:(CGRect)theFrame;
// Returns a frame that, when rotated 270°, can superimpose upon the given frame. The returned frame must be applied to a view with anchor point zero (i.e., view.layer.anchorPoint = CGPointZero).
+ (CGRect)frameToRotate270ToMatchFrame:(CGRect)theFrame;
// Return whether device is running iOS less than 7; e.g., 6.1. There were a lot of changes in iOS 7.
+ (BOOL)iOSisBelow7;

// Return a frame size that will keep a sharp view if the given view is rotated 90°. When a view is rotated, the center stays the same, so the origin changes. If the origin is not at integer points, then the view will be fuzzy. In a 90° rotation, the origin will be fine if both width and height are even, or if both are odd. So, at most, the width or height should be reduced by 1. Use this method by setting the view's size to the returned value, then rotating.
//+ (CGSize)sizeForSharp90RotationOfView:(UIView *)theView;

// Return table view for the given cell.
+ (UITableView *)tableViewForCell:(UITableViewCell *)theCell;
@end
