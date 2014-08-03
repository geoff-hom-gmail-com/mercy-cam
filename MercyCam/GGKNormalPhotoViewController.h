//
//  GGKTakePhotoViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKAbstractPhotoViewController.h"

@interface GGKNormalPhotoViewController : GGKAbstractPhotoViewController
// Width changes depending on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyRightTriggerButtonWidthLayoutConstraint;
// In portrait, tip label and camera-roll button are center-Y aligned.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelAlignCenterYLayoutConstraint;
// Height changes depending on device rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelHeightLayoutConstraint;
// Override.
- (void)updateLayoutForLandscape;
// Override.
- (void)updateLayoutForPortrait;
// Override.
- (void)viewDidLoad;
@end
