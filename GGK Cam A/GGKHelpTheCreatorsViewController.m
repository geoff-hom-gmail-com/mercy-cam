//
//  GGKHelpTheCreatorsViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/1/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKHelpTheCreatorsViewController.h"

#import "GGKCamAppDelegate.h"
#import "UIView+GGKAdditions.h"
#import <StoreKit/StoreKit.h>

NSString *GGKNumberOfStarsPurchasedNumberKeyString = @"Number of stars purchased";

// Unicode for the emoji, "White Medium Star."
NSString *WhiteMediumStarEmojiString = @"\u2B50";

@interface GGKHelpTheCreatorsViewController ()

// For getting product info from the App Store, and for purchasing products.
@property (nonatomic, strong) GGKInAppPurchaseManager *inAppPurchaseManager;

// Show the number of thank-you stars. (One star per dollar given.)
- (void)showStars;

// Story: User sees UI and knows she can tap "Give $0.99."
- (void)updateForAllowingDonation;

@end

@implementation GGKHelpTheCreatorsViewController

- (IBAction)emailTheCreators
{
    MFMailComposeViewController *aMailComposeViewController = [[MFMailComposeViewController alloc] init];
    aMailComposeViewController.mailComposeDelegate = self;
    
    NSArray *theToRecipientsArray = @[@"geoffhom@gmail.com"];
    [aMailComposeViewController setToRecipients:theToRecipientsArray];
    
    [aMailComposeViewController setSubject:@"Mercy Camera"];
    
    // Include app version.
    NSString *theVersionString = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    UIDevice *theDevice = [UIDevice currentDevice];    
    NSString *theMessageBody = [NSString stringWithFormat:@"(Using Mercy Camera, version %@, on an %@ running %@ %@.)"
        "\n\nFeedback:", theVersionString, theDevice.localizedModel, theDevice.systemName, theDevice.systemVersion];
    [aMailComposeViewController setMessageBody:theMessageBody isHTML:NO];
    
    [self presentViewController:aMailComposeViewController animated:YES completion:nil];
}

- (IBAction)giveADollar
{
    BOOL thePaymentWasAdded = [self.inAppPurchaseManager buyProductWithID:GGKGiveDollarProductIDString];
    if (thePaymentWasAdded) {
        
        self.view.window.userInteractionEnabled = NO;
        [self.giveADollarButton setTitle:@"Giving…" forState:UIControlStateDisabled];
        self.giveADollarButton.enabled = NO;
    }
}

