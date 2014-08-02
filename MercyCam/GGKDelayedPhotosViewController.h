//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKAbstractPhotoViewController.h"

@class GGKDelayedPhotosModel;

@interface GGKDelayedPhotosViewController : GGKAbstractPhotoViewController <UITextFieldDelegate>

@property (strong, nonatomic) GGKDelayedPhotosModel *delayedPhotosModel;

// User taps trigger button. User sees label appear and increment with each photo taken. User implicitly understands when photos are taken, how many photos remain and how long it will take.
@property (nonatomic, weak) IBOutlet UILabel *numberOfPhotosTakenLabel;
// User taps trigger button. The number of photos showing in the text field are taken.
@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;
// User taps trigger button. Before first photo is taken, we wait for the number of seconds shown in the text field.
@property (weak, nonatomic) IBOutlet UITextField *numberOfSecondsToWaitTextField;
// User taps trigger button. User sees label appear and increment each second. User implicitly understands that the timer has started and can estimate when the first photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *numberOfSecondsWaitedLabel;
// In "Wait X second(s), then take Y photo(s)," it's "photo(s)."
// Story: User sets number of photos. User may see "photo" or "photos."
@property (weak, nonatomic) IBOutlet UILabel *photosLabel;
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyRightTriggerButtonTopGapPortraitLayoutConstraint;
// Width depends on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyRightTriggerButtonWidthLayoutConstraint;
// In "Wait X seconds, then take Y photos," it's "seconds, then take." But may be singular or plural.
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelRightGapPortraitLayoutConstraint;

// Called after user taps cancel-timer button.
// What: Stop repeating timer. Stop taking photos. Change to planning mode.
//- (IBAction)handleCancelTimerTapped;


// Override.
// Now that we can: Update timer labels. If enough time has passed, take a photo.

// Now that we can: Show how many seconds have passed. If enough seconds, take the first photo.
- (void)handleOneSecondTimerFired;

// Called after user taps a start-timer button.
// What: Change to shooting mode. Either start taking photos or start timer to wait.
//- (IBAction)handleTriggerButtonTapped:(id)sender;

// Override.
// What: Stop repeating timer. Stop taking photos.
- (void)handleViewDidDisappearFromUser;

// Override.
// Make a delayed-photos model.
- (GGKTakePhotoModel *)makeTakePhotoModel;

// Starts timer to take first photo.
//- (void)startTimer;
// Stops repeating timer.
//- (void)stopOneSecondRepeatingTimer;

// Override.
// What: Show how many photos taken, including this one. Done here instead of captureManagerDidTakePhoto:, because latter didn't update screen in time.
- (void)takePhoto;
// Override.
// Now that we can: If all photos taken, stop. Else, take another photo.
- (void)takePhotoModelDidTakePhoto:(id)sender;
// Now that we can: Ensure we have a valid value.
- (void)textFieldDidEndEditing:(UITextField *)textField;
// Now that we can: Dismiss the keyboard.
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// Override.
- (void)updateLayoutForLandscape;
// Override.
- (void)updateLayoutForPortrait;
// Override.
- (void)updateUI;
// Override.
- (void)viewDidLoad;
@end
