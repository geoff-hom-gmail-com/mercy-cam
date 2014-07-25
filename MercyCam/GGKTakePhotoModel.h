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
@property (weak, nonatomic) id <GGKTakePhotoModelDelegate> delegate;
// The input capture device. E.g., the rear camera.
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, assign) GGKTakePhotoModelFocusAndExposureStatus focusAndExposureStatus;
@property (nonatomic, strong) AVCaptureSession *captureSession;
// Override.
- (void)dealloc;
// Remove current session from memory.
- (void)destroyCaptureSession;
// Focus at the given point (in device space). Also lock exposure.
- (void)focusAtPoint:(CGPoint)thePoint;
// Lock exposure. If the focus is also locked, then notify that both are locked.
- (void)handleLockRequestedAndExposureIsSteady:(NSTimer *)theTimer;
// Either focus at the point or unfocus.
// Story: User taps on object. Focus and exposure auto-adjust and lock there. User taps again in view. Focus and exposure return to continuous. (If the user taps again before both focus and exposure lock, then the new tap will be the POI and both will relock.)
- (void)handleUserTappedAtDevicePoint:(CGPoint)theDevicePoint;
// Notify delegate.
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// Override.
- (id)init;
// Make a new capture session.
- (void)makeCaptureSession;
// Override.
// KVO. After setting the exposure POI, we want to know when the exposure is steady, so we can lock it. If the device's exposure stops adjusting, then we see if it stays steady long enough (via a timer).
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
// Return the video orientation matching the device orientation.
- (AVCaptureVideoOrientation)properCaptureVideoOrientation;
// Start the capture session. Asychronous.
- (void)startCaptureSession;
// Stop the capture session.
- (void)stopCaptureSession;
// Take a photo.
- (void)takePhoto;
// Set focus, exposure and white balance to be continuous. (And reset points of interest.)
- (void)unlockFocus;
@end
