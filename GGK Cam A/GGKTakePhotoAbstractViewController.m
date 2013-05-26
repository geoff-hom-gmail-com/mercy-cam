//
//  GGKTakePhotoAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoAbstractViewController.h"

#import "GGKSavedPhotoViewController.h"
#import "GGKSavedPhotosManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

NSString *GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString = @"captureManager.focusAndExposureStatus";

@interface GGKTakePhotoAbstractViewController ()

@end

@implementation GGKTakePhotoAbstractViewController

- (void)captureManagerDidTakePhoto:(id)sender
{
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}

- (void)dealloc {
    
    [self.captureManager.session stopRunning];
    [self removeObserver:self forKeyPath:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString];
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString]) {
        
// Template for subclasses.
//        switch (self.captureManager.focusAndExposureStatus) {
//                
//            case GGKCaptureManagerFocusAndExposureStatusContinuous:
//                break;
//                
//            case GGKCaptureManagerFocusAndExposureStatusLocking:
//                break;
//                
//            case GGKCaptureManagerFocusAndExposureStatusLocked:
//                break;
//                
//            default:
//                break;
//        }
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)imagePickerController:(UIImagePickerController *)theImagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)theInfoDictionary
{
    NSLog(@"imagePickerController delegate called");
    GGKSavedPhotoViewController *aSavedPhotoViewController = (GGKSavedPhotoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SavedPhotoViewController"];
    aSavedPhotoViewController.view.frame = theImagePickerController.view.frame;
    [aSavedPhotoViewController.view setNeedsLayout];
    UIImage *anImage = theInfoDictionary[UIImagePickerControllerOriginalImage];
    if (anImage == nil) {
        NSLog(@"anImage nil");
    } else {
        NSLog(@"anImage size:%@", NSStringFromCGSize(anImage.size));
    }
// It seems to return the original image correctly. Just not appearing.
//    aSavedPhotoViewController.imageView.image = anImage;
//    [aSavedPhotoViewController.imageView setImage:anImage];
    [theImagePickerController pushViewController:aSavedPhotoViewController animated:NO];
    NSLog(@"imagePickerController delegate called2");
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)sender
{
    if ([theSegue.identifier hasPrefix:@"ShowSavedPhotos"]) {
        
                
        // Retain popover controller, to dismiss later.
//        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        
        NSLog(@"testing1");
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            
            UIImagePickerController *anImagePickerController = (UIImagePickerController *)theSegue.destinationViewController;

            // UIImagePickerController browser on iPad must be presented in a popover.
            
//            UIImagePickerController *anImagePickerController = [[UIImagePickerController alloc] init];
            anImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            anImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            anImagePickerController.delegate = self;
            anImagePickerController.allowsEditing = NO;
            
//            UIPopoverController *aPopoverController = [[UIPopoverController alloc] initWithContentViewController:anImagePickerController];
//            [aPopoverController presentPopoverFromRect:theButton.bounds inView:theButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//            self.savedPhotosPopoverController = aPopoverController;
        }
    }
}

- (IBAction)takePhoto
{
    [self playButtonSound];
    [self.captureManager takePhoto];
    
    // Give visual feedback that photo was taken: Flash the screen.
    UIView *aFlashView = [[UIView alloc] initWithFrame:self.videoPreviewView.frame];
    aFlashView.backgroundColor = [UIColor whiteColor];
    aFlashView.alpha = 0.8f;
    [self.view addSubview:aFlashView];
    [UIView animateWithDuration:0.6f animations:^{
        
        aFlashView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        [aFlashView removeFromSuperview];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.savedPhotosManager = [[GGKSavedPhotosManager alloc] init];
    
    // Report focus (and exposure) status in real time.
    [self addObserver:self forKeyPath:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    
    // Set up the camera.
    GGKCaptureManager *theCaptureManager = [[GGKCaptureManager alloc] init];
    theCaptureManager.delegate = self;
    [theCaptureManager setUpSession];
    [theCaptureManager addPreviewLayerToView:self.videoPreviewView];
    [theCaptureManager startSession];
    self.captureManager = theCaptureManager;
}

- (IBAction)viewPhotos
{
    [self.savedPhotosManager viewPhotosViaButton:self.cameraRollButton];
}

- (IBAction)viewPhotos2
{
    [self.savedPhotosManager viewPhotosViaButton:self.cameraRollButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}

@end
