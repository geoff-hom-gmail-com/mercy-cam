//
//  GGKTakePhotoAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoAbstractViewController.h"

#import "GGKSavedPhotosManager.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}

@end
