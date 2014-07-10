//
//  GGKUtilities.m
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKUtilities.h"

@implementation GGKUtilities
+ (void)addBorderOfColor:(UIColor *)theColor toView:(UIView *)theView {
    theView.layer.borderWidth = 1.0f;
//    theView.layer.borderColor = theView.tintColor.CGColor;
    theView.layer.borderColor = theColor.CGColor;
    theView.layer.cornerRadius = 5.0f;
}
+ (BOOL)iOSisBelow7 {
    // From Apple iOS 7 UI Transition Guide: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/SupportingEarlieriOS.html
    return floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
}
+ (void)matchFrameOfRotated90View:(UIView *)theRotatedView withView:(UIView *)theTemplateView {
    // Match centers. Switch width and height.
    theRotatedView.center = theTemplateView.center;
    CGPoint theBoundsOriginPoint = theRotatedView.bounds.origin;
    CGSize theUnreversedSize = theTemplateView.bounds.size;
    CGRect theNewBoundsRect = CGRectMake(theBoundsOriginPoint.x, theBoundsOriginPoint.y, theUnreversedSize.height, theUnreversedSize.width);
    theRotatedView.bounds = theNewBoundsRect;
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
