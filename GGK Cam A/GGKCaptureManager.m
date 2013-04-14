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
        self.device.focusPointOfInterest = thePoint;
        self.device.focusMode = AVCaptureFocusModeAutoFocus;
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
        
        self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        [self.device unlockForConfiguration];
    }
}

@end
