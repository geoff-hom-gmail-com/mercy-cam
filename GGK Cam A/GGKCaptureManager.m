//
//  GGKCaptureManager.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKCaptureManager.h"

//BOOL GGKDebugCamera = YES;
BOOL GGKDebugCamera = NO;

@interface GGKCaptureManager ()
// For showing the user and converting the tap point to device space.
// temp move to .h
//@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

// For invalidating the timer if the exposure is adjusted.
@property (nonatomic, strong) NSTimer *exposureUnadjustedTimer;


// temp move to .h
//@property (nonatomic, strong) AVCaptureSession *session;

- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer;
// So, lock it. If the focus is also locked, then notify that both are locked.

// Story: User taps on object. Focus and exposure auto-adjust and lock there. User taps again in view. Focus and exposure return to continuous. (If the user taps again before both focus and exposure lock, then the new tap will be the POI and both will relock.)
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// So, notify delegate.

// KVO. After setting the exposure POI, we want to know when the exposure is steady, so we can lock it. If the device's exposure stops adjusting, then we see if it stays steady long enough (via a timer). 
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end

@implementation GGKCaptureManager

//- (void)testAddPreviewLayerToLayer:(CALayer *)theLayer {
//    self.captureVideoPreviewLayer.contents = nil;
//    self.captureVideoPreviewLayer.session = self.session;
////    [self.captureVideoPreviewLayer initWithSession:self.session];
//    [theLayer addSublayer:self.captureVideoPreviewLayer];
//}

- (void)addPreviewLayerToView:(UIView *)theView {
    self.captureVideoPreviewLayer.frame = theView.bounds;
    CALayer *theViewLayer = theView.layer;
    
    // set color to orange; works if preview layer not added
    // if preview added, orange appears for a bit
//    theViewLayer.backgroundColor = [UIColor orangeColor].CGColor;
    
    //testing; add a different layer
    // shows red (over orange of root layer)
    CALayer *aTestLayer = [CALayer layer];
    aTestLayer.frame = theView.bounds;
//    aTestLayer.backgroundColor = [UIColor redColor].CGColor;
//    [theViewLayer addSublayer:aTestLayer];

//    self.captureVideoPreviewLayer.backgroundColor = [UIColor redColor].CGColor;
    [theViewLayer addSublayer:self.captureVideoPreviewLayer];
    
    // Story: User taps on object. Focus locks there. User taps again in view. Focus returns to continuous.
    UITapGestureRecognizer *aSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTappedInCameraView:)];
    aSingleTapGestureRecognizer.numberOfTapsRequired = 1;
    [theView addGestureRecognizer:aSingleTapGestureRecognizer];
}



- (void)correctThePreviewOrientation:(UIView *)theView
{
    self.captureVideoPreviewLayer.connection.videoOrientation = [self theCorrectCaptureVideoOrientation];
    self.captureVideoPreviewLayer.frame = theView.bounds;
}
- (void)dealloc {
//    NSLog(@"CM dealloc");
    [self removeObserver:self forKeyPath:@"device.adjustingExposure"];
    [self removeObserver:self forKeyPath:@"device.focusMode"];
}
- (void)focusAtPoint:(CGPoint)thePoint
{
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.device lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        
        self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusLocking;
        
        // To lock the focus at a point, we set the POI, then do an auto-focus.
        if (self.device.focusPointOfInterestSupported) {
            
            self.device.focusPointOfInterest = thePoint;
        }
        self.device.focusMode = AVCaptureFocusModeAutoFocus;
        
        // To lock the exposure at a point, we can do the same as with focus. However, if AVCaptureExposureModeAutoExpose isn't supported, then we need a trick to get the POI recognized (lock exposure, then go back to continuous exposure), and we need to listen for when the exposure stops adjusting.
        if (self.device.exposurePointOfInterestSupported) {
            
            self.device.exposurePointOfInterest = thePoint;
        }
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            
            self.device.exposureMode = AVCaptureExposureModeAutoExpose;
        } else {
            
            self.device.exposureMode = AVCaptureExposureModeLocked;
            self.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        // Not changing white balance in this release.
//        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
//            
//            self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
//            NSLog(@"CM fAP: AVCaptureWhiteBalanceModeAutoWhiteBalance.");
//        } else if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
//            
//            self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
//            NSLog(@"CM fAP: AVCaptureWhiteBalanceModeLocked.");
//        }
        
        [self.device unlockForConfiguration];
    }
}

- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer
{
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.device lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        
        self.device.exposureMode = AVCaptureExposureModeLocked;
        [self.device unlockForConfiguration];
        if (self.device.focusMode == AVCaptureFocusModeLocked) {
            
            self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusLocked;
        }
    }
}

- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer
{
    AVCaptureDevice *aCaptureDevice = self.device;
    if (aCaptureDevice == nil) {
        
        NSLog(@"GGK warning: No capture-device input.");
    } else {
        
        if (aCaptureDevice.focusMode != AVCaptureFocusModeLocked ||
            aCaptureDevice.exposureMode != AVCaptureExposureModeLocked) {
            
            CGPoint theTapPoint = [theTapGestureRecognizer locationInView:theTapGestureRecognizer.view];
            CGPoint theConvertedTapPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:theTapPoint];
            [self focusAtPoint:theConvertedTapPoint];
        } else {
            
            [self unlockFocus];
        }
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self.delegate captureManagerDidTakePhoto:self];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [self addObserver:self forKeyPath:@"device.adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"device.focusMode" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:@"device.adjustingExposure"]) {
        
        if (GGKDebugCamera) {
            
            NSString *aString = (self.device.adjustingExposure) ? @"Yes" : @"No";
            NSLog(@"adjusting exposure: %@", aString);
        }
        
        if (self.focusAndExposureStatus == GGKCaptureManagerFocusAndExposureStatusLocking) {
            
            // When the exposure isn't being adjusted, time it to see if it stays steady.
            if (self.device.adjustingExposure) {
                
                [self.exposureUnadjustedTimer invalidate];
                self.exposureUnadjustedTimer = nil;
            } else {
                
                NSTimeInterval theExposureIsSteadyTimeInterval = 0.5;
                NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:theExposureIsSteadyTimeInterval target:self selector:@selector(handleLockRequestedAndExposureIsSteady:) userInfo:nil repeats:NO];
                self.exposureUnadjustedTimer = aTimer;
            }
        }
    } else if ([theKeyPath isEqualToString:@"device.focusMode"]) {
        
        if (self.focusAndExposureStatus == GGKCaptureManagerFocusAndExposureStatusLocking &&
            self.device.focusMode == AVCaptureFocusModeLocked &&
            self.device.exposureMode == AVCaptureExposureModeLocked) {
            
            self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusLocked;
        }
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)setUpSession
{
    AVCaptureSession *aCaptureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *aCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *aCameraCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:aCameraCaptureDevice error:&error];
    if (!aCameraCaptureDeviceInput) {
        
        // handle error
        NSLog(@"GGK warning: Error getting camera input: %@", [error localizedDescription]);
    }
    if ([aCaptureSession canAddInput:aCameraCaptureDeviceInput]) {
        
        [aCaptureSession addInput:aCameraCaptureDeviceInput];
        self.device = aCameraCaptureDeviceInput.device;
        
        // Make sure the device has the default settings.
        [self unlockFocus];
        
//        NSLog(@"CM sUS: capture-device model ID: %@", self.device.modelID);
        NSLog(@"CM sUS: capture-device localized name: %@", self.device.localizedName);
//        NSLog(@"CM sUS: capture-device unique ID: %@", self.device.uniqueID);
        
        NSString *aString = (self.device.lowLightBoostSupported) ? @"Yes" : @"No";
//        NSLog(@"CM sUS: low-light boost supported: %@", aString);
        
        aString = (self.device.subjectAreaChangeMonitoringEnabled) ? @"Yes" : @"No";
//        NSLog(@"CM sUS: subject-area-change monitoring enabled: %@", aString);
        
        aString = (self.device.focusPointOfInterestSupported) ? @"Yes" : @"No";
//        NSLog(@"CM sUS: focus point-of-interest supported: %@", aString);
        
        aString = (self.device.exposurePointOfInterestSupported) ? @"Yes" : @"No";
//        NSLog(@"CM sUS: exposure point-of-interest supported: %@", aString);
    }
    
    AVCaptureStillImageOutput *aCaptureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([aCaptureSession canAddOutput:aCaptureStillImageOutput]) {
        [aCaptureSession addOutput:aCaptureStillImageOutput];
    }
    aCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:aCaptureSession];
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
    self.session = aCaptureSession;
}
- (void)startSession {
    //testing
//    self.captureVideoPreviewLayer.session = self.session;
    //replace preview layer with new one
//    if (self.captureVideoPreviewLayer.delegate == nil) {
//        NSLog(@"delegate1 nil");
//    } else {
//        NSLog(@"delegate1 is not nil");
//    }
//    if (self.captureVideoPreviewLayer.superlayer.delegate == nil) {
//        NSLog(@"delegate2 nil");
//    } else {
//        NSLog(@"delegate2 is not nil");
//    }
//    UIView *thePreviewView = self.captureVideoPreviewLayer.superlayer.delegate;
//    [self.captureVideoPreviewLayer removeFromSuperlayer];
//    
//    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
//    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    aCaptureVideoPreviewLayer.frame = thePreviewView.bounds;
//    CALayer *viewLayer = thePreviewView.layer;
//    [viewLayer addSublayer:aCaptureVideoPreviewLayer];
//    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
    
    // This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [self.session startRunning];
    }];
}
- (void)stopSession {
    [self.session stopRunning];
    
    //testing
//    self.captureVideoPreviewLayer.session = nil;
}
- (void)takePhoto {
    
//    NSLog(@"CM takePhoto called");
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.session.outputs[0];
    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (aCaptureConnection != nil) {
        
        aCaptureConnection.videoOrientation = [self theCorrectCaptureVideoOrientation];
        
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

- (AVCaptureVideoOrientation)theCorrectCaptureVideoOrientation
{
    AVCaptureVideoOrientation aCaptureVideoOrientation;
    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (theInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        
        aCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    } else if (theInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        aCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else if (theInterfaceOrientation == UIInterfaceOrientationPortrait) {
        
        aCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    } else {
        
        aCaptureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    return aCaptureVideoOrientation;
}

- (void)unlockFocus
{
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.device lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        
        CGPoint theCenterPoint = CGPointMake(0.5f, 0.5f);
        self.device.focusPointOfInterest = theCenterPoint;
        self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.device.exposurePointOfInterest = theCenterPoint;
        self.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        [self.device unlockForConfiguration];
        self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusContinuous;
    }
}

//testing
//- (void)removePreviewLayer {
//    
//    
////    [self.captureVideoPreviewLayer removeFromSuperlayer];
////    self.captureVideoPreviewLayer.session = nil;
//    NSLog(@"CM rPL");
//}
//testing
//- (void)addPreviewLayerToViewTesting:(UIView *)theView {
////    self.captureVideoPreviewLayer.frame = theView.bounds;
//    NSLog(@"aPLTVT");
////    CALayer *viewLayer = theView.layer;
////    [viewLayer addSublayer:self.captureVideoPreviewLayer];
//}
//
//- (void)replacePreviewLayerWithNewOneToView:(UIView *)theView {
//    NSLog(@"CM rPLWNOTV");
////    UIView *thePreviewView = self.captureVideoPreviewLayer.superlayer.delegate;
//    [self.captureVideoPreviewLayer removeFromSuperlayer];
//    self.captureVideoPreviewLayer.session = nil;
//    
//    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
//    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    aCaptureVideoPreviewLayer.frame = theView.bounds;
//    CALayer *viewLayer = theView.layer;
//    [viewLayer addSublayer:aCaptureVideoPreviewLayer];
//    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
//}
@end
