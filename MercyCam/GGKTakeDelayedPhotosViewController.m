//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosViewController.h"

#import "NSString+GGKAdditions.h"
#import "UIView+GGKAdditions.h"

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger = 3;

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger = 2;

NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString = @"Take delayed photos: number of photos";

NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString = @"Take delayed photos: number of seconds to initially wait";

@interface GGKTakeDelayedPhotosViewController ()

@end

@implementation GGKTakeDelayedPhotosViewController

- (void)getSavedTimerSettings
{
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

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    // An anchor.
    [self.cameraPreviewView ggk_makeSize:CGSizeMake(816, 612)];
    [self.cameraPreviewView ggk_makeBottomGap:0];
    [self.cameraPreviewView ggk_makeLeftGap:0];
    [self updatePreviewOrientation];
    
    CGFloat aWidth = 130;
    CGFloat aGap1 = 8;
    
    // An anchor.
    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
    [self.cameraRollButton ggk_makeBottomGap:aGap1];
    [self.cameraRollButton ggk_makeRightGap:aGap1];
    
    CGFloat aGap2 = 40;
    
    [self.startTimerButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
    CGFloat aHeight = self.startTimerButton.superview.frame.size.height - self.cameraRollButton.frame.size.height - self.cancelTimerButton.frame.size.height - aGap2 - (3 * aGap1);
    [self.startTimerButton ggk_makeHeight:aHeight];
    [self.startTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.startTimerButton ggk_makeTopGap:aGap1];
    
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.focusLabel ggk_makeSize:CGSizeMake(113, 50)];
    [self.focusLabel ggk_makeTopGap:aGap1];
    [self.focusLabel ggk_placeLeftOfView:self.startTimerButton gap:aGap1];
    
    CGFloat aGap3 = 30;
    
    [self.cancelTimerButton ggk_makeWidth:(self.startTimerButton.frame.size.width - aGap3)];
    [self.cancelTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.cancelTimerButton ggk_placeBelowView:self.startTimerButton gap:aGap1];
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    // An anchor.
    [self.cameraPreviewView ggk_makeSize:CGSizeMake(651, 868)];
    [self.cameraPreviewView ggk_makeBottomGap:0];
    [self.cameraPreviewView ggk_makeLeftGap:0];
    [self updatePreviewOrientation];
    CGFloat aWidth = 101;
    CGFloat aGap1 = 8;
    
    // An anchor.
    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
    [self.cameraRollButton ggk_makeBottomGap:aGap1];
    [self.cameraRollButton ggk_makeRightGap:aGap1];
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.focusLabel ggk_makeSize:CGSizeMake(94, 38)];
    [self.focusLabel ggk_makeTopGap:aGap1];
    [self.focusLabel ggk_alignHorizontalCenterWithView:self.cameraRollButton];
    
    CGFloat aGap2 = 40;
    
    [self.startTimerButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
    CGFloat aHeight = self.startTimerButton.superview.frame.size.height - self.cameraRollButton.frame.size.height - self.cancelTimerButton.frame.size.height - aGap2 - self.focusLabel.frame.size.height - (4 * aGap1);
    [self.startTimerButton ggk_makeHeight:aHeight];
    [self.startTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.startTimerButton ggk_placeBelowView:self.focusLabel gap:aGap1];
    
    CGFloat aGap3 = 20;
    
    [self.cancelTimerButton ggk_makeWidth:(self.startTimerButton.frame.size.width - aGap3)];
    [self.cancelTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.cancelTimerButton ggk_placeBelowView:self.startTimerButton gap:aGap1];
}

- (void)viewDidLoad
{    
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
}

@end
