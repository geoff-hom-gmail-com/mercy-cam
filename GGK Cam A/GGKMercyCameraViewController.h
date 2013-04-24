//
//  GGKMercyCameraViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

//#import "GGKOverlayViewController.h"
#import <UIKit/UIKit.h>

@interface GGKMercyCameraViewController : UIViewController

// Story: User taps this button to rate this app in the App Store. In case the user tapped accidentally, ask for confirmation via an alert.
@property (nonatomic, weak) IBOutlet UIButton *rateThisAppButton;

// Story: User reads example for "Take delayed photos" and has a better understanding of whether she wants to do that. Also, user can think about that for the future.
@property (weak, nonatomic) IBOutlet UILabel *takeDelayedPhotosExampleLabel;

// Story: User reads example for "Take delayed photos (advanced)" and has a better understanding of whether she wants to do that. Also, user can think about that for the future.
@property (weak, nonatomic) IBOutlet UILabel *takeAdvancedDelayedPhotosExampleLabel;


// Play sound as aural feedback for pressing button.
- (IBAction)playButtonSound;

// UIViewController override.
- (void)viewDidLoad;

// UIViewController override.
- (void)viewWillAppear:(BOOL)animated;

@end
