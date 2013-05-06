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
    // The left margin.
    CGFloat aMarginX1Float = 20;
    
    // The starting x-coordinate for the 1st greeting column.
    CGFloat aGreetingX1Float = 55;
    
    // The starting x-coordinate for the 2nd greeting column.
    CGFloat aGreetingX2Float = 546;
    
    // The vertical gap between the greeting and the next section (landscape orientation only).
    CGFloat theSectionGreetingGapFloat = 70;
    
    // The vertical gap between the end of one section and the start of another.
    CGFloat theSectionGapFloat = 40;
    
    // The vertical gap between the end of one text and the start of another.
    CGFloat theTextGapFloat = 30;
    
    // The vertical gap between a header and the next label.
    CGFloat theHeaderGapFloat = 8;
    
    // The vertical gap between a button and the text above it.
    CGFloat theTextButtonGapFloat = 15;
    
    // First text for greeting. Centered horizontally.
    CGSize aSize = self.greeting1Label.frame.size;
    self.greeting1Label.frame = CGRectMake(277, theSectionGapFloat, aSize.width, aSize.height);
    
    // More text for the greeting.
    CGRect aPreviousViewFrame = self.greeting1Label.frame;
    CGFloat aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
    aSize = self.greeting2Label.frame.size;
    self.greeting2Label.frame = CGRectMake(aGreetingX1Float, aYFloat, aSize.width, aSize.height);
    
    // More text for the greeting.
    // The top is the same as the previous text.
    aPreviousViewFrame = self.greeting2Label.frame;
    aYFloat = aPreviousViewFrame.origin.y;
    aSize = self.greeting3Label.frame.size;
    self.greeting3Label.frame = CGRectMake(aGreetingX2Float, aYFloat, aSize.width, aSize.height);
    
    // Header: "Rate us"
    aPreviousViewFrame = self.greeting2Label.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGreetingGapFloat;
    aSize = self.rateUsHeaderLabel.frame.size;
    self.rateUsHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Text for "Rate us"
    aPreviousViewFrame = self.rateUsHeaderLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
    aSize = self.rateUsTextLabel.frame.size;
    self.rateUsTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Button for "Rate us."
    aPreviousViewFrame = self.rateUsTextLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextButtonGapFloat;
    aSize = self.rateUsButton.frame.size;
    self.rateUsButton.frame = CGRectMake(155, aYFloat, aSize.width, aSize.height);
    
    // Header: "Donate"
    aPreviousViewFrame = self.rateUsButton.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGapFloat;
    aSize = self.donateHeaderLabel.frame.size;
    self.donateHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // First text for "Donate"
    aPreviousViewFrame = self.donateHeaderLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
    aSize = self.donateTextLabel.frame.size;
    self.donateTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // More text for "Donate"
    aPreviousViewFrame = self.donateTextLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
    aSize = self.giveADollarLabel.frame.size;
    self.giveADollarLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Button for "Donate"
    // The button should be at the end of the text. The button height is greater than the text, so we'll align the button top with the text top.
    aPreviousViewFrame = self.giveADollarLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y;
    aSize = self.giveADollarButton.frame.size;
    self.giveADollarButton.frame = CGRectMake(469, aYFloat, aSize.width, aSize.height);
    
    // Stars for "Donate"
    aPreviousViewFrame = self.giveADollarLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
    aSize = self.starsLabel.frame.size;
    self.starsLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Header: "Give feedback"
    // The top is the same as the header for "Rate us."
    aPreviousViewFrame = self.rateUsHeaderLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y;
    aSize = self.giveFeedbackHeaderLabel.frame.size;
    self.giveFeedbackHeaderLabel.frame = CGRectMake(aGreetingX2Float, aYFloat, aSize.width, aSize.height);
    
    // Text for "Give feedback"
    aPreviousViewFrame = self.giveFeedbackHeaderLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
    aSize = self.giveFeedbackTextLabel.frame.size;
    self.giveFeedbackTextLabel.frame = CGRectMake(aPreviousViewFrame.origin.x, aYFloat, aSize.width, aSize.height);
    
    // Button for "Give feedback."
    aPreviousViewFrame = self.giveFeedbackTextLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextButtonGapFloat;
    aSize = self.emailTheCreatorsButton.frame.size;
    self.emailTheCreatorsButton.frame = CGRectMake(728, aYFloat, aSize.width, aSize.height);
}

