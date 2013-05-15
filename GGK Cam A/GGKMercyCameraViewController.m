//
//  GGKMercyCameraViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCameraViewController.h"

#import "GGKTakeAdvancedDelayedPhotosViewController.h"
#import "GGKTakeDelayedPhotosViewController.h"
#import "GGKTimeUnits.h"
#import "NSAttributedString+GGKAdditions.h"
#import "NSString+GGKAdditions.h"
#import "UIView+GGKAdditions.h"

//BOOL GGKCreateLaunchImages = YES;
BOOL GGKCreateLaunchImages = NO;

@interface GGKMercyCameraViewController ()

// Story: User reads examples using her most-recent settings. She has a better understanding of which option she wants, without having to try each. Also, she can think about them for the future. 
- (void)updateExamples;

@end

@implementation GGKMercyCameraViewController

- (IBAction)rateOrReview
{
    NSLog(@"rateOrReview");
    
    // Go to the App Store, to this app and the section for "Ratings and Reviews." Note that the app ID won't work prior to the app's first release, but one can test by using the ID of an app that has already been released.
    // App ID for Color Fever: 585564245
    // App ID for Mercy Camera!: 637772676
    // App ID for Perfect Potty: 615088461
    // App ID for Text Memory: 490464898
    NSString *theAppIDString = @"637772676";
    NSString *theITunesURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", theAppIDString];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:theITunesURL]];
}

