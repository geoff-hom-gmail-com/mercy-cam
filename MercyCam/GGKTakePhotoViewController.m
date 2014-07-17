//
//  GGKTakePhotoViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoViewController.h"

#import "GGKSavedPhotosManager.h"
#import "GGKUtilities.h"
#import "UIView+GGKAdditions.h"

@interface GGKTakePhotoViewController ()
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
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
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
                aString = GGKToFocusTipString;
                break;
            case GGKCaptureManagerFocusAndExposureStatusLocking:
                aString = GGKFocusingTipString;
                break;
            case GGKCaptureManagerFocusAndExposureStatusLocked:
                aString = GGKToUnlockFocusTipString;
                break;
            default:
                break;
        }
        self.tipLabel.text = aString;
    } else if (!wasHandledSeparately) {
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}
- (void)updateCameraDebugLabels {
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
- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    self.takePhotoRightProxyButtonWidthLayoutConstraint.constant = 103;
    self.tipLabelHeightLayoutConstraint.constant = 21;
}
- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    self.takePhotoRightProxyButtonWidthLayoutConstraint.constant = 53;
    self.tipLabelHeightLayoutConstraint.constant = 58;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [GGKUtilities matchFrameOfRotated90View:self.takePhotoLeftButton withView:self.takePhotoLeftProxyButton];
    [GGKUtilities matchFrameOfRotated90View:self.takePhotoRightButton withView:self.takePhotoRightProxyButton];
}
- (void)viewDidLoad {
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
    self.tipLabel.layer.cornerRadius = 3.0f;
    // Make side buttons. We want vertical/rotated text, so the buttons are rotated. Rotation doesn't work with constraints; no constraints means we have to make the button in code. However, the storyboard has proxy buttons: proper frame (via constraints) but horizontal text.
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    aButton.titleLabel.font = self.takePhotoLeftProxyButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.takePhotoLeftProxyButton];
    self.takePhotoLeftButton = aButton;
    aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    aButton.titleLabel.font = self.takePhotoRightProxyButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.takePhotoRightProxyButton];
    self.takePhotoRightButton = aButton;
    NSString *aButtonTitleString = [self.takePhotoBottomButton titleForState:UIControlStateNormal];
    for (UIButton *aButton in @[self.takePhotoLeftButton, self.takePhotoRightButton]) {
        aButton.backgroundColor = [UIColor whiteColor];
        [aButton setTitle:aButtonTitleString forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(playButtonSound) forControlEvents:UIControlEventTouchDown];
        [aButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:aButton];
    }
    self.takePhotoLeftProxyButton.hidden = YES;
    self.takePhotoRightProxyButton.hidden = YES;
    // Add border to take-photo buttons.
    NSArray *aButtonArray = @[self.takePhotoLeftButton, self.takePhotoRightButton, self.takePhotoBottomButton];
    for (UIButton *aButton in aButtonArray) {
        [GGKUtilities addBorderOfColor:[UIColor clearColor] toView:aButton];
    }
    // Orientation-specific layout constraints.
    self.portraitOnlyLayoutConstraintArray = @[self.tipLabelAlignCenterYLayoutConstraint];
    NSDictionary *aDictionary = @{@"topGuide":self.topLayoutGuide, @"tipLabel":self.tipLabel, @"cameraPreviewView":self.cameraPreviewView};
    // Standard vertical gap between top layout guide, tip label and camera preview.
    NSArray *anArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[tipLabel]-[cameraPreviewView]" options:0 metrics:nil views:aDictionary];
    self.landscapeOnlyLayoutConstraintArray = anArray;
}
@end
