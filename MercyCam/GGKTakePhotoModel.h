//
//  GGKCaptureManager.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

// A model for taking photos via a capture session.

#import <AVFoundation/AVFoundation.h>

extern BOOL GGKDebugCamera;

// The combined status of the camera's focus and exposure. The assumption is that both are continuously adjusting, both are in the process of locking (one may be locked, and the other may be locking), or both are locked.
typedef NS_ENUM(NSInteger, GGKTakePhotoModelFocusAndExposureStatus) {
    GGKTakePhotoModelFocusAndExposureStatusContinuous,
    GGKTakePhotoModelFocusAndExposureStatusLocking,
    GGKTakePhotoModelFocusAndExposureStatusLocked
};

@protocol GGKTakePhotoModelDelegate
// Sent after a photo was taken and saved (to the camera roll). If a photo couldn't be taken (e.g., no camera), this is still sent.
- (void)takePhotoModelDidTakePhoto:(id)sender;
// Sent after the camera's focus-and-exposure status has changed. (Focus and exposure are linked for convenience.)
- (void)takePhotoModelFocusAndExposureStatusDidChange:(id)sender;
@end

@interface GGKTakePhotoModel : NSObject
// The input capture device. E.g., the rear camera.
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (weak, nonatomic) id <GGKTakePhotoModelDelegate> delegate;
// For invalidating the timer if the exposure is adjusted.
@property (nonatomic, strong) NSTimer *exposureUnadjustedTimer;
@property (nonatomic, assign) GGKTakePhotoModelFocusAndExposureStatus focusAndExposureStatus;
@property (assign, nonatomic) NSInteger numberOfPhotosTakenInteger;
@property (assign, nonatomic) NSInteger numberOfSecondsWaitedInteger;
// Timer goes off each second and serves two purposes: 1) UI can be updated each second, so user can get visual feedback. 2) We can track how many seconds have passed, to know when to take a photo.
// Need this property to invalidate the timer later.
@property (nonatomic, strong) NSTimer *oneSecondRepeatingTimer;
// Override.
- (void)dealloc;
// Remove current session from memory. (C.f., stopCaptureSession.)
- (void)destroyCaptureSession;
// Focus at the given point (in device space). Also lock exposure.
- (void)focusAtPoint:(CGPoint)thePoint;
// Lock exposure. If the focus is also locked, then notify that both are locked.
- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer;
// Either focus at the point or unfocus.
// Story: User taps on object. Focus and exposure auto-adjust and lock there. User taps again in view. Focus and exposure return to continuous. (If the user taps again before both focus and exposure lock, then the new tap will be the POI and both will relock.)
- (void)handleUserTappedAtDevicePoint:(CGPoint)theDevicePoint;
// Notify delegate.
- (void)image:(UIImage *)theImage didFinishSavingWithError:(NSError *)theError contextInfo:(void *)theContextInfo;
// Override.
- (id)init;
// Make a new capture session.
- (void)makeCaptureSession;
// Override.
// After setting the exposure POI, we want to know when the exposure is steady, so we can lock it. If the device's exposure stops adjusting, then we see if it stays steady long enough (via a timer).
// Check if both focus and exposure are locked.
// If focus-and-exposure status changed, notify delegate.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
// Return the video orientation that matches the device orientation.
- (AVCaptureVideoOrientation)properCaptureVideoOrientation;
// Start the capture session. Asychronous.
- (void)startCaptureSession;
// Stop the capture session. (Remains in memory. C.f., destroyCaptureSession.)
- (void)stopCaptureSession;
// Take a photo.
- (void)takePhoto;
// Set focus, exposure and white balance to be continuous. (And reset points of interest.)
- (void)unlockFocus;
@end
