//
//  GGKViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKViewController.h"

#import "GGKMercyCamAppDelegate.h"
#import "GGKSoundModel.h"

@interface GGKViewController ()
// To remove the observer later.
@property (strong, nonatomic) id appDidEnterBackgroundObserver;
@property (strong, nonatomic) id appWillEnterForegroundObserver;
// Story: The overall orientation (device/status-bar) is checked against the orientation of this app's UI. The user sees the UI in the correct orientation.
// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;
@end

@implementation GGKViewController
- (void)awakeFromNib {
    [super awakeFromNib];
    self.isShowingLandscapeView = NO;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.appWillEnterForegroundObserver name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.appDidEnterBackgroundObserver name:UIApplicationDidEnterBackgroundNotification object:nil];
    // No need to call super.
}
- (void)handleViewDidDisappearFromUser {
    //    NSLog(@"VC hVDDFU");
}
- (void)handleViewWillAppearToUser {
    //    NSLog(@"VC hVATU1");
    [self updateUI];
}
- (IBAction)playButtonSound
{
    GGKMercyCamAppDelegate *aCamAppDelegate = (GGKMercyCamAppDelegate *)[UIApplication sharedApplication].delegate;
    [aCamAppDelegate.soundModel playButtonTapSound];
}
- (void)updateLayoutForLandscape {
    if (self.portraitOnlyLayoutConstraintArray != nil) {
        [self.view removeConstraints:self.portraitOnlyLayoutConstraintArray];
    }
    for (NSLayoutConstraint *aLayoutConstraint in self.landscapeOnlyLayoutConstraintArray) {
        if ([self.view.constraints indexOfObject:aLayoutConstraint] == NSNotFound) {
            [self.view addConstraint:aLayoutConstraint];
        }
    }
}
- (void)updateLayoutForPortrait {
    if (self.landscapeOnlyLayoutConstraintArray != nil) {
        [self.view removeConstraints:self.landscapeOnlyLayoutConstraintArray];
    }
    for (NSLayoutConstraint *aLayoutConstraint in self.portraitOnlyLayoutConstraintArray) {
        if ([self.view.constraints indexOfObject:aLayoutConstraint] == NSNotFound) {
            [self.view addConstraint:aLayoutConstraint];
        }
    }
}
- (void)updateUI {
    //    NSLog(@"VC uI");
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self handleViewDidDisappearFromUser];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    GGKMercyCamAppDelegate *theAppDelegate = (GGKMercyCamAppDelegate *)[UIApplication sharedApplication].delegate;
    self.model = theAppDelegate.model;
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
    self.appWillEnterForegroundObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.appDidEnterBackgroundObserver name:UIApplicationDidEnterBackgroundNotification object:nil];
    self.appDidEnterBackgroundObserver = nil;
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // Using status-bar orientation, not device orientation. Seems to work.
    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(theInterfaceOrientation)) {
        [self updateLayoutForLandscape];
    } else if (UIInterfaceOrientationIsPortrait(theInterfaceOrientation)) {
        [self updateLayoutForPortrait];
    }
}
@end
