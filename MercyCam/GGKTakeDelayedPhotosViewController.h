//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

// A version of take-advanced-delayed-photos, with an initial wait in seconds and no between-photos wait. Also, a 2-digit limit (i.e., 99) for waiting and photos. 

#import "GGKTakeDelayedPhotosAbstractViewController.h"

// The default number of photos to take.
extern const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger;
// The default number of seconds to initially wait.
extern const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger;
// Key for storing the number of photos to take.
extern NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString;
// Key for storing the number of seconds to initially wait.
extern NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;

@interface GGKTakeDelayedPhotosViewController : GGKTakeDelayedPhotosAbstractViewController

// In "Wait X seconds, then take Y photos," it's "seconds, then take." But may be singular or plural.
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoRightProxyButtonTopGapPortraitLayoutConstraint;
// Width depends on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoRightProxyButtonWidthLayoutConstraint;
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelRightGapPortraitLayoutConstraint;
// View showing the timer settings.
@property (weak, nonatomic) IBOutlet UIView *timerSettingsView;
// Override.
- (void)getSavedTimerSettings;
// Override.
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
