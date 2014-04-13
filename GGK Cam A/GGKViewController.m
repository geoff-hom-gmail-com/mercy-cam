//
//  GGKViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKViewController.h"

#import "GGKMercyCameraAppDelegate.h"
#import "GGKSoundModel.h"

@interface GGKViewController ()

// For removing the observer later.
@property (strong, nonatomic) id appDidEnterBackgroundObserver;
@property (strong, nonatomic) id appWillEnterForegroundObserver;

// Story: The overall orientation (device/status-bar) is checked against the orientation of this app's UI. The user sees the UI in the correct orientation.
// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;

@end

@implementation GGKViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.isShowingLandscapeView = NO;
}
- (void)dealloc {
//    NSLog(@"VC dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self.appWillEnterForegroundObserver name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.appDidEnterBackgroundObserver name:UIApplicationDidEnterBackgroundNotification object:nil];
    // No need to call super.
}
- (void)handleViewDidDisappearFromUser {
//    NSLog(@"VC hVDDFU");
}
- (void)handleViewWillAppearToUser {
//    NSLog(@"VC hVWATU");
}
- (IBAction)playButtonSound
{
    GGKMercyCameraAppDelegate *aCamAppDelegate = (GGKMercyCameraAppDelegate *)[UIApplication sharedApplication].delegate;
    [aCamAppDelegate.soundModel playButtonTapSound];
}
- (void)updateLayoutForLandscape {
//    NSLog(@"updateLayoutForLandscape");
}
- (void)updateLayoutForPortrait {
//    NSLog(@"updateLayoutForPortrait");
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self handleViewDidDisappearFromUser];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self handleViewWillAppearToUser];
    // Using a weak variable to avoid a strong-reference cycle.
    GGKViewController * __weak aWeakSelf = self;
    self.appWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [aWeakSelf handleViewWillAppearToUser];
    }];
    self.appDidEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [aWeakSelf handleViewDidDisappearFromUser];
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.appWillEnterForegroundObserver name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.appDidEnterBackgroundObserver name:UIApplicationDidEnterBackgroundNotification object:nil];
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
