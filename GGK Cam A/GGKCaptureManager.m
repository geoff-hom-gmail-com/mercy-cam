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

// For tracking whether the observer exists or was removed (or never added). Don't want to over-add or over-remove it.
@property (nonatomic, assign) BOOL adjustingExposureObserverExists;

// For converting the tap point to device space.
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

// For invalidating the timer if the exposure is adjusted.
@property (nonatomic, strong) NSTimer *exposureUnadjustedTimer;

// If the observer doesn't exist, add it.
- (void)addAdjustingExposureObserver;

// For removing observers.
- (void)dealloc;

// So, lock the exposure. We don't need to monitor exposure adjustment anymore, so remove the observer.
- (void)handleExposureLockRequestedAndExposureIsSteady:(NSTimer *)theTimer;

// Story: User taps on object. Focus and exposure auto-adjust and lock there. User taps again in view. Focus and exposure return to continuous. (If the user taps again before both focus and exposure lock, then the new tap will be the POI and both will relock.)
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer;

// KVO. After setting the exposure POI, we want to know when the exposure is steady, so we can lock it. If the device's exposure stops adjusting, then we see if it stays steady long enough (via a timer). If so, the timer will lock the exposure.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// If the observer exists, remove it.
- (void)removeAdjustingExposureObserver;

@end

@implementation GGKCaptureManager

- (void)addAdjustingExposureObserver
{
    if (!self.adjustingExposureObserverExists) {
        
        [self addObserver:self forKeyPath:@"device.adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
        self.adjustingExposureObserverExists = YES;
        if (GGKDebugCamera) {
            
            NSLog(@"CM: device.adjustingExposure observer added.");
        }
    }
}

- (void)addPreviewLayerToView:(UIView *)theView
{
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    aCaptureVideoPreviewLayer.frame = theView.bounds;
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    CALayer *viewLayer = theView.layer;
    [viewLayer addSublayer:aCaptureVideoPreviewLayer];
    
    // Story: User taps on object. Focus locks there. User taps again in view. Focus returns to continuous.
    UITapGestureRecognizer *aSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTappedInCameraView:)];
    aSingleTapGestureRecognizer.numberOfTapsRequired = 1;
    [theView addGestureRecognizer:aSingleTapGestureRecognizer];
    
    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
}

- (void)correctThePreviewOrientation:(UIView *)theView
{
    self.captureVideoPreviewLayer.connection.videoOrientation = [self theCorrectCaptureVideoOrientation];
    self.captureVideoPreviewLayer.frame = theView.bounds;
}

- (void)dealloc
{
    [self removeAdjustingExposureObserver];
}

- (void)focusAtPoint:(CGPoint)thePoint
{
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.device lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        
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
            self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusLocked;
        } else {
            
            // We lock the exposure, then add the observer. This way, device.adjustingExposure will start as NO, and the first trigger will be on YES.
            self.device.exposureMode = AVCaptureExposureModeLocked;
            [self addAdjustingExposureObserver];
            self.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusLocking;
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

- (void)handleExposureLockRequestedAndExposureIsSteady:(NSTimer *)theTimer
{
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.device lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        
        // Remove observer, then lock exposure. That's because the latter seems to trigger KVO on device.adjustingExposure.
        [self removeAdjustingExposureObserver];
        self.device.exposureMode = AVCaptureExposureModeLocked;
        if (GGKDebugCamera) {
            
            NSLog(@"CM hELRAEIS: AVCaptureExposureModeLocked.");
        }
        
        [self.device unlockForConfiguration];
        
        // We assume the focus is already locked, or will soon be locked so it won't affect the user.
        self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusLocked;
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

- (id)init
{
    self = [super init];
    if (self != nil) {
		
        self.adjustingExposureObserverExists = NO;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:@"device.adjustingExposure"]) {
        
        // Assume observation started on NO, so first call will be YES. When the exposure stops adjusting, start the timer. If exposure adjusts again quickly, invalidate the timer.
        
        if (GGKDebugCamera) {
            
            NSString *aString = (self.device.adjustingExposure) ? @"Yes" : @"No";
            NSLog(@"adjusting exposure: %@", aString);
        }        
        if (self.device.adjustingExposure) {
            
            [self.exposureUnadjustedTimer invalidate];
            self.exposureUnadjustedTimer = nil;
        } else {
            
            NSTimeInterval theExposureIsSteadyTimeInterval = 0.5;
            NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:theExposureIsSteadyTimeInterval target:self selector:@selector(handleExposureLockRequestedAndExposureIsSteady:) userInfo:nil repeats:NO];
            self.exposureUnadjustedTimer = aTimer;
        }
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)removeAdjustingExposureObserver
{
    if (self.adjustingExposureObserverExists) {
        
        [self removeObserver:self forKeyPath:@"device.adjustingExposure"];
        self.adjustingExposureObserverExists = NO;
        if (GGKDebugCamera) {
            
            NSLog(@"CM: device.adjustingExposure observer removed.");
        }
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
        NSLog(@"GGK warning: Error getting camera input.");
    }
    if ([aCaptureSession canAddInput:aCameraCaptureDeviceInput]) {
        
        [aCaptureSession addInput:aCameraCaptureDeviceInput];
        self.device = aCameraCaptureDeviceInput.device;
        self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusContinuous;
        
//        NSLog(@"CM sUS: capture-device model ID: %@", self.device.modelID);
        NSLog(@"CM sUS: capture-device localized name: %@", self.device.localizedName);
//        NSLog(@"CM sUS: capture-device unique ID: %@", self.device.uniqueID);
        
        NSString *aString = (self.device.lowLightBoostSupported) ? @"Yes" : @"No";
        NSLog(@"CM sUS: low-light boost supported: %@", aString);
        
        aString = (self.device.subjectAreaChangeMonitoringEnabled) ? @"Yes" : @"No";
        NSLog(@"CM sUS: subject-area-change monitoring enabled: %@", aString);
        
        aString = (self.device.focusPointOfInterestSupported) ? @"Yes" : @"No";
        NSLog(@"CM sUS: focus point-of-interest supported: %@", aString);
        
        aString = (self.device.exposurePointOfInterestSupported) ? @"Yes" : @"No";
        NSLog(@"CM sUS: exposure point-of-interest supported: %@", aString);
    }
    
    AVCaptureStillImageOutput *aCaptureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([aCaptureSession canAddOutput:aCaptureStillImageOutput]) {
        
        [aCaptureSession addOutput:aCaptureStillImageOutput];
    }
    
    aCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.session = aCaptureSession;
}

- (void)startSession
{
    // This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [self.session startRunning];
    }];
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
        [self removeAdjustingExposureObserver];
        self.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        [self.device unlockForConfiguration];
        self.focusAndExposureStatus = GGKCaptureManagerFocusAndExposureStatusContinuous;
    }
}

@end
