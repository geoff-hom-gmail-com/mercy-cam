//
//  GGKSimpleDelayedPhotoViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKSimpleDelayedPhotoViewController : UIViewController <UITextFieldDelegate>

// Tap to see camera roll. This button shows the most-recent photo in the roll. 
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;

// Tap to cancel the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *cancelTimerButton;

// Number of photos to take for a given tap of the shutter button.
@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;

// Number of seconds to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfSecondsToInitiallyWaitTextField;

// Tap to start the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;

// To let user know, visually, that the timer started.
@property (weak, nonatomic) IBOutlet UILabel *timerStartedLabel;

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

// Cancel the timer and don't take any more photos.
- (IBAction)cancelTimer;

// Start the timer to take photos.
- (IBAction)startTimer;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
// So, note which text field is being edited. (To know whether to shift the screen up when the keyboard shows.)

- (void)textFieldDidEndEditing:(UITextField *)textField;
// So, note that no text field is being edited.

// View camera roll.
- (IBAction)viewPhotos;

@end
