//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCamViewController.h"

#import "GGKTakeAdvancedDelayedPhotosViewController.h"
#import "GGKTakeDelayedPhotosViewController.h"
#import "GGKTimeUnits.h"
#import "NSAttributedString+GGKAdditions.h"
#import "NSString+GGKAdditions.h"
#import "UIView+GGKAdditions.h"

//BOOL GGKCreateLaunchImages = YES;
BOOL GGKCreateLaunchImages = NO;

@interface GGKMercyCamViewController ()
// Story: User reads examples using her most-recent settings. She has a better understanding of which option she wants, without having to try each. Also, she can think about them for the future. 
- (void)updateExamples;
@end

@implementation GGKMercyCamViewController
- (void)handleViewWillAppearToUser {
    [super handleViewWillAppearToUser];
    [self updateExamples];
}
- (void)updateExamples {
    // "Wait X second(s), then take Y photo(s)."
    NSInteger theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger];
    NSInteger theTakeDelayedPhotosNumberOfPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString];
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theTakeDelayedPhotosNumberOfPhotosInteger];
    self.takeDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"Wait %ld %@, then take %ld %@.", (long)theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger, aSecondsString, (long)theTakeDelayedPhotosNumberOfPhotosInteger, aPhotosString];
    // "Wait X second(s)/day(s)/etc., then take Y photo(s) with Z second(s)/day(s)/etc. between each photo."
    NSInteger theTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString];
    NSInteger theTimeUnitForTheInitialWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString];
    NSString *theTimeUnitForTheInitialWaitString = [GGKTimeUnits stringForTimeUnit:(GGKTimeUnit)theTimeUnitForTheInitialWaitInteger];
    theTimeUnitForTheInitialWaitString = [theTimeUnitForTheInitialWaitString ggk_stringPerhapsWithoutS:theTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitInteger];
    NSInteger theTakeAdvancedDelayedPhotosNumberOfPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString];
    aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theTakeAdvancedDelayedPhotosNumberOfPhotosInteger];
    NSInteger theTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString];
    NSInteger theTimeUnitBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString];
    NSString *theTimeUnitBetweenPhotosString = [GGKTimeUnits stringForTimeUnit:(GGKTimeUnit)theTimeUnitBetweenPhotosInteger];
    theTimeUnitBetweenPhotosString = [theTimeUnitBetweenPhotosString ggk_stringPerhapsWithoutS:theTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosInteger];
    self.takeAdvancedDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"Wait %ld %@, then take %ld %@ with %ld %@ between each photo.", (long)theTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitInteger, theTimeUnitForTheInitialWaitString, (long)theTakeAdvancedDelayedPhotosNumberOfPhotosInteger, aPhotosString, (long)theTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosInteger, theTimeUnitBetweenPhotosString];
}
//- (void)updateLayoutForLandscape {
//    [super updateLayoutForLandscape];
//    
//    // An anchor.
//    [self.hiLabel ggk_makeOrigin:CGPointMake(92, 30)];
//    
//    [self.takeAPhotoButton ggk_placeBelowView:self.hiLabel gap:26];
//    [self.takeAPhotoButton ggk_makeLeftGap:20];
//    
//    CGFloat aGap1Float = 50;
//    
//    [self.takeDelayedPhotosButton ggk_placeBelowView:self.takeAPhotoButton gap:aGap1Float];
//    [self.takeDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
//    
//    [self.takeAdvancedDelayedPhotosButton ggk_placeBelowView:self.takeDelayedPhotosButton gap:aGap1Float];
//    [self.takeAdvancedDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
//    
//    CGFloat aGap2Float = 13;
//    
//    [self.takeAPhotoExampleLabel ggk_placeRightOfView:self.takeAPhotoButton gap:aGap2Float];
//    [self.takeAPhotoExampleLabel ggk_alignVerticalCenterWithView:self.takeAPhotoButton];
//    
//    [self.exampleLabel ggk_placeAboveView:self.takeAPhotoExampleLabel gap:8];
//    [self.exampleLabel ggk_alignHorizontalCenterWithView:self.takeAPhotoExampleLabel];
//    
//    [self.takeDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeDelayedPhotosButton gap:aGap2Float];
//    [self.takeDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeDelayedPhotosButton];
//    
//    [self.takeAdvancedDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeAdvancedDelayedPhotosButton gap:aGap2Float];
//    [self.takeAdvancedDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeAdvancedDelayedPhotosButton];
//    
//    UIFont *aFont = [UIFont boldSystemFontOfSize:18];
//    CGFloat aWidth1Float = 196;
//    
//    // An anchor.
//    self.helpTheCreatorsButton.titleLabel.font = aFont;
//    [self.helpTheCreatorsButton ggk_makeWidth:aWidth1Float];
//    [self.helpTheCreatorsButton ggk_makeBottomGap:30];
//    [self.helpTheCreatorsButton ggk_makeRightGap:20];
//    
//    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
//    anAttributedString = [anAttributedString ggk_attributedStringWithFont:aFont];
//    [self.rateThisAppButton setAttributedTitle:anAttributedString forState:UIControlStateNormal];
//    [self.rateThisAppButton ggk_makeWidth:aWidth1Float];
//    [self.rateThisAppButton ggk_placeAboveView:self.helpTheCreatorsButton gap:40];
//    [self.rateThisAppButton ggk_alignRightEdgeWithView:self.helpTheCreatorsButton];
//}
//- (void)updateLayoutForPortrait {
//    [super updateLayoutForPortrait];
//    // An anchor.
//    [self.hiLabel ggk_makeOrigin:CGPointMake(92, 50)];
//    
//    [self.takeAPhotoButton ggk_placeBelowView:self.hiLabel gap:26];
//    [self.takeAPhotoButton ggk_makeLeftGap:20];
//    
//    CGFloat aGap1Float = 50;
//    
//    [self.takeDelayedPhotosButton ggk_placeBelowView:self.takeAPhotoButton gap:aGap1Float];
//    [self.takeDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
//    
//    [self.takeAdvancedDelayedPhotosButton ggk_placeBelowView:self.takeDelayedPhotosButton gap:aGap1Float];
//    [self.takeAdvancedDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
//    
//    CGFloat aGap2Float = 13;
//    
//    [self.takeAPhotoExampleLabel ggk_placeRightOfView:self.takeAPhotoButton gap:aGap2Float];
//    [self.takeAPhotoExampleLabel ggk_alignVerticalCenterWithView:self.takeAPhotoButton];
//    
//    [self.exampleLabel ggk_placeAboveView:self.takeAPhotoExampleLabel gap:8];
//    [self.exampleLabel ggk_alignHorizontalCenterWithView:self.takeAPhotoExampleLabel];
//    
//    [self.takeDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeDelayedPhotosButton gap:aGap2Float];
//    [self.takeDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeDelayedPhotosButton];
//    
//    [self.takeAdvancedDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeAdvancedDelayedPhotosButton gap:aGap2Float];
//    [self.takeAdvancedDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeAdvancedDelayedPhotosButton];
    
//    UIFont *aFont = [UIFont boldSystemFontOfSize:22];
//    CGFloat aWidth1Float = 237;
    
    // An anchor.
//    self.helpTheCreatorsButton.titleLabel.font = aFont;
//    [self.helpTheCreatorsButton ggk_makeWidth:aWidth1Float];
//    [self.helpTheCreatorsButton ggk_makeBottomGap:aGap1Float];
//    [self.helpTheCreatorsButton ggk_makeRightGap:20];
    
//    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
//    anAttributedString = [anAttributedString ggk_attributedStringWithFont:aFont];
//    [self.rateThisAppButton setAttributedTitle:anAttributedString forState:UIControlStateNormal];
//    [self.rateThisAppButton ggk_makeWidth:aWidth1Float];
//    [self.rateThisAppButton ggk_placeAboveView:self.helpTheCreatorsButton gap:aGap1Float];
//    [self.rateThisAppButton ggk_alignRightEdgeWithView:self.helpTheCreatorsButton];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Make UI blank so we can make launch images via screenshot.
    if (GGKCreateLaunchImages) {
        self.navigationItem.title = @"";
        for (UIView *aSubView in self.view.subviews) {
            aSubView.hidden = YES;
        }
    }
}
@end
