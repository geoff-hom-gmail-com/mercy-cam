//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosViewController.h"

#import "NSString+GGKAdditions.h"
#import "GGKUtilities.h"
#import "UIView+GGKAdditions.h"
const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger = 3;

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger = 2;

NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString = @"Take delayed photos: number of photos";

NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString = @"Take delayed photos: number of seconds to initially wait";

@interface GGKTakeDelayedPhotosViewController ()

@end

@implementation GGKTakeDelayedPhotosViewController

- (void)getSavedTimerSettings {
    [super getSavedTimerSettings];

    self.numberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
    self.timeUnitForTheInitialWaitTimeUnit = GGKTimeUnitSeconds;
    self.numberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfPhotosToTakeKeyString];
    self.numberOfTimeUnitsBetweenPhotosInteger = 0;
    self.timeUnitBetweenPhotosTimeUnit = GGKTimeUnitSeconds;
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString]) {
        
        self.numberOfTimeUnitsToInitiallyWaitTextField.text = [NSString stringWithFormat:@"%ld", (long)self.numberOfTimeUnitsToInitiallyWaitInteger];
        
        // "second(s), then take"
        NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:self.numberOfTimeUnitsToInitiallyWaitInteger];
        self.secondsLabel.text = [NSString stringWithFormat:@"%@, then take", aSecondsString];
    } else if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString]) {
        
        self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%ld", (long)self.numberOfPhotosToTakeInteger];
        
        // "photo(s)."
        NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:self.numberOfPhotosToTakeInteger];
        self.afterNumberOfPhotosTextFieldLabel.text = [NSString stringWithFormat:@"%@.", aPhotosString];
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    self.takePhotoRightProxyButtonWidthLayoutConstraint.constant = 212;
}
- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    self.takePhotoRightProxyButtonWidthLayoutConstraint.constant = 71;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [GGKUtilities matchFrameOfRotated90View:self.startTimerLeftButton withView:self.startTimerLeftProxyButton];
    [GGKUtilities matchFrameOfRotated90View:self.startTimerRightButton withView:self.startTimerRightProxyButton];
}
- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.maximumNumberOfTimeUnitsToInitiallyWaitInteger = 99;
    self.maximumNumberOfPhotosInteger = 99;
    self.maximumNumberOfTimeUnitsBetweenPhotosInteger = 99;
    
    // Set keys.
    self.numberOfTimeUnitsToInitiallyWaitKeyString = GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;
    self.timeUnitForInitialWaitKeyString = nil;
    self.numberOfPhotosToTakeKeyString = GGKTakeDelayedPhotosNumberOfPhotosKeyString;
    self.numberOfTimeUnitsBetweenPhotosKeyString = nil;
    self.timeUnitBetweenPhotosKeyString = nil;
    
    
    // Make side buttons.
    // this should be in abstract vc
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    aButton.titleLabel.font = self.startTimerLeftProxyButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.startTimerLeftProxyButton];
    self.startTimerLeftButton = aButton;
    aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    aButton.titleLabel.font = self.startTimerRightProxyButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.startTimerRightProxyButton];
    self.startTimerRightButton = aButton;
    NSString *aButtonTitleString = [self.startTimerBottomButton titleForState:UIControlStateNormal];
    for (UIButton *aButton in @[self.startTimerLeftButton, self.startTimerRightButton]) {
        aButton.backgroundColor = [UIColor whiteColor];
        [aButton setTitle:aButtonTitleString forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(playButtonSound) forControlEvents:UIControlEventTouchDown];
        [aButton addTarget:self action:@selector(startTimer) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:aButton];
    }
    self.startTimerLeftProxyButton.hidden = YES;
    self.startTimerRightProxyButton.hidden = YES;
    // Add border to take-photo buttons.
    NSArray *aButtonArray = @[self.startTimerLeftButton, self.startTimerRightButton, self.startTimerBottomButton];
    for (UIButton *aButton in aButtonArray) {
        [GGKUtilities addBorderOfColor:[UIColor clearColor] toView:aButton];
    }
    self.tipLabel.layer.cornerRadius = 3.0f;
    self.cancelTimerButton.layer.cornerRadius = 5.0f;
    self.timerSettingsView.layer.cornerRadius = 5.0f;
    
    // Orientation-specific layout constraints.
    self.portraitOnlyLayoutConstraintArray = @[self.takePhotoRightProxyButtonTopGapPortraitLayoutConstraint, self.tipLabelRightGapPortraitLayoutConstraint, self.previewViewAspectRatioPortraitLayoutConstraint];
    // Right proxy button's top neighbor: top layout guide.
    NSDictionary *aDictionary = @{@"topGuide":self.topLayoutGuide, @"rightProxy":self.startTimerRightProxyButton, @"tipLabel":self.tipLabel};
    NSArray *anArray1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[rightProxy]" options:0 metrics:nil views:aDictionary];
    // Tip label's right neighbor: right proxy button.
    NSArray *anArray2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[tipLabel]-[rightProxy]" options:0 metrics:nil views:aDictionary];
    // Camera-preview view: 4:3 aspect ratio.
    NSLayoutConstraint *aLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.cameraPreviewView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cameraPreviewView attribute:NSLayoutAttributeHeight multiplier:(4.0 / 3.0) constant:0];
    self.landscapeOnlyLayoutConstraintArray = @[anArray1[0], anArray2[0], aLayoutConstraint];
}
@end
