//
//  GGKSimpleDelayedPhotoViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosViewController.h"

#import "NSString+GGKAdditions.h"

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger = 3;

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger = 2;

NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString = @"Take delayed photos: number of photos";

NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString = @"Take delayed photos: number of seconds to initially wait";

@interface GGKTakeDelayedPhotosViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// Number of photos to take for a given push of the shutter.
@property (nonatomic, assign) NSInteger numberOfPhotosRemainingToTake;

// Number of seconds to wait before taking first photo.
@property (nonatomic, assign) CGFloat numberOfSecondsToInitiallyWait;


// So, show the user how many seconds have passed. If enough have passed, start taking photos.
- (void)handleOneSecondTimerFired;

- (void)keyboardWillHide:(NSNotification *)theNotification;
// So, shift the view back to normal.

- (void)keyboardWillShow:(NSNotification *)theNotification;
// So, shift the view up, if necessary.

// Start taking photos, immediately.
- (void)startTakingPhotos;

// Set parameters to most-recently used.
- (void)updateSettings;

@end

@implementation GGKTakeDelayedPhotosViewController

- (void)captureManagerDidTakePhoto:(id)sender
{
    [super captureManagerDidTakePhoto:sender];
    
    if (self.numberOfPhotosRemainingToTake > 0) {
        
        [self takePhoto];
    }
}

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleUpdateUITimerFired
{
    [super handleUpdateUITimerFired];
    
    // Calculate how many seconds have passed. 
    NSInteger theNumberOfSecondsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    NSInteger theNumberOfSecondsAlreadyWaitedInteger;
    if (self.initialWaitTimer == nil) {
        
        theNumberOfSecondsAlreadyWaitedInteger = theNumberOfSecondsToInitiallyWaitInteger;
    } else {
        
        CGFloat theNumberOfSecondsRemainingFloat = [self.initialWaitTimer.fireDate timeIntervalSinceNow];
        theNumberOfSecondsAlreadyWaitedInteger = theNumberOfSecondsToInitiallyWaitInteger - theNumberOfSecondsRemainingFloat;
    }
    self.numberOfTimeUnitsInitiallyWaitedLabel.text = [NSString stringWithFormat:@"%d", theNumberOfSecondsAlreadyWaitedInteger];
}


//- (void)handleOneSecondTimerFired
//{
//    NSNumber *theSecondsWaitedNumber = @([self.numberOfTimeUnitsInitiallyWaitedLabel.text integerValue] + 1);
//    self.numberOfTimeUnitsInitiallyWaitedLabel.text = [theSecondsWaitedNumber stringValue];
//    if ([theSecondsWaitedNumber floatValue] >= self.numberOfSecondsToInitiallyWait) {
//        
//        [self.oneSecondRepeatingTimer invalidate];
//        self.oneSecondRepeatingTimer = nil;
//        [self startTakingPhotos];
//    }
//}

- (void)keyboardWillHide:(NSNotification *)theNotification {
	
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = 0;
    
    NSDictionary* theUserInfo = [theNotification userInfo];
    NSTimeInterval keyboardAnimationDurationTimeInterval = [ theUserInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue ];
    [UIView animateWithDuration:keyboardAnimationDurationTimeInterval animations:^{
        
        self.view.frame = newFrame;
    }];
}

- (void)keyboardWillShow:(NSNotification *)theNotification {
    
    // Shift the view so that the active text field can be seen above the keyboard. We do this by comparing where the keyboard will end up vs. where the text field is. If a shift is needed, we shift the entire view up, synced with the keyboard shifting into place.
    
    NSDictionary *theUserInfo = [theNotification userInfo];
    CGRect keyboardFrameEndRect = [theUserInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	keyboardFrameEndRect = [self.view convertRect:keyboardFrameEndRect fromView:nil];
    CGFloat keyboardTop = keyboardFrameEndRect.origin.y;
    CGFloat activeTextFieldBottom = CGRectGetMaxY(self.activeTextField.frame);
    CGFloat overlap = activeTextFieldBottom - keyboardTop;
    CGFloat margin = 10;
    CGFloat amountToShift = overlap + margin;
    if (amountToShift > 0) {
        
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = newFrame.origin.y - amountToShift;
        NSTimeInterval keyboardAnimationDurationTimeInterval = [ theUserInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue ];
        [UIView animateWithDuration:keyboardAnimationDurationTimeInterval animations:^{
            
            self.view.frame = newFrame;
        }];
    } 
}



- (void)startTakingPhotos
{
    if (self.numberOfPhotosRemainingToTake > 0) {
        
        [self takePhoto];
    }
}

- (IBAction)startTimer
{
    [super startTimer];
    
    NSInteger theNumberOfSecondsToInitiallyWait = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:theNumberOfSecondsToInitiallyWait target:self selector:@selector(handleInitialWaitDone) userInfo:nil repeats:NO];
    self.initialWaitTimer = aTimer;
}

