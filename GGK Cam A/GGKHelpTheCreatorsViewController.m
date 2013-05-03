//
//  GGKHelpTheCreatorsViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/1/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKCamAppDelegate.h"
#import "GGKHelpTheCreatorsViewController.h"

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        NSString *aString = [NSString stringWithFormat:@"Give %@", aFormattedString];
        [self.giveADollarButton setTitle:aString forState:UIControlStateNormal];
        [self.giveADollarButton setTitle:aString forState:UIControlStateDisabled];
        self.giveADollarButton.enabled = YES;
        
        aString = [NSString stringWithFormat:@"You can give %@ at a time. Each time you give, you'll see a thank-you star (%@) below.", aFormattedString, WhiteMediumStarEmojiString];
        self.giveADollarLabel.text = aString;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    //testing
    //    theNumberOfStarsPurchasedNumber = @3;
    
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
