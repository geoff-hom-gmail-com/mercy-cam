//
//  GGKHelpTheCreatorsViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/1/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKInAppPurchaseManager.h"
#import "GGKViewController.h"
#import <MessageUI/MessageUI.h>

@interface GGKHelpTheCreatorsViewController : GGKViewController <GGKInAppPurchaseManagerDelegate, MFMailComposeViewControllerDelegate>

// Story: User sees header and understands this is one of the ways to help.
@property (nonatomic, weak) IBOutlet UILabel *donateHeaderLabel;

// Story: User reads the text and understands what the header means.
@property (nonatomic, weak) IBOutlet UILabel *donateTextLabel;

// Story: User taps button. User emails the creators. (Email automatically includes important info the creators may want to know, like the app name and version number.)
@property (nonatomic, weak) IBOutlet UIButton *emailTheCreatorsButton;

// Story: User reads about giving $0.99 (in her local currency) to the creators. She does so. =)
@property (nonatomic, weak) IBOutlet UILabel *giveADollarLabel;

// Story: User taps button to give $0.99 (in her local currency) to the creators. The creators are happy.
@property (nonatomic, weak) IBOutlet UIButton *giveADollarButton;

// Story: User sees header and understands this is one of the ways to help.
@property (nonatomic, weak) IBOutlet UILabel *giveFeedbackHeaderLabel;

// Story: User reads the text and understands what the header means.
@property (nonatomic, weak) IBOutlet UILabel *giveFeedbackTextLabel;

// Story: User reads greetings and feels motivated to help. She also understands there are various ways to help.
@property (nonatomic, weak) IBOutlet UILabel *greeting1Label;

// Story: User reads greetings and feels motivated to help. She also understands there are various ways to help.
@property (nonatomic, weak) IBOutlet UILabel *greeting2Label;

// Story: User reads greetings and feels motivated to help. She also understands there are various ways to help.
@property (nonatomic, weak) IBOutlet UILabel *greeting3Label;

// Story: User taps button, is taken to App Store, and rates the app. Creators happy, and user feels empowered.
@property (nonatomic, weak) IBOutlet UIButton *rateUsButton;

// Story: User sees header and understands this is one of the ways to help.
@property (nonatomic, weak) IBOutlet UILabel *rateUsHeaderLabel;

// Story: User reads the text and understands what the header means.
@property (nonatomic, weak) IBOutlet UILabel *rateUsTextLabel;

// Story: User sees "(No stars yet)" and buys a star. User sees a star for each dollar given, and she feels content.
@property (nonatomic, weak) IBOutlet UILabel *starsLabel;

// Story: User sees she can email the creators. User taps button and sends feedback, which automatically includes technical info to help the creators. User and creators are happy.
// Start an email with the destination, subject line and some message body. The body automatically includes the app version, the type of device, and the version of iOS.
- (IBAction)emailTheCreators;

// Buy the product "give a dollar."
- (IBAction)giveADollar;

- (void)inAppPurchaseManagerDidHandleCompletedTransaction:(id)sender;
// So, assume a star was bought. Record that and update stars shown. Enable donation again.

- (void)inAppPurchaseManagerDidHandleFailedTransaction:(id)sender;
// So, enable donation again.

- (void)inAppPurchaseManagerDidReceiveProducts:(id)sender;
// So, update the UI for the local currency.

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
// So, dismiss the email view.

// Story: User sees option to "Rate this app." User taps button, is brought to the App Store and the rate/review page. User taps 5 stars. =)
- (IBAction)rateOrReview;

// Override.
- (void)updateLayoutForLandscape;

// Override.
- (void)updateLayoutForPortrait;

// Override.
- (void)viewDidLoad;

@end
