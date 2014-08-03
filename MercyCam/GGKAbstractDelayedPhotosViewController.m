//
//  GGKTakeDelayedPhotosAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKAbstractDelayedPhotosViewController.h"

#import "GGKLongTermViewController.h"
#import "NSDate+GGKAdditions.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"
#import "GGKUtilities.h"

@interface GGKAbstractDelayedPhotosViewController ()


// The gesture recognizer for detecting "when the user taps the screen" while allowing those taps through (e.g., on a button). (May not detect taps on the navigation bar or above.)
// Need for enabling/disabling.
@property (nonatomic, strong) UITapGestureRecognizer *anyTapOnScreenGestureRecognizer;


// The number of seconds to wait before dimming the screen and hiding the camera preview.
@property (nonatomic, assign) NSInteger numberOfSecondsToWaitBeforeDimmingTheScreenInteger;

// A transparent view for detecting "when the user taps the screen" but not letting those taps through.
// Needed for hiding/showing (i.e., not-detecting vs. detecting).
@property (nonatomic, strong) UIView *overlayView;

// The screen brightness before dimming. Need for restoring.
@property (nonatomic, assign) CGFloat previousBrightnessFloat;





@end

@implementation GGKAbstractDelayedPhotosViewController
- (void)dealloc {
}

- (void)getSavedTimerSettings
{
    
    NSInteger theNumberOfTimeUnitsToWaitBeforeDimmingTheScreenInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermNumberOfTimeUnitsKeyString];
    GGKTimeUnit aTimeUnit = (GGKTimeUnit)[[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermTimeUnitKeyString];
    self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger = theNumberOfTimeUnitsToWaitBeforeDimmingTheScreenInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:aTimeUnit];
    NSLog(@"TDPAVC secToWaitBeforeDimScreen:%ld", (long)self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger);

}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a (disabled) gesture recognizer to detect taps while letting them through.
    UITapGestureRecognizer *aTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleATapOnScreen:)];
    aTapGestureRecognizer.cancelsTouchesInView = NO;
    aTapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:aTapGestureRecognizer];
    aTapGestureRecognizer.delegate = self;
    self.anyTapOnScreenGestureRecognizer = aTapGestureRecognizer;
    
    // Add an (inactive) overlay view with another gesture recognizer to detect taps but not let them through.
    UIView *anOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
    aTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleATapOnScreen:)];
    [anOverlayView addGestureRecognizer:aTapGestureRecognizer];
    anOverlayView.hidden = YES;
    [self.view addSubview:anOverlayView];
    self.overlayView = anOverlayView;
}
@end
