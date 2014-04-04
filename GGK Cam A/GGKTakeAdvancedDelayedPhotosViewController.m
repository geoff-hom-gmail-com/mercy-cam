//
//  GGKTakeAdvancedDelayedPhotosViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeAdvancedDelayedPhotosViewController.h"

#import "UIView+GGKAdditions.h"

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfPhotosInteger = 5;

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsBetweenPhotosInteger = 7;

const NSInteger GGKTakeAdvancedDelayedPhotosDefaultNumberOfTimeUnitsToInitiallyWaitInteger = 10;

const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitBetweenPhotosTimeUnit = GGKTimeUnitSeconds;

const GGKTimeUnit GGKTakeAdvancedDelayedPhotosDefaultTimeUnitForInitialWaitTimeUnit = GGKTimeUnitSeconds;

NSString *GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString = @"Take advanced delayed photos: number of photos.";

NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString = @"Take advanced delayed photos: number of time units between photos.";

NSString *GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString = @"Take advanced delayed photos: number of time units to initially wait.";

NSString *GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString = @"Take advanced delayed photos: time unit to use between photos.";

NSString *GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString = @"Take advanced delayed photos: time unit to use to initially wait.";

@interface GGKTakeAdvancedDelayedPhotosViewController ()

@end

@implementation GGKTakeAdvancedDelayedPhotosViewController

- (void)getSavedTimerSettings
{
    [super getSavedTimerSettings];
    
    self.numberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
    self.timeUnitForTheInitialWaitTimeUnit = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString];
    self.numberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfPhotosToTakeKeyString];
    self.numberOfTimeUnitsBetweenPhotosInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsBetweenPhotosKeyString];
    self.timeUnitBetweenPhotosTimeUnit = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString];
}

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    // An anchor.
    [self.videoPreviewView ggk_makeSize:CGSizeMake(820, 615)];
    [self.videoPreviewView ggk_makeBottomGap:0];
    [self.videoPreviewView ggk_makeLeftGap:0];
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    CGFloat aGap1 = 8;
    
    // An anchor.
    CGFloat aWidth = 130;
    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
    [self.cameraRollButton ggk_makeBottomGap:aGap1];
    [self.cameraRollButton ggk_makeRightGap:aGap1];
    
    [self.focusLabel ggk_makeTopGap:aGap1];
    [self.focusLabel ggk_alignHorizontalCenterWithView:self.cameraRollButton];
    
    CGFloat aGap2 = 40;
    
    [self.startTimerButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
    CGFloat aHeight = self.startTimerButton.superview.frame.size.height - self.focusLabel.frame.size.height - self.cameraRollButton.frame.size.height - self.cancelTimerButton.frame.size.height - aGap2 - (4 * aGap1);
    [self.startTimerButton ggk_makeHeight:aHeight];
    [self.startTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.startTimerButton ggk_placeBelowView:self.focusLabel gap:aGap1];
    
    CGFloat aGap3 = 30;
    
    [self.cancelTimerButton ggk_makeWidth:(self.startTimerButton.frame.size.width - aGap3)];
    [self.cancelTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.cancelTimerButton ggk_placeBelowView:self.startTimerButton gap:aGap1];
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    // An anchor.
    [self.videoPreviewView ggk_makeSize:CGSizeMake(654, 872)];
    [self.videoPreviewView ggk_makeBottomGap:0];
    [self.videoPreviewView ggk_makeLeftGap:0];
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    CGFloat aGap1 = 8;
    
    CGFloat aWidth = self.cameraRollButton.superview.frame.size.width - self.videoPreviewView.frame.size.width - (2 * aGap1);
    [self.cameraRollButton ggk_makeSize:CGSizeMake(aWidth, aWidth)];
    [self.cameraRollButton ggk_makeBottomGap:aGap1];
    [self.cameraRollButton ggk_makeRightGap:aGap1];
    
    [self.focusLabel ggk_alignTopEdgeWithView:self.videoPreviewView];
    [self.focusLabel ggk_alignHorizontalCenterWithView:self.cameraRollButton];
    
    CGFloat aGap2 = 50;
    
    [self.startTimerButton ggk_makeWidth:self.cameraRollButton.frame.size.width];
    CGFloat aHeight = self.startTimerButton.superview.frame.size.height - self.focusLabel.frame.origin.y - self.focusLabel.frame.size.height - self.cameraRollButton.frame.size.height - self.cancelTimerButton.frame.size.height - aGap2 - (3 * aGap1);
    [self.startTimerButton ggk_makeHeight:aHeight];
    [self.startTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.startTimerButton ggk_placeBelowView:self.focusLabel gap:aGap1];
    
    CGFloat aGap3 = 20;
    
    [self.cancelTimerButton ggk_makeWidth:(self.startTimerButton.frame.size.width - aGap3)];
    [self.cancelTimerButton ggk_alignRightEdgeWithView:self.cameraRollButton];
    [self.cancelTimerButton ggk_placeBelowView:self.startTimerButton gap:aGap1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set keys.
    self.numberOfTimeUnitsToInitiallyWaitKeyString = GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyString;
    self.timeUnitForInitialWaitKeyString = GGKTakeAdvancedDelayedPhotosTimeUnitForInitialWaitKeyString;
    self.numberOfPhotosToTakeKeyString = GGKTakeAdvancedDelayedPhotosNumberOfPhotosKeyString;
    self.numberOfTimeUnitsBetweenPhotosKeyString = GGKTakeAdvancedDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyString;
    self.timeUnitBetweenPhotosKeyString = GGKTakeAdvancedDelayedPhotosTimeUnitBetweenPhotosKeyString;
    
    //testing; trying to get preview to appear here but not in vWA
//    [self.view addSubview:self.videoPreviewView];
//    [self.captureManager setUpSession];
//    [self.captureManager addPreviewLayerToView:self.videoPreviewView];
//    CALayer *aTestLayer = [CALayer layer];
//    if (aTestLayer == nil) {
//        NSLog(@" layer is nil");
//    } else {
//        NSLog(@" layer is ok");
//    }
//    aTestLayer.backgroundColor = [UIColor orangeColor].CGColor;
//    [self.videoPreviewView.layer addSublayer:aTestLayer];
//    [theViewLayer addSublayer:aTestLayer];

    NSArray *anArray = [self.captureManager.captureVideoPreviewLayer.sublayers copy];
    for (CALayer *aLayer in anArray) {
//        [aLayer removeFromSuperlayer];
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0);
    UIBezierPath *aBezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0, 50, 50)];
    [[UIColor purpleColor] setFill];
    [aBezierPath fill];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
