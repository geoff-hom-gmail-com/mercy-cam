//
//  GGKCaptureManager.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKCaptureManager.h"

@implementation GGKCaptureManager

- (void)focusAtPoint:(CGPoint)thePoint
{
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.device lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        
        // To lock the focus at a point, we set the POI, then do an auto-focus.
        
        if (self.device.focusPointOfInterestSupported) {
            
            self.device.focusPointOfInterest = thePoint;
        }
//        self.device.focusMode = AVCaptureFocusModeAutoFocus;
        
        if (self.device.exposurePointOfInterestSupported) {
            
            self.device.exposurePointOfInterest = thePoint;
        }
        // testing
        self.device.focusMode = AVCaptureFocusModeAutoFocus;
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            
            self.device.exposureMode = AVCaptureExposureModeAutoExpose;
            NSLog(@"CM fAP: AVCaptureExposureModeAutoExpose.");
        } else if ([self.device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            
//            self.device.exposureMode = AVCaptureExposureModeLocked;
//            NSLog(@"CM fAP: AVCaptureExposureModeLocked.");
        }
        
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

- (id)init
{
    self = [super init];
    if (self != nil) {
		
    }
    return self;
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

- (void)unlockFocus
{
    NSError *anError;
    BOOL aDeviceMayBeConfigured = [self.device lockForConfiguration:&anError];
    if (aDeviceMayBeConfigured) {
        
        CGPoint theCenterPoint = CGPointMake(0.5f, 0.5f);
        self.device.focusPointOfInterest = theCenterPoint;
        self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
//        self.device.exposurePointOfInterest = theCenterPoint;
        self.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        [self.device unlockForConfiguration];
    }
}

@end
