//
//  GGKTakeAdvancedDelayedPhotosViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKDelayedSpacedPhotosViewController.h"

#import "GGKUtilities.h"
#import "UIView+GGKAdditions.h"

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger = 5;
const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger = 7;
const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger = 10;
const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit = GGKTimeUnitSeconds;
const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit = GGKTimeUnitSeconds;

NSString *GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString = @"Take advanced delayed photos: number of photos.";
NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString = @"Take advanced delayed photos: number of time units between photos.";
NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString = @"Take advanced delayed photos: number of time units to initially wait.";
NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString = @"Take advanced delayed photos: time unit to use between photos.";
NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString = @"Take advanced delayed photos: time unit to use to initially wait.";

@interface GGKDelayedSpacedPhotosViewController ()
@end

@implementation GGKDelayedSpacedPhotosViewController
- (void)getSavedTimerSettings {
//    [super getSavedTimerSettings];
//    self.numberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
//    self.timeUnitForTheInitialWaitTimeUnit = (GGKTimeUnit)[[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString];
//    self.numberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfPhotosToTakeKeyString];
//    self.numberOfTimeUnitsBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsBetweenPhotosKeyString];
//    self.timeUnitBetweenPhotosTimeUnit = (GGKTimeUnit)[[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString];
}
- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    
//    // An anchor.
//    [self.cameraPreviewView ggk_makeSize:CGSizeMake(820, 615)];
//    [self.cameraPreviewView ggk_makeBottomGap:0];
//    [self.cameraPreviewView ggk_makeLeftGap:0];
//    [self updatePreviewOrientation];
//    CGFloat aGap1 = 8;
//    
//    // An anchor.
//    CGFloat aWidth = 130;
//    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
//    [self.cameraRollButton ggk_makeBottomGap:aGap1];
//    [self.cameraRollButton ggk_makeRightGap:aGap1];
//    
//    [self.tipLabel ggk_makeTopGap:aGap1];
//    [self.tipLabel ggk_alignHorizontalCenterWithView:self.cameraRollButton];
//    
//    CGFloat aGap2 = 40;
//    
//    [self.startTimerBottomButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
//    CGFloat aHeight = self.startTimerBottomButton.superview.frame.size.height - self.tipLabel.frame.size.height - self.cameraRollButton.frame.size.height - self.cancelTimerButton.frame.size.height - aGap2 - (4 * aGap1);
//    [self.startTimerBottomButton ggk_makeHeight:aHeight];
//    [self.startTimerBottomButton ggk_alignRightEdgeWithView:self.cameraRollButton];
//    [self.startTimerBottomButton ggk_placeBelowView:self.tipLabel gap:aGap1];
//    
//    CGFloat aGap3 = 30;
//    
//    [self.cancelTimerButton ggk_makeWidth:(self.startTimerBottomButton.frame.size.width - aGap3)];
//    [self.cancelTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
//    [self.cancelTimerButton ggk_placeBelowView:self.startTimerBottomButton gap:aGap1];
}

- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    
//    // An anchor.
//    [self.cameraPreviewView ggk_makeSize:CGSizeMake(654, 872)];
//    [self.cameraPreviewView ggk_makeBottomGap:0];
//    [self.cameraPreviewView ggk_makeLeftGap:0];
//    [self updatePreviewOrientation];
//    CGFloat aGap1 = 8;
//    
//    CGFloat aWidth = self.cameraRollButton.superview.frame.size.width - self.cameraPreviewView.frame.size.width - (2 * aGap1);
//    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
//    [self.cameraRollButton ggk_makeBottomGap:aGap1];
//    [self.cameraRollButton ggk_makeRightGap:aGap1];
//    
//    [self.tipLabel ggk_alignTopEdgeWithView:self.cameraPreviewView];
//    [self.tipLabel ggk_alignHorizontalCenterWithView:self.cameraRollButton];
//    
//    CGFloat aGap2 = 50;
//    
//    [self.startTimerBottomButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
//    CGFloat aHeight = self.startTimerBottomButton.superview.frame.size.height - self.tipLabel.frame.origin.y - self.tipLabel.frame.size.height - self.cameraRollButton.frame.size.height - self.cancelTimerButton.frame.size.height - aGap2 - (3 * aGap1);
//    [self.startTimerBottomButton ggk_makeHeight:aHeight];
//    [self.startTimerBottomButton ggk_alignRightEdgeWithView:self.cameraRollButton];
//    [self.startTimerBottomButton ggk_placeBelowView:self.tipLabel gap:aGap1];
//    
//    CGFloat aGap3 = 20;
//    
//    [self.cancelTimerButton ggk_makeWidth:(self.startTimerBottomButton.frame.size.width - aGap3)];
//    [self.cancelTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
//    [self.cancelTimerButton ggk_placeBelowView:self.startTimerBottomButton gap:aGap1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Time-unit buttons.
//    [GGKUtilities addBorderOfColor:[UIColor blackColor] toView:self.timeUnitsToInitiallyWaitButton];

    // Set keys.
//    self.numberOfTimeUnitsToInitiallyWaitKeyString = GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString;
//    self.timeUnitForInitialWaitKeyString = GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString;
//    self.numberOfPhotosToTakeKeyString = GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString;
//    self.numberOfTimeUnitsBetweenPhotosKeyString = GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString;
//    self.timeUnitBetweenPhotosKeyString = GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString;
}
@end
