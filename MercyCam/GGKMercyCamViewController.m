//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCamViewController.h"

#import "GGKDelayedPhotosModel.h"
#import "GGKMercyCamAppDelegate.h"
#import "GGKTakeAdvancedDelayedPhotosViewController.h"
#import "GGKTimeUnits.h"
#import "NSAttributedString+GGKAdditions.h"
#import "NSString+GGKAdditions.h"
#import "UIView+GGKAdditions.h"

//BOOL GGKCreateLaunchImages = YES;
BOOL GGKCreateLaunchImages = NO;

@interface GGKMercyCamViewController ()
@end

@implementation GGKMercyCamViewController
- (void)updateUI {
    [super updateUI];
    // "Wait X second(s), then take Y photo(s)."
    NSInteger theDelayedPhotosNumberOfSecondsToWaitInteger = self.delayedPhotosModel.numberOfSecondsToWaitInteger;
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theDelayedPhotosNumberOfSecondsToWaitInteger];
    NSInteger theDelayedPhotosNumberOfPhotosToTakeInteger = self.delayedPhotosModel.numberOfPhotosToTakeInteger;
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theDelayedPhotosNumberOfPhotosToTakeInteger];
    self.takeDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"Wait %ld %@, then take %ld %@.", (long)theDelayedPhotosNumberOfSecondsToWaitInteger, aSecondsString, (long)theDelayedPhotosNumberOfPhotosToTakeInteger, aPhotosString];

    
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Make UI blank so we can make launch images via screenshot.
    if (GGKCreateLaunchImages) {
        self.navigationItem.title = @"";
        for (UIView *aSubView in self.view.subviews) {
            aSubView.hidden = YES;
        }
    }
    GGKMercyCamAppDelegate *theAppDelegate = (GGKMercyCamAppDelegate *)[UIApplication sharedApplication].delegate;
    self.delayedPhotosModel = theAppDelegate.delayedPhotosModel;
}
@end
