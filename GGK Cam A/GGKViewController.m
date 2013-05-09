//
//  GGKViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKViewController.h"

@interface GGKViewController ()

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

- (IBAction)playButtonSound
{
    GGKCamAppDelegate *aCamAppDelegate = (GGKCamAppDelegate *)[UIApplication sharedApplication].delegate;
    [aCamAppDelegate.soundModel playButtonTapSound];
}

- (void)updateLayoutForLandscape
{
    ;
}

- (void)updateLayoutForPortrait
{
    ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
