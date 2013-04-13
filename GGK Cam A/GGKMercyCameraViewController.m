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

//@property (strong, nonatomic) GGKOverlayViewController *overlayViewController;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

@end

@implementation GGKMercyCameraViewController

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