// works; view has purple bg
    // self.view...
    self.videoPreviewView.layer.contents = (__bridge id)(anImage.CGImage);
    
//    self.captureManager.captureVideoPreviewLayer.contents = (__bridge id)(anImage.CGImage);
    
}
//testing
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"TADPVC vWA");
//    [self.videoPreviewView removeFromSuperview];
    
    // add preview layer if it's not already there
    CALayer *aLayer = self.videoPreviewView.layer.sublayers[0];
    if (aLayer) {
        NSLog(@"TADPVC vWA2 layer exists");
        self.captureManager.captureVideoPreviewLayer.contents = nil;
    } else {
        NSLog(@"TADPVC vWA2 layer nil");
//        self.captureManager.captureVideoPreviewLayer.contents = nil;
        self.captureManager.captureVideoPreviewLayer.session = nil;
//        self.captureManager.captureVideoPreviewLayer.contents = nil;
        // purple square contents
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0);
        UIBezierPath *aBezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0, 50, 50)];
        [[UIColor purpleColor] setFill];
        [aBezierPath fill];
        UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.captureManager.captureVideoPreviewLayer.contents = (__bridge id)(anImage.CGImage);
        
        [self.view setNeedsDisplay];
        [self.captureManager.captureVideoPreviewLayer setNeedsDisplay];
        [self.captureManager.captureVideoPreviewLayer displayIfNeeded];
        [self.captureManager.captureVideoPreviewLayer display];
        
        // main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view setNeedsDisplay];
            [self.captureManager.captureVideoPreviewLayer setNeedsDisplay];
            [self.captureManager.captureVideoPreviewLayer displayIfNeeded];
            [self.captureManager.captureVideoPreviewLayer display];
        });

