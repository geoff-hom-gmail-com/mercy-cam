//
//  GGKSimpleDelayedPhotoViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "GGKSimpleDelayedPhotoViewController.h"

@interface GGKSimpleDelayedPhotoViewController ()

@property (strong, nonatomic) AVCaptureSession *captureSession;

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// So, update the image in the button for showing the camera roll.

// Show most-recent photo on button for showing camera roll.
- (void)showMostRecentPhotoOnButton;

@end

@implementation GGKSimpleDelayedPhotoViewController

- (void)dealloc {
    
    [self.captureSession stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [self showMostRecentPhotoOnButton];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)showMostRecentPhotoOnButton {
    
    // Show thumbnail on button for showing camera roll.
    void (^showPhotoOnButton)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *photoAsset, NSUInteger index, BOOL *stop) {
        
        // End of enumeration is signalled by asset == nil.
        if (photoAsset == nil) {
            
            return;
        }
        
        CGImageRef aPhotoThumbnailImageRef = [photoAsset thumbnail];
        UIImage *aPhotoImage = [UIImage imageWithCGImage:aPhotoThumbnailImageRef];
        [self.cameraRollButton setImage:aPhotoImage forState:UIControlStateNormal];
    };
    
    // Show thumbnail of most-recent photo in group on button for showing camera roll.
    void (^showMostRecentPhotoInGroupOnButton)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        
        // If no photos, skip.
        [ group setAssetsFilter:[ALAssetsFilter allPhotos] ];
        NSInteger theNumberOfPhotos = [group numberOfAssets];
        if (theNumberOfPhotos < 1) {
            
            return;
        }
        
        NSIndexSet *theMostRecentPhotoIndexSet = [NSIndexSet indexSetWithIndex:(theNumberOfPhotos - 1)];
        [group enumerateAssetsAtIndexes:theMostRecentPhotoIndexSet options:0 usingBlock:showPhotoOnButton];
    };
    
    ALAssetsLibrary *theAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [theAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:showMostRecentPhotoInGroupOnButton failureBlock:^(NSError *error) {
        
        NSLog(@"Warning: Couldn't see saved photos.");
    }];
}

- (IBAction)takePhoto {
    
//    NSLog(@"takePhoto called");
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureSession.outputs[0];
    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [aCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:aCaptureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer != NULL) {
            
            NSData *theImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *theImage = [[UIImage alloc] initWithData:theImageData];
            UIImageWriteToSavedPhotosAlbum(theImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }];
//    NSLog(@"takePhoto2 called");
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    NSLog(@"SDPVC vDL called");
    
    AVCaptureSession *aCaptureSession = [[AVCaptureSession alloc] init];
//    AVCaptureSession *aCaptureSession = //get from another class
    
    AVCaptureDevice *aCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *aCameraCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:aCameraCaptureDevice error:&error];
    if (!aCameraCaptureDeviceInput) {
        
        // handle error
        NSLog(@"Warning: error getting camera input.");
    }
    if ([aCaptureSession canAddInput:aCameraCaptureDeviceInput]) {
        
        [aCaptureSession addInput:aCameraCaptureDeviceInput];
    }
    
    AVCaptureStillImageOutput *aCaptureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([aCaptureSession canAddOutput:aCaptureStillImageOutput]) {
        
        [aCaptureSession addOutput:aCaptureStillImageOutput];
    }
    
    aCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Add camera preview.
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:aCaptureSession];
    aCaptureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    CALayer *viewLayer = self.videoPreviewView.layer;
    [viewLayer addSublayer:aCaptureVideoPreviewLayer];
    
    self.captureSession = aCaptureSession;
    
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [aCaptureSession startRunning];
    }];
    
    [self showMostRecentPhotoOnButton];
}

- (IBAction)viewPhotos {
    
    NSLog(@"viewPhotos called");
}

@end