- (void)inAppPurchaseManagerDidHandleCompletedTransaction:(id)sender
{
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

- (void)inAppPurchaseManagerDidHandleFailedTransaction:(id)sender
{
    [self updateForAllowingDonation];
}

- (void)inAppPurchaseManagerDidReceiveProducts:(id)sender
{
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
        
        aString = [NSString stringWithFormat:@"You can give %@ at a time. Each time you give, you'll see a thank-you star (%@) below.", aFormattedString, WhiteMediumStarEmojiString];
        self.giveADollarLabel.text = aString;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)theViewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [theViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rateOrReview
{
    NSLog(@"HTCVC rateOrReview");
    
    // Go to the App Store, to this app and the section for "Ratings and Reviews." Note that the app ID won't work prior to the app's first release, but one can test by using the ID of an app that has already been released.
    // App ID for Color Fever: 585564245
    // App ID for Mercy Camera!: 637772676
    // App ID for Perfect Potty: 615088461
    // App ID for Text Memory: 490464898
    NSString *theAppIDString = @"637772676";
    NSString *theITunesURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", theAppIDString];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:theITunesURL]];
}

- (void)showStars
{
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

- (void)updateForAllowingDonation
{
    NSString *theNormalTitle = [self.giveADollarButton titleForState:UIControlStateNormal];
    [self.giveADollarButton setTitle:theNormalTitle forState:UIControlStateDisabled];
    
    self.giveADollarButton.enabled = YES;
    self.view.window.userInteractionEnabled = YES;
}

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    CGFloat aGap1 = 40;
    
    // An anchor.
    [self.greeting1Label ggk_makeTopGap:aGap1];
    [self.greeting1Label ggk_alignHorizontalCenterWithView:self.greeting1Label.superview];
    
    CGFloat aGap2 = 30;
    
    [self.greeting2Label ggk_placeBelowView:self.greeting1Label gap:aGap2];
    [self.greeting2Label ggk_makeX:55];
    
    // An anchor.
    [self.greeting3Label ggk_alignTopEdgeWithView:self.greeting2Label];
    [self.greeting3Label ggk_makeX:546];
    
    CGFloat aGap3 = 70;
    
    [self.rateUsHeaderLabel ggk_placeBelowView:self.greeting2Label gap:aGap3];
    [self.rateUsHeaderLabel ggk_makeLeftGap:20];
    
    CGFloat aGap4 = 8;
    
    [self.rateUsTextLabel ggk_placeBelowView:self.rateUsHeaderLabel gap:aGap4];
    [self.rateUsTextLabel ggk_alignLeftEdgeWithView:self.rateUsHeaderLabel];
    
    CGFloat aGap5 = 15;
    
    [self.rateUsButton ggk_placeBelowView:self.rateUsTextLabel gap:aGap5];
    [self.rateUsButton ggk_makeX:155];
    
    [self.donateHeaderLabel ggk_placeBelowView:self.rateUsButton gap:aGap1];
    [self.donateHeaderLabel ggk_alignLeftEdgeWithView:self.rateUsTextLabel];
    
    [self.donateTextLabel ggk_placeBelowView:self.donateHeaderLabel gap:aGap4];
    [self.donateTextLabel ggk_alignLeftEdgeWithView:self.donateHeaderLabel];
    
    [self.giveADollarLabel ggk_placeBelowView:self.donateTextLabel gap:aGap2];
    [self.giveADollarLabel ggk_alignLeftEdgeWithView:self.donateTextLabel];
    
    [self.giveADollarButton ggk_alignTopEdgeWithView:self.giveADollarLabel];
    [self.giveADollarButton ggk_makeX:469];
    
    [self.starsLabel ggk_placeBelowView:self.giveADollarLabel gap:aGap2];
    [self.starsLabel ggk_alignLeftEdgeWithView:self.giveADollarLabel];
    
    [self.giveFeedbackHeaderLabel ggk_alignTopEdgeWithView:self.rateUsHeaderLabel];
    [self.giveFeedbackHeaderLabel ggk_alignLeftEdgeWithView:self.greeting3Label];
    
    [self.giveFeedbackTextLabel ggk_placeBelowView:self.giveFeedbackHeaderLabel gap:aGap4];
    [self.giveFeedbackTextLabel ggk_alignLeftEdgeWithView:self.giveFeedbackHeaderLabel];
    
    [self.emailTheCreatorsButton ggk_placeBelowView:self.giveFeedbackTextLabel gap:aGap5];
    [self.emailTheCreatorsButton ggk_alignRightEdgeWithView:self.giveFeedbackTextLabel];
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    CGFloat aGap1 = 40;
    
    // An anchor.
    [self.greeting1Label ggk_makeTopGap:aGap1];
    [self.greeting1Label ggk_alignHorizontalCenterWithView:self.greeting1Label.superview];
    
    CGFloat aGap2 = 30;
    
    [self.greeting2Label ggk_placeBelowView:self.greeting1Label gap:aGap2];
    [self.greeting2Label ggk_makeLeftGap:20];
    
    [self.greeting3Label ggk_placeBelowView:self.greeting2Label gap:aGap2];
    [self.greeting3Label ggk_alignLeftEdgeWithView:self.greeting2Label];
    
    [self.rateUsHeaderLabel ggk_placeBelowView:self.greeting3Label gap:aGap1];
    [self.rateUsHeaderLabel ggk_alignLeftEdgeWithView:self.greeting2Label];
    
    CGFloat aGap3 = 8;
    
    [self.rateUsTextLabel ggk_placeBelowView:self.rateUsHeaderLabel gap:aGap3];
    [self.rateUsTextLabel ggk_alignLeftEdgeWithView:self.rateUsHeaderLabel];
    
    [self.rateUsButton ggk_alignTopEdgeWithView:self.rateUsTextLabel];
    [self.rateUsButton ggk_makeX:419];
    
    [self.donateHeaderLabel ggk_placeBelowView:self.rateUsTextLabel gap:aGap1];
    [self.donateHeaderLabel ggk_alignLeftEdgeWithView:self.rateUsTextLabel];
    
    [self.donateTextLabel ggk_placeBelowView:self.donateHeaderLabel gap:aGap3];
    [self.donateTextLabel ggk_alignLeftEdgeWithView:self.donateHeaderLabel];
    
    [self.giveADollarLabel ggk_placeBelowView:self.donateTextLabel gap:aGap2];
    [self.giveADollarLabel ggk_alignLeftEdgeWithView:self.donateTextLabel];
    
    [self.giveADollarButton ggk_alignTopEdgeWithView:self.giveADollarLabel];
    [self.giveADollarButton ggk_makeX:469];
    
    [self.starsLabel ggk_placeBelowView:self.giveADollarLabel gap:aGap2];
    [self.starsLabel ggk_alignLeftEdgeWithView:self.giveADollarLabel];
    
    [self.giveFeedbackHeaderLabel ggk_placeBelowView:self.starsLabel gap:aGap1];
    [self.giveFeedbackHeaderLabel ggk_alignLeftEdgeWithView:self.starsLabel];
    
    [self.giveFeedbackTextLabel ggk_placeBelowView:self.giveFeedbackHeaderLabel gap:aGap3];
    [self.giveFeedbackTextLabel ggk_alignLeftEdgeWithView:self.giveFeedbackHeaderLabel];
    
    [self.emailTheCreatorsButton ggk_alignBottomEdgeWithView:self.giveFeedbackTextLabel];
    [self.emailTheCreatorsButton ggk_makeX:446];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set up in-app purchase.
    GGKCamAppDelegate *aCamAppDelegate = (GGKCamAppDelegate *)[UIApplication sharedApplication].delegate;
    self.inAppPurchaseManager = aCamAppDelegate.inAppPurchaseManager;
    self.inAppPurchaseManager.delegate = self;
    [self.inAppPurchaseManager requestProductData];
    
    [self showStars];
}

@end
