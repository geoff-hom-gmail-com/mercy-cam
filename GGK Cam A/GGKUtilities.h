//
//  GGKUtilities.h
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGKUtilities : NSObject
// Add a rounded border to the given view.
+ (void)addBorderToView:(UIView *)theView;
// Return a button with the given frame but text rotated 270°. The button is actually rotated, so the frame is relative. (Looks the same to the user.)
+ (UIButton *)buttonWithTextRotated270WithFrame:(CGRect)theFrame;
+ (UIButton *)buttonWithTextRotated90WithFrame:(CGRect)theFrame;
// Return whether device is running iOS less than 7; e.g., 6.1. There were a lot of changes in iOS 7.
+ (BOOL)iOSisBelow7;

// Return a frame size that will keep a sharp view if the given view is rotated 90°. When a view is rotated, the center stays the same, so the origin changes. If the origin is not at integer points, then the view will be fuzzy. In a 90° rotation, the origin will be fine if both width and height are even, or if both are odd. So, at most, the width or height should be reduced by 1. Use this method by setting the view's size to the returned value, then rotating.
//+ (CGSize)sizeForSharp90RotationOfView:(UIView *)theView;

// Return table view for the given cell.
+ (UITableView *)tableViewForCell:(UITableViewCell *)theCell;
@end
