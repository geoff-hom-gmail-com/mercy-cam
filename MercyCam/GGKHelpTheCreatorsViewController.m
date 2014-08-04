//
//  Created by Geoff Hom on 5/1/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKHelpTheCreatorsViewController.h"

#import "GGKMercyCamAppDelegate.h"
#import "GGKUtilities.h"
#import "UIView+GGKAdditions.h"
#import <StoreKit/StoreKit.h>

NSString *GGKNumberOfStarsPurchasedNumberKeyString = @"Number of stars purchased";

// Unicode for the emoji, "White Medium Star."
NSString *WhiteMediumStarEmojiString = @"\u2B50";

@implementation GGKHelpTheCreatorsViewController
- (IBAction)emailTheCreators {
    MFMailComposeViewController *aMailComposeViewController = [[MFMailComposeViewController alloc] init];
    aMailComposeViewController.mailComposeDelegate = self;
    NSArray *theToRecipientsArray = @[@"geoffhom@gmail.com"];
    [aMailComposeViewController setToRecipients:theToRecipientsArray];
    [aMailComposeViewController setSubject:@"MercyCam"];
    // Include app version.
    NSString *theVersionString = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    UIDevice *theDevice = [UIDevice currentDevice];    
    NSString *theMessageBody = [NSString stringWithFormat:@"(Using MercyCam, version %@, on an %@ running %@ %@.)"
        "\n\nComments:", theVersionString, theDevice.localizedModel, theDevice.systemName, theDevice.systemVersion];
    [aMailComposeViewController setMessageBody:theMessageBody isHTML:NO];
    [self presentViewController:aMailComposeViewController animated:YES completion:nil];
}
- (IBAction)giveADollar {
    BOOL thePaymentWasAdded = [self.inAppPurchaseManager buyProductWithID:GGKGiveDollarProductIDString];
    if (thePaymentWasAdded) {
        self.view.window.userInteractionEnabled = NO;
        [self.giveADollarButton setTitle:@"Giving…" forState:UIControlStateDisabled];
        self.giveADollarButton.enabled = NO;
    }
}
- (void)inAppPurchaseManagerDidHandleCompletedTransaction:(id)sender {
    // Store the star.
    NSNumber *theNumberOfStarsPurchasedNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKNumberOfStarsPurchasedNumberKeyString];
    if (theNumberOfStarsPurchasedNumber == nil) {
        theNumberOfStarsPurchasedNumber = @0;
    }
    NSInteger theNumberOfStarsPurchasedInteger = [theNumberOfStarsPurchasedNumber integerValue];
    theNumberOfStarsPurchasedInteger++;
    theNumberOfStarsPurchasedNumber = [NSNumber numberWithInteger:theNumberOfStarsPurchasedInteger];
    [[NSUserDefaults standardUserDefaults] setObject:theNumberOfStarsPurchasedNumber forKey:GGKNumberOfStarsPurchasedNumberKeyString];
    [self showStars];
    // Notify user.
    UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:@"Donation Complete" message:@"Thank you!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [anAlertView show];
    [self updateForAllowingDonation];
}
- (void)inAppPurchaseManagerDidHandleFailedTransaction:(id)sender {
    [self updateForAllowingDonation];
}
- (void)inAppPurchaseManagerDidReceiveProducts:(id)sender {
    // Assuming only one product for now.
    SKProduct *aProduct = self.inAppPurchaseManager.availableProducts[0];
    if ([aProduct.productIdentifier isEqualToString:GGKGiveDollarProductIDString]) {
        // Show the price in local currency. Enable the purchase button.
        NSNumberFormatter *aNumberFormatter = [[NSNumberFormatter alloc] init];
        [aNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [aNumberFormatter setLocale:aProduct.priceLocale];
        NSString *aFormattedString = [aNumberFormatter stringFromNumber:aProduct.price];
//        NSLog(@"inAppPurchaseManagerDidReceiveProducts price: %@", aFormattedString);
        NSString *aString = [NSString stringWithFormat:@"Give %@", aFormattedString];
        [self.giveADollarButton setTitle:aString forState:UIControlStateNormal];
        [self.giveADollarButton setTitle:aString forState:UIControlStateDisabled];
        self.giveADollarButton.enabled = YES;
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)theViewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [theViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)rateOrReview {
    NSLog(@"HTCVC rateOrReview");
    // Go to the App Store, to this app. Note that the app ID won't work prior to the app's first release, but one can test by using the ID of an app that has already been released.
    // App ID for Color Fever: 585564245
    // App ID for MercyCam: 637772676
    // App ID for Perfect Potty: 615088461
    // App ID for Text Memory: 490464898
    NSString *theAppIDString = @"637772676";
    NSString *theITunesURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", theAppIDString];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:theITunesURL]];
}
- (void)showStars {
    NSNumber *theNumberOfStarsPurchasedNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKNumberOfStarsPurchasedNumberKeyString];
    // For testing.
//    theNumberOfStarsPurchasedNumber = @7;
//    theNumberOfStarsPurchasedNumber = nil;
    NSString *aString = @"(No stars yet.)";
    if (theNumberOfStarsPurchasedNumber != nil) {
        NSInteger theNumberOfStarsPurchasedInteger = [theNumberOfStarsPurchasedNumber integerValue];
        NSMutableString *aMutableString = [[NSMutableString alloc] initWithCapacity:10];
        for (int i = 0; i < theNumberOfStarsPurchasedInteger; i++) {
            [aMutableString appendString:WhiteMediumStarEmojiString];
        }
        aString = [aMutableString copy];
    }
    self.starsLabel.text = aString;
}
- (void)updateForAllowingDonation {
    NSString *theNormalTitle = [self.giveADollarButton titleForState:UIControlStateNormal];
    [self.giveADollarButton setTitle:theNormalTitle forState:UIControlStateDisabled];
    
    self.giveADollarButton.enabled = YES;
    self.view.window.userInteractionEnabled = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Set up in-app purchase.
    GGKMercyCamAppDelegate *aCamAppDelegate = (GGKMercyCamAppDelegate *)[UIApplication sharedApplication].delegate;
    self.inAppPurchaseManager = aCamAppDelegate.inAppPurchaseManager;
    self.inAppPurchaseManager.delegate = self;
    [self.inAppPurchaseManager requestProductData];
    [self showStars];
    // Borders and corners.
    [GGKUtilities addBorderOfColor:[UIColor blackColor] toView:self.giveADollarButton];
    NSArray *aViewArray = @[self.donateView, self.emailTheCreatorsButton, self.rateUsButton];
    for (UIView *aView in aViewArray) {
        aView.layer.cornerRadius = 3.0f;
    }
}
@end
