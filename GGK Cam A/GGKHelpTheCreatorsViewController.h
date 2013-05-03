//
//  GGKHelpTheCreatorsViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/1/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGKInAppPurchaseManager.h"

@interface GGKHelpTheCreatorsViewController : UIViewController <GGKInAppPurchaseManagerDelegate>

// Story: User taps button. User emails the creators. (Email automatically includes important info the creators may want to know, like the app name and version number.)
@property (nonatomic, weak) IBOutlet UIButton *emailTheCreatorsButton;

// Story: User reads about giving $0.99 (in her local currency) to the creators. She does so. =)
@property (nonatomic, weak) IBOutlet UILabel *giveADollarLabel;

// Story: User taps button to give $0.99 (in her local currency) to the creators. The creators are happy.
@property (nonatomic, weak) IBOutlet UIButton *giveADollarButton;

// Story: User sees "(No stars yet)" and buys a star. User sees a star for each dollar given, and she feels content.
@property (nonatomic, weak) IBOutlet UILabel *starsLabel;

// Buy the product "give a dollar."
- (IBAction)giveADollar;

- (void)inAppPurchaseManagerDidHandleCompletedTransaction:(id)sender;
// So, assume a star was bought. Record that and update stars shown. Enable donation again.

- (void)inAppPurchaseManagerDidHandleFailedTransaction:(id)sender;
// So, enable donation again.

- (void)inAppPurchaseManagerDidReceiveProducts:(id)sender;
// So, update the UI for the local currency.

// Story: User sees option to "Rate this app." User taps button, is brought to the App Store and the rate/review page. User taps 5 stars. =)
- (IBAction)rateOrReview;

@end
