//
//  GGKCaptureManager.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

// This manages a capture session for taking photos from the rear camera: Input is the rear camera; output is a still image.

#import <AVFoundation/AVFoundation.h>

extern BOOL GGKDebugCamera;

// The combined status of the camera's focus and exposure. The assumption is that both are continuously adjusting, both are in the process of locking (one may be locked, and the other may be locking), or both are locked.
typedef enum {
    GGKCaptureManagerFocusAndExposureStatusContinuous,
    GGKCaptureManagerFocusAndExposureStatusLocking,
    GGKCaptureManagerFocusAndExposureStatusLocked
} GGKCaptureManagerFocusAndExposureStatus;

@protocol GGKCaptureManagerDelegate
// Sent after a photo was taken and saved (to the camera roll). If a photo couldn't be taken (e.g., no camera), this is still sent.
- (void)captureManagerDidTakePhoto:(id)sender;
@end

@interface GGKCaptureManager : NSObject
@property (weak, nonatomic) id <GGKCaptureManagerDelegate> delegate;
// The input capture device. E.g., the rear camera.
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, assign) GGKCaptureManagerFocusAndExposureStatus focusAndExposureStatus;
@property (nonatomic, strong) AVCaptureSession *session;
// Override.
- (void)dealloc;
// Remove current session from memory.
- (void)destroySession;
// Focus at the given point (in device space). Also lock exposure.
- (void)focusAtPoint:(CGPoint)thePoint;
// Either focus at the point or unfocus.
// Story: User taps on object. Focus and exposure auto-adjust and lock there. User taps again in view. Focus and exposure return to continuous. (If the user taps again before both focus and exposure lock, then the new tap will be the POI and both will relock.)
- (void)handleUserTappedAtDevicePoint:(CGPoint)theDevicePoint;
// Override.
- (id)init;
// Make a new capture session.
- (void)makeSession;
// Return the video orientation matching the device orientation.
- (AVCaptureVideoOrientation)properCaptureVideoOrientation;
// Start the session. Asychronous.
- (void)startSession;
// Take a photo.
- (void)takePhoto;
// Set focus, exposure and white balance to be continuous. (And reset points of interest.)
- (void)unlockFocus;
@end
