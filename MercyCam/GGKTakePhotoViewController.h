//
//  GGKTakePhotoViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoAbstractViewController.h"

@interface GGKTakePhotoViewController : GGKTakePhotoAbstractViewController
// Width changes depending on device rotation.
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraRollButtonWidthLayoutConstraint;
// (For testing.) Report whether currently exposing.
@property (strong, nonatomic) IBOutlet UILabel *exposingLabel;
// (For testing.) Report the current exposure mode.
@property (strong, nonatomic) IBOutlet UILabel *exposureModeLabel;
// (For testing.) Report the current exposure point-of-interest.
@property (strong, nonatomic) IBOutlet UILabel *exposurePointOfInterestLabel;
// (For testing.) Report the current focus mode.
@property (strong, nonatomic) IBOutlet UILabel *focusModeLabel;
// (For testing.) Report the current focus point-of-interest.
@property (strong, nonatomic) IBOutlet UILabel *focusPointOfInterestLabel;
// (For testing.) Report whether currently focusing.
@property (strong, nonatomic) IBOutlet UILabel *focusingLabel;
// Tap to take a photo.
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBottomButton;
@property (weak, nonatomic) UIButton *takePhotoLeftButton;
// Proxy button gives frame (via constraints) for rotated button.
@property (weak, nonatomic) IBOutlet UIButton *takePhotoLeftProxyButton;
@property (weak, nonatomic) UIButton *takePhotoRightButton;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoRightProxyButton;
// Width changes depending on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoRightProxyButtonWidthLayoutConstraint;
// For displaying a context-sensitive tip.
@property (nonatomic, strong) IBOutlet UILabel *tipLabel;
// In portrait, tip label and camera-roll button are center-Y aligned.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelAlignCenterYLayoutConstraint;
// Height changes depending on device rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelHeightLayoutConstraint;
// (For testing.) Report the current white-balance mode.
@property (strong, nonatomic) IBOutlet UILabel *whiteBalanceModeLabel;
// (For testing.) Report whether currently white balancing.
@property (strong, nonatomic) IBOutlet UILabel *whiteBalancingLabel;
// Override.
- (void)dealloc;
// KVO. Story: user (and tester) can see the camera's status in real-time.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
// Override.
- (void)updateLayoutForLandscape;
// Override.
- (void)updateLayoutForPortrait;
// Override.
// Update things after constraints have been applied.
- (void)viewDidLayoutSubviews;
// Override.
- (void)viewDidLoad;
@end
