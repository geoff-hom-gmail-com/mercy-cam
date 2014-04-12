//
//  GGKTakePhotoViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoViewController.h"

#import "UIView+GGKAdditions.h"

// Story: User sees tip. User learns how to focus on an object.
NSString *const ToFocusTipString = @"Tip: To focus on an object, tap it.";

// Story: User sees tip. User learns the focus is locked. User learns how to unlock.
NSString *const ToUnlockFocusTipString = @"Tip: The focus is locked. To unlock, tap anywhere in the view.";

@interface GGKTakePhotoViewController ()

// (For testing.) Show the current camera settings.
- (void)updateCameraDebugLabels;

@end

@implementation GGKTakePhotoViewController

- (void)dealloc {
    if (GGKDebugCamera) {
        if (self.captureManager.device != nil) {
            [self removeObserver:self forKeyPath:@"captureManager.device.focusMode"];
            [self removeObserver:self forKeyPath:@"captureManager.device.exposureMode"];
            [self removeObserver:self forKeyPath:@"captureManager.device.whiteBalanceMode"];
            [self removeObserver:self forKeyPath:@"captureManager.device.focusPointOfInterest"];
            [self removeObserver:self forKeyPath:@"captureManager.device.exposurePointOfInterest"];
            [self removeObserver:self forKeyPath:@"captureManager.device.adjustingFocus"];
            [self removeObserver:self forKeyPath:@"captureManager.device.adjustingExposure"];
            [self removeObserver:self forKeyPath:@"captureManager.device.adjustingWhiteBalance"];
        }
    }
}
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL wasHandledSeparately = NO;
    if (GGKDebugCamera) {
        
        // To keep this simple, if any of our properties change, then report all of them.
        if ([theKeyPath isEqualToString:@"captureManager.device.focusMode"] ||
            [theKeyPath isEqualToString:@"captureManager.device.exposureMode"] ||
            [theKeyPath isEqualToString:@"captureManager.device.whiteBalanceMode"] ||
            [theKeyPath isEqualToString:@"captureManager.device.focusPointOfInterest"] ||
            [theKeyPath isEqualToString:@"captureManager.device.exposurePointOfInterest"] ||
            [theKeyPath isEqualToString:@"captureManager.device.adjustingFocus"] ||
            [theKeyPath isEqualToString:@"captureManager.device.adjustingExposure"] ||
            [theKeyPath isEqualToString:@"captureManager.device.adjustingWhiteBalance"]) {
            
            [self updateCameraDebugLabels];
            wasHandledSeparately = YES;
        }
    }
    
    if ([theKeyPath isEqualToString:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString]) {
        
        NSString *aString = @"";
        switch (self.captureManager.focusAndExposureStatus) {
                
            case GGKCaptureManagerFocusAndExposureStatusContinuous:
                aString = ToFocusTipString;
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocking:
                aString = @"Focusing…";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocked:
                aString = ToUnlockFocusTipString;
                break;
                
            default:
                break;
        }
        self.tipLabel.text = aString;
    } else if (!wasHandledSeparately) {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)updateCameraDebugLabels
{
    AVCaptureDevice *aCaptureDevice = self.captureManager.device;
    NSString *aString = @"";
    switch (aCaptureDevice.focusMode) {
            
        case AVCaptureFocusModeAutoFocus:
            aString = @"auto.";
            break;
            
        case AVCaptureFocusModeContinuousAutoFocus:
            aString = @"cont.";
            break;
            
        case AVCaptureFocusModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.focusModeLabel.text = [NSString stringWithFormat:@"Foc. mode: %@", aString];
    
    switch (aCaptureDevice.exposureMode) {
            
        case AVCaptureExposureModeAutoExpose:
            aString = @"auto.";
            break;
            
        case AVCaptureExposureModeContinuousAutoExposure:
            aString = @"cont.";
            break;
            
        case AVCaptureExposureModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.exposureModeLabel.text = [NSString stringWithFormat:@"Exp. mode: %@", aString];
    
    switch (aCaptureDevice.whiteBalanceMode) {
            
        case AVCaptureWhiteBalanceModeAutoWhiteBalance:
            aString = @"auto.";
            break;
            
        case AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance:
            aString = @"cont.";
            break;
            
        case AVCaptureWhiteBalanceModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.whiteBalanceModeLabel.text = [NSString stringWithFormat:@"WB mode: %@", aString];
    
    aString = (aCaptureDevice.adjustingFocus) ? @"Yes" : @"No";
    self.focusingLabel.text = [NSString stringWithFormat:@"Focusing: %@", aString];
    
    aString = (aCaptureDevice.adjustingExposure) ? @"Yes" : @"No";
    self.exposingLabel.text = [NSString stringWithFormat:@"Exposing: %@", aString];
    
    aString = (aCaptureDevice.adjustingWhiteBalance) ? @"Yes" : @"No";
    self.whiteBalancingLabel.text = [NSString stringWithFormat:@"Wh. balancing: %@", aString];
    
    // Show points of interest, rounded to decimal (0.1).
    // Depending on the interface orientation, the coordinates may be reversed, mirrored, etc. However, tap-to-focus seems to be working, so I haven't worried about reporting the coordinates correctly.
    CGPoint aPoint = aCaptureDevice.focusPointOfInterest;
    self.focusPointOfInterestLabel.text = [NSString stringWithFormat:@"Foc. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
    aPoint = aCaptureDevice.exposurePointOfInterest;
    self.exposurePointOfInterestLabel.text = [NSString stringWithFormat:@"Exp. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
}

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    // An anchor.
    [self.cameraPreviewView ggk_makeSize:CGSizeMake(889, 667)];
    [self.cameraPreviewView ggk_makeBottomGap:0];
    [self.cameraPreviewView ggk_makeLeftGap:0];
    [self.captureManager correctThePreviewOrientation:self.cameraPreviewView];
    
    CGFloat aGap1 = 8;
    
    CGFloat aWidth = self.cameraRollButton.superview.frame.size.width - self.cameraPreviewView.frame.size.width - (2 * aGap1);
    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
    [self.cameraRollButton ggk_makeBottomGap:aGap1];
    [self.cameraRollButton ggk_makeRightGap:aGap1];
    
    CGFloat aGap2 = 50;
    
    [self.takePhotoButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
    CGFloat aHeight = self.takePhotoButton.superview.frame.size.height - self.cameraRollButton.frame.size.height - aGap2 - (2 * aGap1);
    [self.takePhotoButton ggk_makeHeight:aHeight];
    [self.takePhotoButton ggk_makeTopGap:aGap1];
    [self.takePhotoButton ggk_alignRightEdgeWithView:self.cameraRollButton];
        
    // An anchor.
    [self.tipLabel ggk_makeTopGap:8];
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    // An anchor.
    [self.cameraPreviewView ggk_makeSize:CGSizeMake(675, 900)];
    [self.cameraPreviewView ggk_makeBottomGap:0];
    [self.cameraPreviewView ggk_makeLeftGap:0];
    [self.captureManager correctThePreviewOrientation:self.cameraPreviewView];
    
    CGFloat aGap1 = 8;
    
    CGFloat aWidth = self.cameraRollButton.superview.frame.size.width - self.cameraPreviewView.frame.size.width - (2 * aGap1);
    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
    [self.cameraRollButton ggk_makeBottomGap:aGap1];
    [self.cameraRollButton ggk_makeRightGap:aGap1];
    
    CGFloat aGap2 = 50;
    
    [self.takePhotoButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
    CGFloat aHeight = self.takePhotoButton.superview.frame.size.height - self.cameraRollButton.frame.size.height - aGap2 - (2 * aGap1);
    [self.takePhotoButton ggk_makeHeight:aHeight];
    [self.takePhotoButton ggk_makeTopGap:aGap1];
    [self.takePhotoButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    
    // An anchor.
    [self.tipLabel ggk_makeTopGap:20];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    // If not debugging, hide those labels. (They're shown by default so we can see them in the storyboard.) If debugging, set up KVO.
    if (!GGKDebugCamera) {
        
        self.focusModeLabel.hidden = YES;
        self.exposureModeLabel.hidden = YES;
        self.whiteBalanceModeLabel.hidden = YES;
        self.focusingLabel.hidden = YES;
        self.exposingLabel.hidden = YES;
        self.whiteBalancingLabel.hidden = YES;
        self.focusPointOfInterestLabel.hidden = YES;
        self.exposurePointOfInterestLabel.hidden = YES;
    } else {
        
        if (self.captureManager.device != nil) {
            
            [self updateCameraDebugLabels];
            
            // Tried adding observer to self.captureManager.device, but it didn't work.
            [self addObserver:self forKeyPath:@"captureManager.device.focusMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.exposureMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.whiteBalanceMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.focusPointOfInterest" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.exposurePointOfInterest" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

@end