- (void)takePhoto
{
    [super takePhoto];
    
//    NSLog(@"TDPVC takePhoto called");
    self.numberOfPhotosRemainingToTake -= 1;
    
    // Show number of photos taken.
    if (self.numberOfPhotosTakenLabel.hidden) {
        
        self.numberOfPhotosTakenLabel.text = @"0";
        self.numberOfPhotosTakenLabel.hidden = NO;
    }
    NSNumber *theNumberOfPhotosTakenNumber = @([self.numberOfPhotosTakenLabel.text integerValue] + 1);
    self.numberOfPhotosTakenLabel.text = [theNumberOfPhotosTakenNumber stringValue];
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
    
    self.activeTextField = theTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    
    // Behavior depends on which text field was edited. Regardless, check the entered value. If not okay, set to an appropriate value. Store the value.
    
    NSString *theKey;
    id okayValue;
    
    if (theTextField == self.numberOfTimeUnitsToInitiallyWaitTextField) {
        
        theKey = GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;
        okayValue = @([theTextField.text integerValue]);
        
        // The number of seconds to initially wait should be an integer, 0 to 99. If not, fix.
        NSInteger okayValueInteger = [okayValue integerValue];
        if (okayValueInteger < 0) {
            
            okayValue = @0;
        } else if (okayValueInteger > 99) {
            
            okayValue = @99;
        }
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        
        theKey = GGKTakeDelayedPhotosNumberOfPhotosKeyString;
        okayValue = @([theTextField.text integerValue]);
        
        // The number of photos should be from 1 to 99. If not, fix.
        NSInteger okayValueInteger = [okayValue integerValue];
        if (okayValueInteger < 1) {
            
            okayValue = @1;
        } else if (okayValueInteger > 99) {
            
            okayValue = @99;
        }
    }
    
    // Set the new value, then update the entire UI.
    [[NSUserDefaults standardUserDefaults] setObject:okayValue forKey:theKey];
    [self updateSettings];
    
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 804, 603);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.focusLabel.frame = CGRectMake(765, 8, 113, 50);
    
    CGFloat anX1 = 886;
    CGFloat aWidth = 130;
    self.startTimerButton.frame = CGRectMake(anX1, 8, aWidth, 451);
    
    self.cancelTimerButton.frame = CGRectMake(916, 466, 100, 60);
    
    self.cameraRollButton.frame = CGRectMake(anX1, 566, aWidth, aWidth);
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 644, 859);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.focusLabel.frame = CGRectMake(659, 8, 94, 38);
    
    CGFloat anX1 = 652;
    CGFloat aWidth = 108;
    self.startTimerButton.frame = CGRectMake(anX1, 54, aWidth, 674);
    
    self.cancelTimerButton.frame = CGRectMake(672, 735, 88, 60);
    
    self.cameraRollButton.frame = CGRectMake(anX1, 844, aWidth, aWidth);
}

- (void)updateSettings
{
    NSInteger theNumberOfSecondsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    self.numberOfTimeUnitsToInitiallyWaitTextField.text = [NSString stringWithFormat:@"%d", theNumberOfSecondsToInitiallyWaitInteger];
    
    // "second(s), then take"
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theNumberOfSecondsToInitiallyWaitInteger];
    self.secondsLabel.text = [NSString stringWithFormat:@"%@, then take", aSecondsString];
    
    NSInteger theNumberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString];
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%d", theNumberOfPhotosToTakeInteger];
    
    // "photo(s)."
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theNumberOfPhotosToTakeInteger];
    self.afterNumberOfPhotosTextFieldLabel.text = [NSString stringWithFormat:@"%@.", aPhotosString];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    // Observe keyboard notifications to shift the screen up/down appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self updateSettings];
    
    [self updateToAllowStartTimer];
}

@end
