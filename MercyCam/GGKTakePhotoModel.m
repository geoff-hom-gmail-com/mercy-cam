//
//  GGKCaptureManager.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoModel.h"

//BOOL GGKDebugCamera = YES;
BOOL GGKDebugCamera = NO;

// For KVO.
NSString *CaptureDeviceAdjustingExposureKeyPathString = @"captureDevice.adjustingExposure";
NSString *CaptureDeviceFocusModeKeyPathString = @"captureDevice.focusMode";
NSString *FocusAndExposureStatusKeyPathString = @"focusAndExposureStatus";
NSString *ModeKeyPathString = @"mode";

@implementation GGKTakePhotoModel
// Custom accessors.
- (NSInteger)numberOfPhotosToTakeInteger {
    return 1;
}

- (void)dealloc {
    NSLog(@"TPM dealloc");
    [self destroyCaptureSession];
    [self removeObserver:self forKeyPath:CaptureDeviceAdjustingExposureKeyPathString];
    [self removeObserver:self forKeyPath:CaptureDeviceFocusModeKeyPathString];
    [self removeObserver:self forKeyPath:FocusAndExposureStatusKeyPathString];
    [self removeObserver:self forKeyPath:ModeKeyPathString];
    [self stopOneSecondRepeatingTimer];
}
- (void)destroyCaptureSession {
    [self.captureSession stopRunning];
    self.captureSession = nil;
}
- (BOOL)doStartTimer {
    return NO;
}
- (BOOL)doStopTimer {
    return YES;
}
- (void)focusAtPoint:(CGPoint)thePoint {
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.captureDevice lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        self.focusAndExposureStatus = GGKTakePhotoModelFocusAndExposureStatusLocking;
        // To lock the focus at a point, we set the POI, then do an auto-focus.
        if (self.captureDevice.focusPointOfInterestSupported) {
            self.captureDevice.focusPointOfInterest = thePoint;
        }
        self.captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        // To lock the exposure at a point, we can do the same as with focus. However, if AVCaptureExposureModeAutoExpose isn't supported, then we need a trick to get the POI recognized (lock exposure, then go back to continuous exposure), and we need to listen for when the exposure stops adjusting.
        if (self.captureDevice.exposurePointOfInterestSupported) {
            self.captureDevice.exposurePointOfInterest = thePoint;
        }
        if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            self.captureDevice.exposureMode = AVCaptureExposureModeAutoExpose;
        } else {
            self.captureDevice.exposureMode = AVCaptureExposureModeLocked;
            self.captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        // White balance: not changing in this version.
//        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
//            
//            self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
//            NSLog(@"CM fAP: AVCaptureWhiteBalanceModeAutoWhiteBalance.");
//        } else if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
//            
//            self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
//            NSLog(@"CM fAP: AVCaptureWhiteBalanceModeLocked.");
//        }
        [self.captureDevice unlockForConfiguration];
    }
}
- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer {
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.captureDevice lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        self.captureDevice.exposureMode = AVCaptureExposureModeLocked;
        [self.captureDevice unlockForConfiguration];
        if (self.captureDevice.focusMode == AVCaptureFocusModeLocked) {
            self.focusAndExposureStatus = GGKTakePhotoModelFocusAndExposureStatusLocked;
        }
    }
}
- (void)handleOneSecondTimerFired {
    // Each tick of this timer is 1 sec, so we can use that both to show how much time has passed and to determine if enough time has passed.
    self.numberOfSecondsWaitedInteger++;
    [self.delegate takePhotoModelUpdateTimerDidFire:self];
    if (self.numberOfSecondsWaitedInteger == [self numberOfSecondsToWaitInteger]) {
        [self takePhoto];
        self.numberOfSecondsWaitedInteger = 0;
        if ([self doStopTimer]) {
            [self stopOneSecondRepeatingTimer];
        }
    }
}
- (void)handlePhotoTaken {
    [self.delegate takePhotoModelDidTakePhoto:self];
    if (self.oneSecondRepeatingTimer == nil && self.mode == GGKTakePhotoModelModeShooting) {
        if (self.numberOfPhotosTakenInteger < self.numberOfPhotosToTakeInteger) {
            [self takePhoto];
        } else {
            self.mode = GGKTakePhotoModelModePlanning;
        }
    }
}
- (void)handleUserTappedAtDevicePoint:(CGPoint)theDevicePoint {
    AVCaptureDevice *aCaptureDevice = self.captureDevice;
    if (aCaptureDevice == nil) {
        NSLog(@"GGK warning: No capture-device input.");
    } else {
        if (aCaptureDevice.focusMode != AVCaptureFocusModeLocked ||
            aCaptureDevice.exposureMode != AVCaptureExposureModeLocked) {
            [self focusAtPoint:theDevicePoint];
        } else {
            [self unlockFocus];
        }
    }
}
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self handlePhotoTaken];
}
- (id)init {
    self = [super init];
    if (self != nil) {
        [self addObserver:self forKeyPath:CaptureDeviceAdjustingExposureKeyPathString options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:CaptureDeviceFocusModeKeyPathString options:NSKeyValueObservingOptionNew context:nil];
        // Report focus (and exposure) status in real time.
        [self addObserver:self forKeyPath:FocusAndExposureStatusKeyPathString options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:ModeKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)makeCaptureSession {
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
        self.captureDevice = aCameraCaptureDeviceInput.device;
        // Make sure the device has the default settings.
        [self unlockFocus];
        //        NSLog(@"CM mS: capture-device model ID: %@", self.device.modelID);
        NSLog(@"CM sUS: capture-device localized name: %@", self.captureDevice.localizedName);
        //        NSLog(@"CM sUS: capture-device unique ID: %@", self.device.uniqueID);
        NSString *aString = (self.captureDevice.lowLightBoostSupported) ? @"Yes" : @"No";
        //        NSLog(@"CM sUS: low-light boost supported: %@", aString);
        aString = (self.captureDevice.subjectAreaChangeMonitoringEnabled) ? @"Yes" : @"No";
        //        NSLog(@"CM sUS: subject-area-change monitoring enabled: %@", aString);
        aString = (self.captureDevice.focusPointOfInterestSupported) ? @"Yes" : @"No";
        //        NSLog(@"CM sUS: focus point-of-interest supported: %@", aString);
        aString = (self.captureDevice.exposurePointOfInterestSupported) ? @"Yes" : @"No";
        //        NSLog(@"CM sUS: exposure point-of-interest supported: %@", aString);
    }
    AVCaptureStillImageOutput *aCaptureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([aCaptureSession canAddOutput:aCaptureStillImageOutput]) {
        [aCaptureSession addOutput:aCaptureStillImageOutput];
    }
    aCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    self.captureSession = aCaptureSession;
}
- (NSInteger)numberOfSecondsToWaitInteger {
    return 0;
}
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([theKeyPath isEqualToString:CaptureDeviceAdjustingExposureKeyPathString]) {
        if (self.focusAndExposureStatus == GGKTakePhotoModelFocusAndExposureStatusLocking) {
            // When the exposure isn't being adjusted, time it to see if it stays steady.
            if (self.captureDevice.adjustingExposure) {
                [self.exposureUnadjustedTimer invalidate];
                self.exposureUnadjustedTimer = nil;
            } else {
                NSTimeInterval theExposureIsSteadyTimeInterval = 0.5;
                NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:theExposureIsSteadyTimeInterval target:self selector:@selector(handleLockRequestedAndExposureIsSteady:) userInfo:nil repeats:NO];
                self.exposureUnadjustedTimer = aTimer;
            }
        }
    } else if ([theKeyPath isEqualToString:CaptureDeviceFocusModeKeyPathString]) {
        if (self.focusAndExposureStatus == GGKTakePhotoModelFocusAndExposureStatusLocking &&
            self.captureDevice.focusMode == AVCaptureFocusModeLocked &&
            self.captureDevice.exposureMode == AVCaptureExposureModeLocked) {
            self.focusAndExposureStatus = GGKTakePhotoModelFocusAndExposureStatusLocked;
        }
    } else if ([theKeyPath isEqualToString:FocusAndExposureStatusKeyPathString]) {
        [self.delegate takePhotoModelFocusAndExposureStatusDidChange:self];
    } else if ([theKeyPath isEqualToString:ModeKeyPathString]) {
        [self.delegate takePhotoModelDidChangeMode:self];
    } else {
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}
- (AVCaptureVideoOrientation)properCaptureVideoOrientation {
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
- (void)startCaptureSession {
    // This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [self.captureSession startRunning];
    }];
}
- (void)startTimer {
    self.numberOfSecondsWaitedInteger = 0;
    // Start a timer to count seconds.
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleOneSecondTimerFired) userInfo:nil repeats:YES];
    self.oneSecondRepeatingTimer = aTimer;
}
- (void)startTrigger {
    self.mode = GGKTakePhotoModelModeShooting;
    self.numberOfPhotosTakenInteger = 0;
    if ([self doStartTimer]) {
        [self startTimer];
    } else {
        [self takePhoto];
    }
}
- (void)stopCaptureSession {
    [self.captureSession stopRunning];
}
- (void)stopOneSecondRepeatingTimer {
    [self.oneSecondRepeatingTimer invalidate];
    self.oneSecondRepeatingTimer = nil;
}
- (void)takePhoto {
    [self.delegate takePhotoModelWillTakePhoto:self];
    self.numberOfPhotosTakenInteger++;
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureSession.outputs[0];
    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (aCaptureConnection != nil) {
        aCaptureConnection.videoOrientation = [self properCaptureVideoOrientation];
        [aCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:aCaptureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer != NULL) {
                NSData *theImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *theImage = [[UIImage alloc] initWithData:theImageData];
                UIImageWriteToSavedPhotosAlbum(theImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
    } else {
        NSLog(@"GGK warning: aCaptureConnection nil");
        // To avoid stalling. Didn't think about this much, so there's probably a more robust solution.
        [self handlePhotoTaken];
//        UIImageWriteToSavedPhotosAlbum(nil, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
- (void)unlockFocus {
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.captureDevice lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        CGPoint theCenterPoint = CGPointMake(0.5f, 0.5f);
        self.captureDevice.focusPointOfInterest = theCenterPoint;
        self.captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.captureDevice.exposurePointOfInterest = theCenterPoint;
        self.captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        self.captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        [self.captureDevice unlockForConfiguration];
        self.focusAndExposureStatus = GGKTakePhotoModelFocusAndExposureStatusContinuous;
    }
}
@end
