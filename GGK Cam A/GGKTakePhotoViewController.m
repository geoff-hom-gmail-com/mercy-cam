//
//  GGKTakePhotoViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GGKTakePhotoViewController.h"

@interface GGKTakePhotoViewController ()

@property (assign, nonatomic) BOOL appWillEnterForegroundNotificationIsBeingObserved;

@property (strong, nonatomic) AVCaptureSession *captureSession;

@property (strong, nonatomic) UIPopoverController *savedPhotosPopoverController;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// So, update the image in the button for showing the camera roll. If another photo is supposed to be taken, do it.

// Show most-recent photo on button for showing camera roll.
- (void)showMostRecentPhotoOnButton;

@end

@implementation GGKTakePhotoViewController

- (void)dealloc
{    
    [self.captureSession stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{    
    [self showMostRecentPhotoOnButton];
//        self.startTimerButton.enabled = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)playButtonSound
{
    [self.soundModel playButtonTapSound];
}

- (void)showMostRecentPhotoOnButton
{    
    // Show thumbnail on button for showing camera roll.
    void (^showPhotoOnButton)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *photoAsset, NSUInteger index, BOOL *stop) {
        
        // End of enumeration is signalled by asset == nil.
        if (photoAsset == nil) {
            
            return;
        }
        
        CGImageRef aPhotoThumbnailImageRef = [photoAsset thumbnail];
        UIImage *aPhotoImage = [UIImage imageWithCGImage:aPhotoThumbnailImageRef];
        [self.cameraRollButton setImage:aPhotoImage forState:UIControlStateNormal];
        
        // If we don't the title to nil, it still shows along the edge.
        [self.cameraRollButton setTitle:nil forState:UIControlStateNormal];
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
    
    // If no photos, show this text.
    [self.cameraRollButton setTitle:@"Saved photos" forState:UIControlStateNormal];
    
    ALAssetsLibrary *theAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [theAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:showMostRecentPhotoInGroupOnButton failureBlock:^(NSError *error) {
        
        NSLog(@"Warning: Couldn't see saved photos.");
    }];
}

- (IBAction)takePhoto
{    
    NSLog(@"SDPVC takePhoto called");
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureSession.outputs[0];
    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
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
    
    if (aCaptureConnection != nil) {
        
        [aCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:aCaptureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer != NULL) {
                
                NSData *theImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *theImage = [[UIImage alloc] initWithData:theImageData];
                UIImageWriteToSavedPhotosAlbum(theImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
    } else {
        
        NSLog(@"GGK warning: aCaptureConnection nil");
        UIImageWriteToSavedPhotosAlbum(nil, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.soundModel = [[GGKSoundModel alloc] init];
    
    AVCaptureSession *aCaptureSession = [[AVCaptureSession alloc] init];
    //    AVCaptureSession *aCaptureSession = //get from another class
    
    AVCaptureDevice *aCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *aCameraCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:aCameraCaptureDevice error:&error];
    if (!aCameraCaptureDeviceInput) {
        
        // handle error
        NSLog(@"GGK Warning: error getting camera input.");
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
    
    self.appWillEnterForegroundNotificationIsBeingObserved = NO;
    
}

- (IBAction)viewPhotos
{    
    NSLog(@"viewPhotos called");
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        // UIImagePickerController browser on iPad must be presented in a popover.
        
        UIImagePickerController *anImagePickerController = [[UIImagePickerController alloc] init];
        anImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        anImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        anImagePickerController.delegate = self;
        anImagePickerController.allowsEditing = NO;
        
        UIPopoverController *aPopoverController = [[UIPopoverController alloc] initWithContentViewController:anImagePickerController];
        [aPopoverController presentPopoverFromRect:self.cameraRollButton.bounds inView:self.cameraRollButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.savedPhotosPopoverController = aPopoverController;
    }
    
    
}

// Do what we do in -viewWillAppear (except adding the observer that calls this method).

// Story: View will appear to user. User sees updated view.
// Whether the view appears from another view in this app or from the app entering the foreground, the user should see an updated view. -viewWillAppear should call this method, and -viewWillAppear should listen for UIApplicationWillEnterForegroundNotification; when that notification  the app wthe notification


// UIViewController override. Start visible updates. Check for app coming from background/lock.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If the app returns from background/lock to this view, then -viewWillAppear isn't called. However, the user expects the same behavior. So, we'll listen for the appropriate notification.
    if (!self.appWillEnterForegroundNotificationIsBeingObserved) {
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [self viewWillAppear:animated];
        }];
        self.appWillEnterForegroundNotificationIsBeingObserved = YES;
    }
    
    [self showMostRecentPhotoOnButton];
}

// UIViewController override. Stop anything from -viewWillAppear.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.appWillEnterForegroundNotificationIsBeingObserved) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        self.appWillEnterForegroundNotificationIsBeingObserved = NO;
    }
}

@end
