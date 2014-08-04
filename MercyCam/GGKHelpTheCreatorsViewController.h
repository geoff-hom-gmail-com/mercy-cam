//
//  Created by Geoff Hom on 5/1/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKInAppPurchaseManager.h"
#import "GGKViewController.h"
#import <MessageUI/MessageUI.h>

@interface GGKHelpTheCreatorsViewController : GGKViewController <GGKInAppPurchaseManagerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *donateView;
// Story: User taps button. User emails the creators. (Email automatically includes important info the creators may want to know, like the app name and version number.)
@property (nonatomic, weak) IBOutlet UIButton *emailTheCreatorsButton;
// Story: User taps button to give $0.99 (in her local currency) to the creators. The creators are happy.
@property (nonatomic, weak) IBOutlet UIButton *giveADollarButton;
// For getting product info from the App Store, and for purchasing products.
@property (nonatomic, strong) GGKInAppPurchaseManager *inAppPurchaseManager;
// Story: User taps button, is taken to App Store, and rates the app. Creators happy, and user feels empowered.
@property (nonatomic, weak) IBOutlet UIButton *rateUsButton;
// Story: User sees "(No stars yet)" and buys a star. User sees a star for each dollar given, and she feels content.
@property (nonatomic, weak) IBOutlet UILabel *starsLabel;
// Story: User sees she can email the creators. User taps button and sends feedback, which automatically includes technical info to help the creators. User and creators are happy.
// Start an email with the destination, subject line and some message body. The body automatically includes the app version, the type of device, and the version of iOS.
- (IBAction)emailTheCreators;
// Buy the product "give a dollar."
- (IBAction)giveADollar;
// Assume a star was bought. Record that and update stars shown. Enable donation again.
- (void)inAppPurchaseManagerDidHandleCompletedTransaction:(id)sender;
// Enable donation again.
- (void)inAppPurchaseManagerDidHandleFailedTransaction:(id)sender;
// Update the UI for the local currency.
- (void)inAppPurchaseManagerDidReceiveProducts:(id)sender;
// Dismiss the email view.
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
// Story: User sees option to "Rate this app." User taps button, is brought to the App Store and the rate/review page. User taps 5 stars. =)
- (IBAction)rateOrReview;
// Show the number of thank-you stars. (One star per dollar given.)
- (void)showStars;
// Story: User sees UI and knows she can tap "Give $0.99."
- (void)updateForAllowingDonation;
// Override.
- (void)viewDidLoad;
@end
