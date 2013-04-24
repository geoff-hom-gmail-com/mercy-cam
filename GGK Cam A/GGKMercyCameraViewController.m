//
//  GGKMercyCameraViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCameraViewController.h"
//#import "GGKOverlayViewController.h"
#import "GGKSimpleDelayedPhotoViewController.h"

//BOOL GGKCreateLaunchImages = YES;
BOOL GGKCreateLaunchImages = NO;

@interface GGKMercyCameraViewController ()

// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;

//@property (strong, nonatomic) GGKOverlayViewController *overlayViewController;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

@end

@implementation GGKMercyCameraViewController

// ?
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSLog(@"MCVC aFN");
    self.isShowingLandscapeView = NO;
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
//
//// ?
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
//}
//
//// ?
//- (void)handleOrientationChange:(NSNotification *)theNotification
//{
//    UIDeviceOrientation theDeviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(theDeviceOrientation) && !self.isShowingLandscapeView) {
//        
//        [self performSegueWithIdentifier:@"DisplayLandscapeView" sender:self];
//        self.isShowingLandscapeView = YES;
//    } else if (UIDeviceOrientationIsPortrait(theDeviceOrientation) && self.isShowingLandscapeView) {
//        
//        [self dismissViewControllerAnimated:YES completion:nil];
//        self.isShowingLandscapeView = NO;
//    }
//}

// ?
- (void)updateLayoutForLandscape
{
    //testing
    self.takeDelayedPhotosExampleLabel.text = @"this is now landscape mode";
    self.rateThisAppButton.frame = CGRectMake(831, 516, 173, 60);
}

//??
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    NSLog(@"MCVC vWLS");
    
    // using device orientation
//    UIDeviceOrientation theDeviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(theDeviceOrientation) && !self.isShowingLandscapeView) {
//        
//        NSLog(@"MCVC vWLS theDeviceOrientation set things to landscape");
//        [self updateLayoutForLandscape];
//        self.isShowingLandscapeView = YES;
//    } else if (UIDeviceOrientationIsPortrait(theDeviceOrientation) && self.isShowingLandscapeView) {
//        
//        NSLog(@"MCVC vWLS theDeviceOrientation set things to portrait");
//        // it may set things to be portrait automatically sometimes, like returning to foreground? test by implementing landscape changes, then do some sim tests involving home button
//        self.isShowingLandscapeView = NO;
//    }
    
    // using status-bar orientation
    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(theInterfaceOrientation) && !self.isShowingLandscapeView) {
        
        NSLog(@"MCVC vWLS theInterfaceOrientation set things to landscape");
        [self updateLayoutForLandscape];
        self.isShowingLandscapeView = YES;
    } else if (UIInterfaceOrientationIsPortrait(theInterfaceOrientation) && self.isShowingLandscapeView) {
        
        NSLog(@"MCVC vWLS theInterfaceOrientation set things to portrait");
        // it may set things to be portrait automatically sometimes, like returning to foreground? test by implementing landscape changes, then do some sim tests involving home button
        // no; only during app launch
        self.isShowingLandscapeView = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// gets called after "use" but not before "retake"
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"imagePickerController:didFinishPickingMediaWithInfo called");
    UIImage *theImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(theImage, nil, nil, nil);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    NSLog(@"imagePickerControllerDidCancel called");
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:self.imagePickerController completion:nil];
}

- (IBAction)playButtonSound
{
    [self.soundModel playButtonTapSound];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    // Make UI blank so we can make launch images via screenshot.
    if (GGKCreateLaunchImages) {
        
        self.navigationItem.title = @"";
        for (UIView *aSubView in self.view.subviews) {
            
            aSubView.hidden = YES;
        }
    } else {
        
        self.soundModel = [[GGKSoundModel alloc] init];
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

@end
