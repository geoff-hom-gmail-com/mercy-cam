//
//  GGKHelpTheCreatorsViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/1/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKHelpTheCreatorsViewController : UIViewController

// Story: User taps button. User emails the creators. (Email automatically includes important info the creators may want to know, like the app name and version number.)
@property (nonatomic, weak) IBOutlet UIButton *emailTheCreatorsButton;

// Story: User reads about giving $0.99 (in her local currency) to the creators. She does so. =)
@property (nonatomic, weak) IBOutlet UILabel *giveADollarLabel;

// Story: User taps button to give $0.99 (in her local currency) to the creators. The creators are happy.
@property (nonatomic, weak) IBOutlet UIButton *giveADollarButton;


// label for the thank-you stars

// button for rate us


@end
