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
// For invalidating the timer if the exposure is adjusted.
@property (nonatomic, strong) NSTimer *exposureUnadjustedTimer;
// Lock exposure. If the focus is also locked, then notify that both are locked.
- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer;
// Notify delegate.
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// KVO. After setting the exposure POI, we want to know when the exposure is steady, so we can lock it. If the device's exposure stops adjusting, then we see if it stays steady long enough (via a timer). 
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@end

@implementation GGKCaptureManager
- (void)dealloc {
//    NSLog(@"CM dealloc");
    [self removeObserver:self forKeyPath:@"device.adjustingExposure"];
    [self removeObserver:self forKeyPath:@"device.focusMode"];
}
- (void)destroySession {
    [self.session stopRunning];
    self.session = nil;
}
- (void)focusAtPoint:(CGPoint)thePoint {
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
- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer {
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
- (void)handleUserTappedAtDevicePoint:(CGPoint)theDevicePoint {
    AVCaptureDevice *aCaptureDevice = self.device;
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
- (void)makeSession {
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
        //        NSLog(@"CM mS: capture-device model ID: %@", self.device.modelID);
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
    self.session = aCaptureSession;
}
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
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
- (void)startSession {
    // This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [self.session startRunning];
    }];
}
- (void)takePhoto {
//    NSLog(@"CM takePhoto called");
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.session.outputs[0];
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
        UIImageWriteToSavedPhotosAlbum(nil, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
- (void)unlockFocus {
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
@end
