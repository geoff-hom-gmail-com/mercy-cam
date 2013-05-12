//
//  GGKSimpleDelayedPhotoViewController.h
//  GGK Cam A
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

@interface GGKTakeDelayedPhotosViewController : GGKTakeDelayedPhotosAbstractViewController <UITextFieldDelegate>

// In "Wait X seconds, then take Y photos," it's "seconds, then take." But may be singular or plural.
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;

// Override.
- (void)captureManagerDidTakePhoto:(id)sender;
// So, if more photos to be taken, do that.

// Override.
- (void)handleUpdateUITimerFired;

// Override.
- (IBAction)startTimer;




// Override. But not an IBAction here.
// Also show number of photos taken.
- (void)takePhoto;

- (void)textFieldDidBeginEditing:(UITextField *)textField;
// So, note which text field is being edited. (To know whether to shift the screen up when the keyboard shows.)

- (void)textFieldDidEndEditing:(UITextField *)textField;
// So, if an invalid value was entered, then use the previous value. Also, note that no text field is being edited now.

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// So, dismiss the keyboard.




// Override.
- (void)updateLayoutForLandscape;

// Override.
- (void)updateLayoutForPortrait;

// Override.
- (void)viewDidLoad;

@end
