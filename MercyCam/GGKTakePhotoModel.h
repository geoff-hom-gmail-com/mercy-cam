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
// Model's mode.
// Planning: default.
// Shooting: user starts trigger.
typedef NS_ENUM(NSInteger, GGKTakePhotoModelMode) {
    GGKTakePhotoModelModePlanning,
    GGKTakePhotoModelModeShooting
};
// The combined status of the camera's focus and exposure. The assumption is that both are continuously adjusting, both are in the process of locking (one may be locked, and the other may be locking), or both are locked.
typedef NS_ENUM(NSInteger, GGKTakePhotoModelFocusAndExposureStatus) {
    GGKTakePhotoModelFocusAndExposureStatusContinuous,
    GGKTakePhotoModelFocusAndExposureStatusLocking,
    GGKTakePhotoModelFocusAndExposureStatusLocked
};

@protocol GGKTakePhotoModelDelegate
// Sent after the mode changed (planning, shooting, etc.).
- (void)takePhotoModelDidChangeMode:(id)sender;
// Sent after a photo was taken and saved (to the camera roll). If a photo couldn't be taken (e.g., no camera), this is still sent.
- (void)takePhotoModelDidTakePhoto:(id)sender;
// Sent after the camera's focus-and-exposure status has changed. (Focus and exposure are linked for convenience.)
- (void)takePhotoModelFocusAndExposureStatusDidChange:(id)sender;
// Sent after the one-second repeating timer fired.
- (void)takePhotoModelUpdateTimerDidFire:(id)sender;
// Sent before a photo is taken.
- (void)takePhotoModelWillTakePhoto:(id)sender;
@end

@interface GGKTakePhotoModel : NSObject
// The input capture device. E.g., the rear camera.
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (weak, nonatomic) id <GGKTakePhotoModelDelegate> delegate;
// For invalidating the timer if the exposure is adjusted.
@property (nonatomic, strong) NSTimer *exposureUnadjustedTimer;
@property (nonatomic, assign) GGKTakePhotoModelFocusAndExposureStatus focusAndExposureStatus;
@property (assign, nonatomic) GGKTakePhotoModelMode mode;
@property (assign, nonatomic) NSInteger numberOfPhotosTakenInteger;
// Custom accessors.
@property (assign, nonatomic) NSInteger numberOfPhotosToTakeInteger;
// Number of seconds since start or previous photo taken.
@property (assign, nonatomic) NSInteger numberOfSecondsWaitedInteger;
// Timer goes off each second and serves two purposes: 1) UI can be updated each second, so user can get visual feedback. 2) We can track how many seconds have passed, to know when to take a photo.
// Need this property to invalidate the timer later.
@property (nonatomic, strong) NSTimer *oneSecondRepeatingTimer;
// Override.
- (void)dealloc;
// Remove current session from memory. (C.f., stopCaptureSession.)
- (void)destroyCaptureSession;
// Whether to start the timer.
// Stub. Returns NO.
- (BOOL)doStartTimer;
// Whether to stop the timer.
// Stub. Returns YES.
- (BOOL)doStopTimer;
// Focus at the given point (in device space). Also lock exposure.
- (void)focusAtPoint:(CGPoint)thePoint;
// Lock exposure. If the focus is also locked, then notify that both are locked.
- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer;

// Called after the repeating one-second timer fires.
// What: Notify delegate. In subclass, determine whether to take photo and whether to stop timer.

- (void)handleOneSecondTimerFired;

// Notify delegate. If no timer still going, then either take another photo or switch out of shooting mode.
- (void)handlePhotoTaken;
// Either focus at the point or unfocus.
// Story: User taps on object. Focus and exposure auto-adjust and lock there. User taps again in view. Focus and exposure return to continuous. (If the user taps again before both focus and exposure lock, then the new tap will be the POI and both will relock.)
- (void)handleUserTappedAtDevicePoint:(CGPoint)theDevicePoint;
// UIImageWriteToSavedPhotosAlbum() requires this method signature. In this case, it means a photo was taken. Redirect there.
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
// Starts a timer to know when to take photos.
- (void)startTimer;
// Change to shooting mode. Start timer or take photo.
- (void)startTrigger;
// Stop the capture session. (Remains in memory. C.f., destroyCaptureSession.)
- (void)stopCaptureSession;
- (void)stopOneSecondRepeatingTimer;
// Notify delegate that we will take photo. Take a photo.
- (void)takePhoto;
// Set focus, exposure and white balance to be continuous. (And reset points of interest.)
- (void)unlockFocus;
@end