- (void)updateLayoutForPortrait
{
    // The left margin.
    CGFloat aMarginX1Float = 20;
    
    // The vertical gap between the end of one section and the start of another.
    CGFloat theSectionGapFloat = 40;
    
    // The vertical gap between the end of one text and the start of another.
    CGFloat theTextGapFloat = 30;
    
    // The vertical gap between a header and the next label.
    CGFloat theHeaderGapFloat = 8;
    
    // First text for greeting. Centered horizontally.
    CGSize aSize = self.greeting1Label.frame.size;
    self.greeting1Label.frame = CGRectMake(153, theSectionGapFloat, aSize.width, aSize.height);
    
    // More text for the greeting.
    CGRect aPreviousViewFrame = self.greeting1Label.frame;
    CGFloat aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
    aSize = self.greeting2Label.frame.size;
    self.greeting2Label.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // More text for the greeting.
    aPreviousViewFrame = self.greeting2Label.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
    aSize = self.greeting3Label.frame.size;
    self.greeting3Label.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Header: "Rate us"
    aPreviousViewFrame = self.greeting3Label.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGapFloat;
    aSize = self.rateUsHeaderLabel.frame.size;
    self.rateUsHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Text for "Rate us"
    aPreviousViewFrame = self.rateUsHeaderLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
    aSize = self.rateUsTextLabel.frame.size;
    self.rateUsTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Button for "Rate us"
    // The button should be at the end of the text. The button height is greater than the text, so we'll align the button top with the text top.
    aPreviousViewFrame = self.rateUsTextLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y;
    aSize = self.rateUsButton.frame.size;
    self.rateUsButton.frame = CGRectMake(414, aYFloat, aSize.width, aSize.height);
    
    // Header: "Donate"
    aPreviousViewFrame = self.rateUsTextLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGapFloat;
    aSize = self.donateHeaderLabel.frame.size;
    self.donateHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // First text for "Donate"
    aPreviousViewFrame = self.donateHeaderLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
    aSize = self.donateTextLabel.frame.size;
    self.donateTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // More text for "Donate"
    aPreviousViewFrame = self.donateTextLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
    aSize = self.giveADollarLabel.frame.size;
    self.giveADollarLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Button for "Donate"
    // The button should be at the end of the text. The button height is greater than the text, so we'll align the button top with the text top.
    aPreviousViewFrame = self.giveADollarLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y;
    aSize = self.giveADollarButton.frame.size;
    self.giveADollarButton.frame = CGRectMake(469, aYFloat, aSize.width, aSize.height);
    
    // Stars for "Donate"
    aPreviousViewFrame = self.giveADollarLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theTextGapFloat;
    aSize = self.starsLabel.frame.size;
    self.starsLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Header: "Give feedback"
    aPreviousViewFrame = self.starsLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theSectionGapFloat;
    aSize = self.giveFeedbackHeaderLabel.frame.size;
    self.giveFeedbackHeaderLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Text for "Give feedback"
    aPreviousViewFrame = self.giveFeedbackHeaderLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height + theHeaderGapFloat;
    aSize = self.giveFeedbackTextLabel.frame.size;
    self.giveFeedbackTextLabel.frame = CGRectMake(aMarginX1Float, aYFloat, aSize.width, aSize.height);
    
    // Button for "Give feedback"
    // Button bottom is aligned with text bottom.
    aSize = self.emailTheCreatorsButton.frame.size;
    aPreviousViewFrame = self.giveFeedbackTextLabel.frame;
    aYFloat = aPreviousViewFrame.origin.y + aPreviousViewFrame.size.height - aSize.height;
    self.emailTheCreatorsButton.frame = CGRectMake(446, aYFloat, aSize.width, aSize.height);
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
