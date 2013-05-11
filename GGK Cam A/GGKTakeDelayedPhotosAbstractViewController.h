//
//  GGKTakeDelayedPhotosAbstractViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoAbstractViewController.h"

extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger;

extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger;

extern const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger;

@interface GGKTakeDelayedPhotosAbstractViewController : GGKTakePhotoAbstractViewController

// Story: User sets number of photos to 1. User sees "1 photo…" instead of "1 photos…."
// The label following the number-of-photos-to-take text field.
@property (weak, nonatomic) IBOutlet UILabel *afterNumberOfPhotosTextFieldLabel;

// Tap to cancel the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *cancelTimerButton;

// For displaying when the focus is continuous or locked. (Displays "locked" only when both focus and exposure are locked. Otherwise, displays "continuous" or "locking.")
@property (nonatomic, strong) IBOutlet UILabel *focusLabel;

// Timer to wait before the first photo is taken.
// Story: User taps cancel. No more photos taken.
@property (nonatomic, strong) NSTimer *initialWaitTimer;

// The number of photos remaining to take.
@property (nonatomic, assign) NSInteger numberOfPhotosRemainingToTake;

// Story: User taps "Start timer." User sees label below appear and increment with each photo taken. User implicitly understands when photos are taken, how many photos remain, and how long it will take.
@property (nonatomic, weak) IBOutlet UILabel *numberOfPhotosTakenLabel;

// Number of photos to take for a given tap of the shutter button.
@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;

// Story: User taps "Start timer." User sees label below; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that the timer has started and can estimate when the first photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsInitiallyWaitedLabel;

// Number of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToInitiallyWaitTextField;

// Tap to start the timer for taking photos.
@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;

// Override.
- (void)captureManagerDidTakePhoto:(id)sender;
// So, if no more photos to take, then reset the UI for starting the timer again.

// Override.
// KVO. Story: User can see when the focus/exposure is locked.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// Update UI to allow canceling. Start timer for updating UI.
// Partial stub: Subclasses should start timer for initial wait.
- (IBAction)startTimer;



// stub?
//?
- (void)handleInitialWaitDone;



// stub? or have it all here?
// Cancel timers and don't take any more photos.
- (IBAction)cancelTimer;

// Story: User sees UI and knows to wait for photos to be taken, or to tap "Cancel."
- (void)updateToAllowCancelTimer;

// Stub? partial?
// Story: User sees UI and knows she can tap "Start timer."
- (void)updateToAllowStartTimer;


@end
