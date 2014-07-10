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

//+ (void)matchFrameOfRotated270View:(UIView *)theRotatedView withView:(UIView *)theTemplateView {
//    // Match centers. Switch width and height.
//    theRotatedView.center = theTemplateView.center;
//    CGPoint theBoundsOriginPoint = theRotatedView.bounds.origin;
//    CGSize theUnreversedSize = theTemplateView.bounds.size;
//    CGRect theNewBoundsRect = CGRectMake(theBoundsOriginPoint.x, theBoundsOriginPoint.y, theUnreversedSize.height, theUnreversedSize.width);
//    theRotatedView.bounds = theNewBoundsRect;
//}

+ (void)matchFrameOfRotated90View:(UIView *)theRotatedView withView:(UIView *)theTemplateView {
    // Match centers. Switch width and height.
    theRotatedView.center = theTemplateView.center;
    CGPoint theBoundsOriginPoint = theRotatedView.bounds.origin;
    CGSize theUnreversedSize = theTemplateView.bounds.size;
    CGRect theNewBoundsRect = CGRectMake(theBoundsOriginPoint.x, theBoundsOriginPoint.y, theUnreversedSize.height, theUnreversedSize.width);
    theRotatedView.bounds = theNewBoundsRect;
}

// works but not abstract enough
//+ (UIButton *)buttonWithTextRotated270WithButton:(UIButton *)theButton {
//    // Try using center and bounds. So we'll leave the anchor point as-is.
//    // match the centers; switch the width and height; rotate
//    
//    // We'll rotate around the origin to make sure it's integral and thus sharp. We want a button with the width and height switched, and the origin shifted right by the given width. Then we rotate 90° clockwise.
//    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    aButton.transform = CGAffineTransformMakeRotation(M_PI_2);
//    aButton.center = theButton.center;
//    CGPoint theBoundsOriginPoint = aButton.bounds.origin;
//    CGSize theUnreversedSize = theButton.bounds.size;
//    CGRect theNewBoundsRect = CGRectMake(theBoundsOriginPoint.x, theBoundsOriginPoint.y, theUnreversedSize.height, theUnreversedSize.width);
//    aButton.bounds = theNewBoundsRect;
//    return aButton;
//}
//works but uses frame instead of center and bounds, so less robust
+ (UIButton *)buttonWithTextRotated270WithFrame:(CGRect)theFrame {
    // We'll rotate around the origin to make sure it's integral and thus sharp. We want a button with the width and height switched, and the origin shifted right by the given width. Then we rotate 90° clockwise.
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.layer.anchorPoint = CGPointZero;
    CGPoint theOriginPoint = theFrame.origin;
    CGSize theOldFrameSize = theFrame.size;
    CGPoint theNewOriginPoint = CGPointMake(theOriginPoint.x + theOldFrameSize.width, theOriginPoint.y);
    CGRect aNewRect = CGRectMake(theNewOriginPoint.x, theNewOriginPoint.y, theOldFrameSize.height, theOldFrameSize.width);
    aButton.frame = aNewRect;
    NSLog(@"test3:%@", NSStringFromCGRect(aNewRect));
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
+ (CGRect)frameToRotate270ToMatchFrame:(CGRect)theFrame {
    // Rotate around origin to ensure frame is integral and thus sharp. We want a frame with the width and height switched, and the origin shifted right by the given width. Then a 90°-clockwise rotation (270°-counterclockwise) works.
//    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    aButton.layer.anchorPoint = CGPointZero;
    CGPoint theOriginPoint = theFrame.origin;
    CGSize theOldFrameSize = theFrame.size;
    CGPoint theNewOriginPoint = CGPointMake(theOriginPoint.x + theOldFrameSize.width, theOriginPoint.y);
    CGRect aNewRect = CGRectMake(theNewOriginPoint.x, theNewOriginPoint.y, theOldFrameSize.height, theOldFrameSize.width);
    return aNewRect;
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
