//
//  GGKMercyCameraViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKMercyCameraViewController : UIViewController

// Story: User sees this and understands that the parts shown below it are examples.
@property (nonatomic, weak) IBOutlet UILabel *exampleLabel;

// Story: User taps this button to learn about helping the creators. (Donation, rate/review, sending feedback directly.)
@property (nonatomic, weak) IBOutlet UIButton *helpTheCreatorsButton;

// Story: User feels welcome. She is given direction via instruction, while retaining choice.
@property (nonatomic, weak) IBOutlet UILabel *hiLabel;

// Story: User taps this button to rate this app in the App Store. In case the user tapped accidentally, ask for confirmation via an alert.
@property (nonatomic, weak) IBOutlet UIButton *rateThisAppButton;

@property (nonatomic, weak) IBOutlet UIButton *takeAPhotoButton;

// Story: User reads example and has a better understanding whether she wants to do that. Also, she can think about that for the future.
@property (nonatomic, weak) IBOutlet UILabel *takeAPhotoExampleLabel;

@property (nonatomic, weak) IBOutlet UIButton *takeAdvancedDelayedPhotosButton;

// Story: User reads example for "Take delayed photos (advanced)" and has a better understanding whether she wants to do that. Also, user can think about that for the future.
@property (weak, nonatomic) IBOutlet UILabel *takeAdvancedDelayedPhotosExampleLabel;

@property (nonatomic, weak) IBOutlet UIButton *takeDelayedPhotosButton;

// Story: User reads example for "Take delayed photos" and has a better understanding of whether she wants to do that. Also, user can think about that for the future.
@property (weak, nonatomic) IBOutlet UILabel *takeDelayedPhotosExampleLabel;

// Play sound as aural feedback for pressing button.
- (IBAction)playButtonSound;

@end
