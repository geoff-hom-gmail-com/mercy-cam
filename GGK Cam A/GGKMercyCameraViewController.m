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
#import "NSString+GGKAdditions.h"
#import "NSUserDefaults+GGKAdditions.h"

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
    NSInteger theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString ifNil:GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger];
    
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger];
    
    NSInteger theTakeDelayedPhotosNumberOfPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString ifNil:GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger];
    
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theTakeDelayedPhotosNumberOfPhotosInteger];
    
    self.takeDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"\"Wait %d %@,\nthen take %d %@.\"", theTakeDelayedPhotosNumberOfSecondsToInitiallyWaitInteger, aSecondsString, theTakeDelayedPhotosNumberOfPhotosInteger, aPhotosString];
    
    NSInteger theTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger];
    
    NSInteger theTimeUnitForTheInitialWaitInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit];
    NSString *theTimeUnitForTheInitialWaitString = [GGKTimeUnitsTableViewController stringForTimeUnit:(GGKTimeUnit)theTimeUnitForTheInitialWaitInteger];
    theTimeUnitForTheInitialWaitString = [theTimeUnitForTheInitialWaitString ggk_stringPerhapsWithoutS:theTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitInteger];
    
    NSInteger theTakeAdvancedDelayedPhotosNumberOfPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger];
    
    NSInteger theTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger];
    
    NSInteger theTimeUnitBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] ggk_integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString ifNil:GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit];
    NSString *theTimeUnitBetweenPhotosString = [GGKTimeUnitsTableViewController stringForTimeUnit:(GGKTimeUnit)theTimeUnitBetweenPhotosInteger];
    
    // using aPhotosString 2 times, just for testing
    self.takeAdvancedDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"\"Wait %d %@,\nthen take %d %@\nwith %d %@ between each photo.\"", theTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitInteger, theTimeUnitForTheInitialWaitString, theTakeAdvancedDelayedPhotosNumberOfPhotosInteger, aPhotosString, theTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosInteger, theTimeUnitBetweenPhotosString];
}

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    CGSize aSize = self.hiLabel.frame.size;
    self.hiLabel.frame = CGRectMake(92, 30, aSize.width, aSize.height);
    
    CGFloat anX1 = 20;
    aSize = self.takeAPhotoButton.frame.size;
    self.takeAPhotoButton.frame = CGRectMake(anX1, 101, aSize.width, aSize.height);
    
    aSize = self.exampleLabel.frame.size;
    self.exampleLabel.frame = CGRectMake(472, 131, aSize.width, aSize.height);
    
    CGFloat anX2 = 353;
    aSize = self.takeAPhotoExampleLabel.frame.size;
    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 166, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosButton.frame.size;
    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 331, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 363, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 501, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 511, aSize.width, aSize.height);
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:18];
    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:anAttributedString];
    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
    [self.rateThisAppButton setAttributedTitle:aMutableAttributedString forState:UIControlStateNormal];
    CGFloat anX3 = 808;
    aSize = CGSizeMake(196, 60);
    self.rateThisAppButton.frame = CGRectMake(anX3, 516, aSize.width, aSize.height);
    
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 615, aSize.width, aSize.height);
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    CGSize aSize = self.hiLabel.frame.size;
    self.hiLabel.frame = CGRectMake(92, 50, aSize.width, aSize.height);
    
    CGFloat anX1 = 20;
    aSize = self.takeAPhotoButton.frame.size;
    self.takeAPhotoButton.frame = CGRectMake(anX1, 120, aSize.width, aSize.height);
    
    aSize = self.exampleLabel.frame.size;
    self.exampleLabel.frame = CGRectMake(472, 151, aSize.width, aSize.height);
    
    CGFloat anX2 = 353;
    aSize = self.takeAPhotoExampleLabel.frame.size;
    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 186, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosButton.frame.size;
    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 350, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 382, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 520, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 530, aSize.width, aSize.height);
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:22];
    NSAttributedString *anAttributedString = [self.rateThisAppButton attributedTitleForState:UIControlStateNormal];
    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:anAttributedString];
    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
    [self.rateThisAppButton setAttributedTitle:aMutableAttributedString forState:UIControlStateNormal];
    CGFloat anX3 = 511;
    aSize = CGSizeMake(237, 60);
    self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
        
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 851, aSize.width, aSize.height);
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