- (void)updateExamples
{
    // "Wait X second(s), then take Y photo(s)."
    
    NSInteger theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger];
    
    NSInteger theTakeDelayedPhotosNumberOfPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString];
    
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theTakeDelayedPhotosNumberOfPhotosInteger];
    
    self.takeDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"\"Wait %d %@,\nthen take %d %@.\"", theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger, aSecondsString, theTakeDelayedPhotosNumberOfPhotosInteger, aPhotosString];
    
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
    
    self.takeAdvancedDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"\"Wait %d %@,\nthen take %d %@\nwith %d %@ between each photo.\"", theTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitInteger, theTimeUnitForTheInitialWaitString, theTakeAdvancedDelayedPhotosNumberOfPhotosInteger, aPhotosString, theTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosInteger, theTimeUnitBetweenPhotosString];
}

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    // An anchor.
    [self.hiLabel ggk_placeAtPoint:CGPointMake(92, 30)];
    
    [self.takeAPhotoButton ggk_placeBelowView:self.hiLabel gap:26];
    [self.takeAPhotoButton ggk_makeLeftGap:20];
    
    CGFloat aGap1Float = 50;
    
    [self.takeDelayedPhotosButton ggk_placeBelowView:self.takeAPhotoButton gap:aGap1Float];
    [self.takeDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
    
    [self.takeAdvancedDelayedPhotosButton ggk_placeBelowView:self.takeDelayedPhotosButton gap:aGap1Float];
    [self.takeAdvancedDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
    
    CGFloat aGap2Float = 13;
    
    [self.takeAPhotoExampleLabel ggk_placeRightOfView:self.takeAPhotoButton gap:aGap2Float];
    [self.takeAPhotoExampleLabel ggk_alignVerticalCenterWithView:self.takeAPhotoButton];
    
    [self.exampleLabel ggk_placeAboveView:self.takeAPhotoExampleLabel gap:8];
    [self.exampleLabel ggk_alignHorizontalCenterWithView:self.takeAPhotoExampleLabel];
    
    [self.takeDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeDelayedPhotosButton gap:aGap2Float];
    [self.takeDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeDelayedPhotosButton];
    
    [self.takeAdvancedDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeAdvancedDelayedPhotosButton gap:aGap2Float];
    [self.takeAdvancedDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeAdvancedDelayedPhotosButton];
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:18];
    CGFloat aWidth1Float = 196;
    
    // An anchor.
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    [self.helpTheCreatorsButton ggk_makeWidth:aWidth1Float];
    [self.helpTheCreatorsButton ggk_makeBottomGap:30];
    [self.helpTheCreatorsButton ggk_makeRightGap:20];
    
    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
    anAttributedString = [anAttributedString ggk_attributedStringWithFont:aFont];
    [self.rateThisAppButton setAttributedTitle:anAttributedString forState:UIControlStateNormal];
    [self.rateThisAppButton ggk_makeWidth:aWidth1Float];
    [self.rateThisAppButton ggk_placeAboveView:self.helpTheCreatorsButton gap:40];
    [self.rateThisAppButton ggk_alignRightEdgeWithView:self.helpTheCreatorsButton];
    
    
    // old stuff below
    
//    CGSize aSize = self.hiLabel.frame.size;
//    self.hiLabel.frame = CGRectMake(92, 30, aSize.width, aSize.height);
//    
//    CGFloat anX1 = 20;
//    aSize = self.takeAPhotoButton.frame.size;
//    self.takeAPhotoButton.frame = CGRectMake(anX1, 101, aSize.width, aSize.height);
//    
//    aSize = self.exampleLabel.frame.size;
//    self.exampleLabel.frame = CGRectMake(472, 131, aSize.width, aSize.height);
//    
//    CGFloat anX2 = 353;
//    aSize = self.takeAPhotoExampleLabel.frame.size;
//    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 166, aSize.width, aSize.height);
//    
//    aSize = self.takeDelayedPhotosButton.frame.size;
//    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 331, aSize.width, aSize.height);
//    
//    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
//    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 363, aSize.width, aSize.height);
//    
//    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
//    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 501, aSize.width, aSize.height);
//    
//    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
//    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 511, aSize.width, aSize.height);
//    
//    UIFont *aFont = [UIFont boldSystemFontOfSize:18];
//    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
//    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:anAttributedString];
//    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
//    [self.rateThisAppButton setAttributedTitle:aMutableAttributedString forState:UIControlStateNormal];
//    CGFloat anX3 = 808;
//    aSize = CGSizeMake(196, 60);
//    self.rateThisAppButton.frame = CGRectMake(anX3, 516, aSize.width, aSize.height);
//    
//    self.helpTheCreatorsButton.titleLabel.font = aFont;
//    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 615, aSize.width, aSize.height);
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    // An anchor.
    [self.hiLabel ggk_placeAtPoint:CGPointMake(92, 50)];
    
    [self.takeAPhotoButton ggk_placeBelowView:self.hiLabel gap:26];
    [self.takeAPhotoButton ggk_makeLeftGap:20];
    
    CGFloat aGap1Float = 50;
    
    [self.takeDelayedPhotosButton ggk_placeBelowView:self.takeAPhotoButton gap:aGap1Float];
    [self.takeDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
    
    [self.takeAdvancedDelayedPhotosButton ggk_placeBelowView:self.takeDelayedPhotosButton gap:aGap1Float];
    [self.takeAdvancedDelayedPhotosButton ggk_alignLeftEdgeWithView:self.takeAPhotoButton];
    
    CGFloat aGap2Float = 13;
    
    [self.takeAPhotoExampleLabel ggk_placeRightOfView:self.takeAPhotoButton gap:aGap2Float];
    [self.takeAPhotoExampleLabel ggk_alignVerticalCenterWithView:self.takeAPhotoButton];
    
    [self.exampleLabel ggk_placeAboveView:self.takeAPhotoExampleLabel gap:8];
    [self.exampleLabel ggk_alignHorizontalCenterWithView:self.takeAPhotoExampleLabel];
    
    [self.takeDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeDelayedPhotosButton gap:aGap2Float];
    [self.takeDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeDelayedPhotosButton];
    
    [self.takeAdvancedDelayedPhotosExampleLabel ggk_placeRightOfView:self.takeAdvancedDelayedPhotosButton gap:aGap2Float];
    [self.takeAdvancedDelayedPhotosExampleLabel ggk_alignVerticalCenterWithView:self.takeAdvancedDelayedPhotosButton];
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:22];
    CGFloat aWidth1Float = 237;
    
    // An anchor.
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    [self.helpTheCreatorsButton ggk_makeWidth:aWidth1Float];
    [self.helpTheCreatorsButton ggk_makeBottomGap:aGap1Float];
    [self.helpTheCreatorsButton ggk_makeRightGap:20];
    
    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
    anAttributedString = [anAttributedString ggk_attributedStringWithFont:aFont];
    [self.rateThisAppButton setAttributedTitle:anAttributedString forState:UIControlStateNormal];
    [self.rateThisAppButton ggk_makeWidth:aWidth1Float];
    [self.rateThisAppButton ggk_placeAboveView:self.helpTheCreatorsButton gap:aGap1Float];
    [self.rateThisAppButton ggk_alignRightEdgeWithView:self.helpTheCreatorsButton];
    
    // old stuff below
    
//    CGSize aSize = self.hiLabel.frame.size;
//    self.hiLabel.frame = CGRectMake(92, 50, aSize.width, aSize.height);
    
//    CGFloat anX1 = 20;
//    aSize = self.takeAPhotoButton.frame.size;
//    self.takeAPhotoButton.frame = CGRectMake(anX1, 120, aSize.width, aSize.height);
//    
//    aSize = self.exampleLabel.frame.size;
//    self.exampleLabel.frame = CGRectMake(472, 151, aSize.width, aSize.height);
//    
//    CGFloat anX2 = 353;
//    aSize = self.takeAPhotoExampleLabel.frame.size;
//    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 186, aSize.width, aSize.height);
//    
//    aSize = self.takeDelayedPhotosButton.frame.size;
//    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 350, aSize.width, aSize.height);
//    
//    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
//    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 382, aSize.width, aSize.height);
//    
//    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
//    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 520, aSize.width, aSize.height);
//    
//    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
//    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 530, aSize.width, aSize.height);
//    
//    UIFont *aFont = [UIFont boldSystemFontOfSize:22];
//    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
//    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:anAttributedString];
//    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
//    [self.rateThisAppButton setAttributedTitle:aMutableAttributedString forState:UIControlStateNormal];
//    CGFloat anX3 = 511;
//    aSize = CGSizeMake(237, 60);
//    self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
//        
//    self.helpTheCreatorsButton.titleLabel.font = aFont;
//    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 851, aSize.width, aSize.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Make UI blank so we can make launch images via screenshot.
    if (GGKCreateLaunchImages) {
        
        self.navigationItem.title = @"";
        for (UIView *aSubView in self.view.subviews) {
            
            aSubView.hidden = YES;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    
    [self updateExamples];
}

@end
