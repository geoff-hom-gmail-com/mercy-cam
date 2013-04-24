//
//  GGKMercyCameraViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCameraViewController.h"
#import "GGKSimpleDelayedPhotoViewController.h"

//BOOL GGKCreateLaunchImages = YES;
BOOL GGKCreateLaunchImages = NO;

@interface GGKMercyCameraViewController ()

// Story: The overall orientation (device/status-bar) is checked against the orientation of this app's UI. The user sees the UI in the correct orientation.
// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

// UIViewController override.
- (void)awakeFromNib;

// Story: When the user should see the UI in landscape, she does.
- (void)updateLayoutForLandscape;

// Story: When the user should see the UI in portrait, she does.
- (void)updateLayoutForPortrait;

// UIViewController override.
- (void)viewDidLoad;

// UIViewController override.
- (void)viewWillAppear:(BOOL)animated;

// UIViewController override.
// Story: Whether user rotates device in the app, or from the home screen, this method will be called. User sees UI in correct orientation.
- (void)viewWillLayoutSubviews;

@end

@implementation GGKMercyCameraViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    NSLog(@"MCVC aFN");
    self.isShowingLandscapeView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonSound
{
    [self.soundModel playButtonTapSound];
}

- (void)updateLayoutForLandscape
{
    CGSize aSize = self.hiLabel.frame.size;
    self.hiLabel.frame = CGRectMake(92, 30, aSize.width, aSize.height);
    
    CGFloat anX1 = 20;
    aSize = self.takeAPhotoButton.frame.size;
    self.takeAPhotoButton.frame = CGRectMake(anX1, 101, aSize.width, aSize.height);
    
    aSize = self.exampleLabel.frame.size;
    self.exampleLabel.frame = CGRectMake(472, 131, aSize.width, aSize.height);
    
    CGFloat anX2 = 353;
    aSize = self.takeAPhotoExampleLabel.frame.size;
    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 166, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosButton.frame.size;
    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 331, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 363, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 501, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 511, aSize.width, aSize.height);
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:18];
    self.rateThisAppButton.titleLabel.font = aFont;
    CGFloat anX3 = 831;
    aSize = CGSizeMake(173, 60);
    self.rateThisAppButton.frame = CGRectMake(anX3, 516, aSize.width, aSize.height);
    
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 615, aSize.width, aSize.height);
}

- (void)updateLayoutForPortrait
{
    CGSize aSize = self.hiLabel.frame.size;
    self.hiLabel.frame = CGRectMake(92, 50, aSize.width, aSize.height);
    
    CGFloat anX1 = 20;
    aSize = self.takeAPhotoButton.frame.size;
    self.takeAPhotoButton.frame = CGRectMake(anX1, 120, aSize.width, aSize.height);
    
    aSize = self.exampleLabel.frame.size;
    self.exampleLabel.frame = CGRectMake(472, 151, aSize.width, aSize.height);
    
    CGFloat anX2 = 353;
    aSize = self.takeAPhotoExampleLabel.frame.size;
    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 186, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosButton.frame.size;
    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 350, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 382, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 520, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 530, aSize.width, aSize.height);
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:22];
    self.rateThisAppButton.titleLabel.font = aFont;
    CGFloat anX3 = 538;
    aSize = CGSizeMake(210, 60);
    self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
    
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 851, aSize.width, aSize.height);
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
//    NSLog(@"MCVC vdL");
    
    // Make UI blank so we can make launch images via screenshot.
    if (GGKCreateLaunchImages) {
        
        self.navigationItem.title = @"";
        for (UIView *aSubView in self.view.subviews) {
            
            aSubView.hidden = YES;
        }
    } else {
        
        self.soundModel = [[GGKSoundModel alloc] init];
        [self updateLayoutForPortrait];
    }
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    
    // move to sub-method
    // Update labels in case they changed.
    
    NSNumber *takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    if (takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber == nil) {
        
        takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber = @(GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger);
    }
    NSNumber *takeDelayedPhotosNumberOfPhotosNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString];
    if (takeDelayedPhotosNumberOfPhotosNumber == nil) {
        
        takeDelayedPhotosNumberOfPhotosNumber = @(GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger);
    }
    
    NSString *aSecondsString = @"seconds";
    if ([takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber intValue] == 1) {
        
        aSecondsString = @"second";
    }
    NSString *aPhotosString = @"photos";
    if ([takeDelayedPhotosNumberOfPhotosNumber intValue] == 1) {
        
        aPhotosString = @"photo";
    }
    self.takeDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"\"Wait %@ %@,\nthen take %@ %@.\"", takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber, aSecondsString, takeDelayedPhotosNumberOfPhotosNumber, aPhotosString];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //    NSLog(@"MCVC vWLS");
    
    // Using status-bar orientation, not device orientation. Seems to work. 
    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(theInterfaceOrientation) && !self.isShowingLandscapeView) {
        
//        NSLog(@"MCVC vWLS theInterfaceOrientation set things to landscape");
        [self updateLayoutForLandscape];
        self.isShowingLandscapeView = YES;
    } else if (UIInterfaceOrientationIsPortrait(theInterfaceOrientation) && self.isShowingLandscapeView) {
        
//        NSLog(@"MCVC vWLS theInterfaceOrientation set things to portrait");
        [self updateLayoutForPortrait];
        self.isShowingLandscapeView = NO;
    }
}

@end
