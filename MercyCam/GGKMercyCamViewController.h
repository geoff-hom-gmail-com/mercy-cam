//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKViewController.h"

@class GGKDelayedPhotosModel;

@interface GGKMercyCamViewController : GGKViewController
@property (strong, nonatomic) GGKDelayedPhotosModel *delayedPhotosModel;
// Story: User taps this button to learn about helping the creators. (Donation, rate/review, sending feedback directly.)
@property (nonatomic, weak) IBOutlet UIButton *helpTheCreatorsButton;

// Story: User taps this button to rate this app in the App Store. In case the user tapped accidentally, ask for confirmation via an alert.
@property (nonatomic, weak) IBOutlet UIButton *rateThisAppButton;

@property (nonatomic, weak) IBOutlet UIButton *takeAPhotoButton;
@property (nonatomic, weak) IBOutlet UIButton *takeAdvancedDelayedPhotosButton;

// Story: User reads example for "Take delayed photos (advanced)" and has a better understanding whether she wants to do that. Also, user can think about that for the future.
@property (weak, nonatomic) IBOutlet UILabel *takeAdvancedDelayedPhotosExampleLabel;

@property (nonatomic, weak) IBOutlet UIButton *takeDelayedPhotosButton;

// Story: User reads example for "Take delayed photos" and has a better understanding of whether she wants to do that. Also, user can think about that for the future.
@property (weak, nonatomic) IBOutlet UILabel *takeDelayedPhotosExampleLabel;
// Story: User sees option to "Rate this app." User taps button, is brought to the App Store and the rate/review page. User taps 5 stars. =)
//- (IBAction)rateOrReview;
// Override.
// User sees examples, which have her most-recent settings. She has a better understanding of which option she wants, without having to try each. Also, she can think about them for the future.
- (void)updateUI;
// Override.
- (void)viewDidLoad;
@end