//        [self.view displayLayer:self.captureManager.captureVideoPreviewLayer];
        [self.videoPreviewView.layer addSublayer:self.captureManager.captureVideoPreviewLayer];
        self.captureManager.captureVideoPreviewLayer.session = nil;
//        self.captureManager.captureVideoPreviewLayer.contents = nil;
        [self.view setNeedsDisplay];
        [self.captureManager.captureVideoPreviewLayer setNeedsDisplay];
        [self.captureManager.captureVideoPreviewLayer displayIfNeeded];
        [self.captureManager.captureVideoPreviewLayer display];
        
        // purple square contents
        self.captureManager.captureVideoPreviewLayer.contents = (__bridge id)(anImage.CGImage);
        
        
        // main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view setNeedsDisplay];
            [self.captureManager.captureVideoPreviewLayer setNeedsDisplay];
            [self.captureManager.captureVideoPreviewLayer displayIfNeeded];
            [self.captureManager.captureVideoPreviewLayer display];
        });
        
        // purple square contents
        self.captureManager.captureVideoPreviewLayer.contents = (__bridge id)(anImage.CGImage);
        

//        [self.view displayLayer:self.captureManager.captureVideoPreviewLayer];
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // add preview layer if it's not already there
//    CALayer *aLayer = self.videoPreviewView.layer.sublayers[0];
//    if (aLayer) {
//        NSLog(@"TADPVC vDA2 layer exists");
//    } else {
//        NSLog(@"TADPVC vDA2 layer nil");
//        [self.captureManager testAddPreviewLayerToLayer:self.videoPreviewView.layer];
//        //        [self.videoPreviewView.layer addSublayer:self.captureManager.captureVideoPreviewLayer];
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"TADPVC vDD");
    // this makes the layer not appear later (no snapshot)
//    [self.videoPreviewView removeFromSuperview];
    
    // this color-change works, if the preview layer isn't added
    self.videoPreviewView.layer.backgroundColor = [UIColor greenColor].CGColor;
    
    // try to change sub-layer color
    // works
//    CALayer *aLayer = self.videoPreviewView.layer.sublayers[0];
//    aLayer.backgroundColor = [UIColor yellowColor].CGColor;
    
    // try to remove sublayer
    // works
    CALayer *aLayer = self.videoPreviewView.layer.sublayers[0];
    aLayer.contents = nil;
    AVCaptureVideoPreviewLayer *aVideoLayer = (AVCaptureVideoPreviewLayer *)aLayer;
//    aVideoLayer.session = nil;
    aVideoLayer.contents = nil;
    [aLayer removeFromSuperlayer];
    aLayer.contents = nil;
    
    // testing removing inputs and outputs
    AVCaptureOutput *anOutput = self.captureManager.session.outputs[0];
    [self.captureManager.session removeOutput:anOutput];
    AVCaptureInput *anInput = self.captureManager.session.inputs[0];
    [self.captureManager.session removeInput:anInput];
    
    self.captureManager.captureVideoPreviewLayer.session = nil;
    self.captureManager.captureVideoPreviewLayer.contents = nil;
    
    // purple square contents
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0);
    UIBezierPath *aBezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0,0, 50, 50)];
    [[UIColor purpleColor] setFill];
    [aBezierPath fill];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.captureManager.captureVideoPreviewLayer.contents = (__bridge id)(anImage.CGImage);
    
    [self.view setNeedsDisplay];
    [self.captureManager.captureVideoPreviewLayer setNeedsDisplay];
    [self.captureManager.captureVideoPreviewLayer displayIfNeeded];
    [self.captureManager.captureVideoPreviewLayer display];
    
    // main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view setNeedsDisplay];
        [self.captureManager.captureVideoPreviewLayer setNeedsDisplay];
        [self.captureManager.captureVideoPreviewLayer displayIfNeeded];
        [self.captureManager.captureVideoPreviewLayer display];
    });
    
//    [self.view displayLayer:self.captureManager.captureVideoPreviewLayer];
//    [self.videoPreviewView.layer addSublayer:self.captureManager.captureVideoPreviewLayer];
//    self.captureManager.captureVideoPreviewLayer.session = self.captureManager.session;
    
    NSLog(@"TADPVC vDD1");
}
@end
