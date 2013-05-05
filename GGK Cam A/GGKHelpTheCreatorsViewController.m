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

// Story: The overall orientation (device/status-bar) is checked against the orientation of this app's UI. The user sees the UI in the correct orientation.
// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;

// Show the number of thank-you stars. (One star per dollar given.)
- (void)showStars;

// Story: User sees UI and knows she can tap "Give $0.99."
- (void)updateForAllowingDonation;

// Story: When the user should see the UI in landscape, she does.
- (void)updateLayoutForLandscape;

// Story: When the user should see the UI in portrait, she does.
- (void)updateLayoutForPortrait;

// UIViewController override.
// Story: Whether user rotates device in the app, or from the home screen, this method will be called. User sees UI in correct orientation.
- (void)viewWillLayoutSubviews;

@end

@implementation GGKHelpTheCreatorsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)mailComposeController:(MFMailComposeViewController *)theViewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [theViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playButtonSound
{
    GGKCamAppDelegate *aCamAppDelegate = (GGKCamAppDelegate *)[UIApplication sharedApplication].delegate;
    [aCamAppDelegate.soundModel playButtonTapSound];
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
//    CGSize aSize = self.hiLabel.frame.size;
//    self.hiLabel.frame = CGRectMake(92, 50, aSize.width, aSize.height);
//    
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
	// Do any additional setup after loading the view.
    
    // Set up in-app purchase.
    GGKCamAppDelegate *aCamAppDelegate = (GGKCamAppDelegate *)[UIApplication sharedApplication].delegate;
    self.inAppPurchaseManager = aCamAppDelegate.inAppPurchaseManager;
    self.inAppPurchaseManager.delegate = self;
    [self.inAppPurchaseManager requestProductData];
    
    [self showStars];
    
    [self updateLayoutForPortrait];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Using status-bar orientation, not device orientation. Seems to work.
    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(theInterfaceOrientation) && !self.isShowingLandscapeView) {
        
        [self updateLayoutForLandscape];
        self.isShowingLandscapeView = YES;
    } else if (UIInterfaceOrientationIsPortrait(theInterfaceOrientation) && self.isShowingLandscapeView) {
        
        [self updateLayoutForPortrait];
        self.isShowingLandscapeView = NO;
    }
}

@end
