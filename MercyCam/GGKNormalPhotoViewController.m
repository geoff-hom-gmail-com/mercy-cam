//
//  GGKTakePhotoViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKNormalPhotoViewController.h"

@implementation GGKNormalPhotoViewController
- (IBAction)handleTriggerButtonTapped:(id)theSender {
    [super handleTriggerButtonTapped:theSender];
    [self takePhoto];
}
- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 103;
    self.tipLabelHeightLayoutConstraint.constant = 21;
}
- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 53;
    self.tipLabelHeightLayoutConstraint.constant = 58;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipLabel.layer.cornerRadius = 3.0f;
    // Orientation-specific layout constraints.
    self.portraitOnlyLayoutConstraintArray = @[self.tipLabelAlignCenterYLayoutConstraint];
    NSDictionary *aDictionary = @{@"topGuide":self.topLayoutGuide, @"tipLabel":self.tipLabel, @"cameraPreviewView":self.cameraPreviewView};
    // Standard vertical gap between top layout guide, tip label and camera preview.
    NSArray *anArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[tipLabel]-[cameraPreviewView]" options:0 metrics:nil views:aDictionary];
    self.landscapeOnlyLayoutConstraintArray = anArray;
}
@end
