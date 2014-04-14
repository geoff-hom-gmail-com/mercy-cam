//
//  GGKUtilities.m
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKUtilities.h"

@implementation GGKUtilities
+ (void)addBorderToView:(UIView *)theView {
    theView.layer.borderWidth = 1.0f;
    theView.layer.borderColor = theView.tintColor.CGColor;
    theView.layer.cornerRadius = 3.0f;
}
+ (UIButton *)buttonWithTextRotated270WithFrame:(CGRect)theFrame {
    // We'll rotate around the origin to make sure it's integral and thus sharp. We want a button with the width and height switched, and the origin shifted right by the given width. Then we rotate 90° clockwise.
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.layer.anchorPoint = CGPointZero;
    CGPoint theOriginPoint = theFrame.origin;
    CGSize theOldFrameSize = theFrame.size;
    CGPoint theNewOriginPoint = CGPointMake(theOriginPoint.x + theOldFrameSize.width, theOriginPoint.y);
    CGRect aNewRect = CGRectMake(theNewOriginPoint.x, theNewOriginPoint.y, theOldFrameSize.height, theOldFrameSize.width);
    aButton.frame = aNewRect;
    aButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    return aButton;
}
+ (UIButton *)buttonWithTextRotated90WithFrame:(CGRect)theFrame {
    // We'll rotate around the origin to make sure it's integral and thus sharp. We want a button with the width and height switched, and the origin shifted down by the given height. Then we rotate 90° counterclockwise.
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.layer.anchorPoint = CGPointZero;
    CGPoint theOriginPoint = theFrame.origin;
    CGSize theOldFrameSize = theFrame.size;
    CGPoint theNewOriginPoint = CGPointMake(theOriginPoint.x, theOriginPoint.y + theOldFrameSize.height);
    CGRect aNewRect = CGRectMake(theNewOriginPoint.x, theNewOriginPoint.y, theOldFrameSize.height, theOldFrameSize.width);
    aButton.frame = aNewRect;
    aButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    return aButton;
}
+ (BOOL)iOSisBelow7 {
    // From Apple iOS 7 UI Transition Guide: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/SupportingEarlieriOS.html
    return floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
}
+ (UITableView *)tableViewForCell:(UITableViewCell *)theCell {
    // Relation of table view to its cells differs in iOS 6 vs 7.
    UITableView *theTableView;
    UIView *aView = theCell.superview;
    if ([aView isKindOfClass:[UITableView class]]) {
        theTableView = (UITableView *)aView;
    } else {
        aView = aView.superview;
        if ([aView isKindOfClass:[UITableView class]]) {
            theTableView = (UITableView *)aView;
        }
    }
    return theTableView;
}
@end