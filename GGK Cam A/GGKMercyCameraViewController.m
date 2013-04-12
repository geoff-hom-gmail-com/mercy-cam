//
//  GGKMercyCameraViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCameraViewController.h"
#import "GGKOverlayViewController.h"
#import "GGKSimpleDelayedPhotoViewController.h"

@interface GGKMercyCameraViewController ()

@property (strong, nonatomic) GGKOverlayViewController *overlayViewController;

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

- (void)overlayViewControllerDidFinishWithCamera {
    
    NSLog(@"overlayViewControllerDidFinishWithCamera called");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)takePhoto {
//    
//    NSLog(@"takePhoto called");
//    BOOL cameraIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
//    if (cameraIsAvailable) {
//        
//        UIImagePickerController *anImagePickerController = [[UIImagePickerController alloc] init];
//        anImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//        anImagePickerController.delegate = self;
//        // if default controls are shown, then it has the retake/preview screen, which we don't want
//        // Also, taking multiple photos requires hiding the default controls (see Apple docs).
//        anImagePickerController.showsCameraControls = NO;
//        GGKOverlayViewController *anOverlayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OverlayViewController"];
//        anOverlayViewController.delegate = self;
//        anOverlayViewController.imagePickerController = anImagePickerController;
//        anImagePickerController.cameraOverlayView = anOverlayViewController.view;
//        // need to retain the view or vc
//        self.overlayViewController = anOverlayViewController;
//        [self.navigationController presentViewController:anImagePickerController animated:YES completion:nil];
////        self.imagePickerController = anImagePickerController;
//    } else {
//        
//        NSLog(@"Warning: camera not available.");
//    }
//}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
        
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
    self.takeDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"\"Wait %@ %@, then take %@ %@.\"", takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber, aSecondsString, takeDelayedPhotosNumberOfPhotosNumber, aPhotosString];
}

@end
