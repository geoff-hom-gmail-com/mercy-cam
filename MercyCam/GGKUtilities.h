//
//  GGKUtilities.h
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGKUtilities : NSObject
// Add a rounded border of the given color to the given view.
+ (void)addBorderOfColor:(UIColor *)theColor toView:(UIView *)theView;
// Return whether device is running iOS less than 7; e.g., 6.1. There were a lot of changes in iOS 7.
+ (BOOL)iOSisBelow7;
// Given a view whose transform is 90° (e.g., view.transform = CGAffineTransformMakeRotation(M_PI_2)), make that view's effective frame match the second view's frame. (Frame is undefined with transforms, so this uses center and bounds to achieve the desired effect.) Note that the frame will match whether the transform is -90° or +90°.
+ (void)matchFrameOfRotated90View:(UIView *)theRotatedView withView:(UIView *)theTemplateView;
// Return table view for the given cell.
+ (UITableView *)tableViewForCell:(UITableViewCell *)theCell;
@end
