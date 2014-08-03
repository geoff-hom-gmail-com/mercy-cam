//
//  GGKTakeDelayedPhotosAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKAbstractDelayedPhotosViewController.h"

#import "GGKLongTermViewController.h"
#import "NSDate+GGKAdditions.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"
#import "GGKUtilities.h"

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger = 1;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger = 0;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger = 0;

NSString *GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString = @"numberOfPhotosToTakeInteger";

NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString = @"numberOfTimeUnitsBetweenPhotosInteger";

NSString *GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString = @"numberOfTimeUnitsToInitiallyWaitInteger";

NSString *GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString = @"timeUnitBetweenPhotosTimeUnit";

NSString *GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString = @"timeUnitForTheInitialWaitTimeUnit";

@interface GGKAbstractDelayedPhotosViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// The gesture recognizer for detecting "when the user taps the screen" while allowing those taps through (e.g., on a button). (May not detect taps on the navigation bar or above.)
// Need for enabling/disabling.
@property (nonatomic, strong) UITapGestureRecognizer *anyTapOnScreenGestureRecognizer;

// Story: User taps button. Popover appears. User makes selection in popover. User sees updated button.
// The button the user tapped to display the popover.
@property (nonatomic, strong) UIButton *currentPopoverButton;

// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;

// Story: User taps "Start timer" to take photos. The long-term timer also starts. When it fires, the screen dims to save power. The timer resets whenever the user taps the screen.
// Need for invalidating.
@property (nonatomic, strong) NSTimer *longTermTimer;

// The number of photos that have been taken since the user tapped "Start timer."
@property (nonatomic, assign) NSInteger numberOfPhotosTakenInteger;

// The number of seconds that have passed while waiting to take a photo. (Either an initial wait or between photos.)
@property (nonatomic, assign) NSInteger numberOfSecondsPassedInteger;

// The number of seconds to wait before dimming the screen and hiding the camera preview.
@property (nonatomic, assign) NSInteger numberOfSecondsToWaitBeforeDimmingTheScreenInteger;

// The total number of seconds to wait before taking a photo. (Either an initial wait or between photos.)
@property (nonatomic, assign) NSInteger numberOfTotalSecondsToWaitInteger;

// This timer goes off each second, which conveniently serves two purposes. 1) The UI can be updated every second, so the user can get visual feedback. 2) We can track how many seconds have passed, to know when to take a photo.
// Need this property to invalidate the timer later.
@property (nonatomic, strong) NSTimer *oneSecondRepeatingTimer;

// A transparent view for detecting "when the user taps the screen" but not letting those taps through.
// Needed for hiding/showing (i.e., not-detecting vs. detecting).
@property (nonatomic, strong) UIView *overlayView;

// The screen brightness before dimming. Need for restoring.
@property (nonatomic, assign) CGFloat previousBrightnessFloat;

- (void)handleATapOnScreen:(UIGestureRecognizer *)theGestureRecognizer;
// So, if the screen was dimmed (and the camera preview hidden), restore brightness and the preview. Also allow taps through again. Regardless, restart the long-term timer.

- (void)handleLongTermTimerFired;
// So, dim the screen and hide the camera preview. Also, block taps from going through (in case the user accidentally taps Cancel, for example).

// Start a timer for dimming the screen (and hiding the camera preview) after awhile.
- (void)startLongTermTimer;

@end

@implementation GGKAbstractDelayedPhotosViewController


//- (void)captureManagerDidTakePhoto:(id)sender {
//    } else if (self.numberOfTotalSecondsToWaitInteger == 0 && [self.oneSecondRepeatingTimer isValid]) {
//        [self takePhoto];
//    }
//}
- (void)dealloc {
//    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString];
//    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString];
//    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString];
//    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString];
//    [self removeObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)getSavedTimerSettings
{
    // The order of retrieval is important, as the assigned properties may be under KVO and refer to one another. In particular, updating a time unit may update it's corresponding string. That string also depends on the number of time units.
    
    NSInteger theNumberOfTimeUnitsToWaitBeforeDimmingTheScreenInteger = [[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermNumberOfTimeUnitsKeyString];
    GGKTimeUnit aTimeUnit = (GGKTimeUnit)[[NSUserDefaults standardUserDefaults] integerForKey:GGKLongTermTimeUnitKeyString];
    self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger = theNumberOfTimeUnitsToWaitBeforeDimmingTheScreenInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:aTimeUnit];
    NSLog(@"TDPAVC secToWaitBeforeDimScreen:%ld", (long)self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger);

    // Template for subclasses.
    
    //    self.numberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:AKey];
    //    self.timeUnitForTheInitialWaitTimeUnit
    //    self.numberOfPhotosToTakeInteger
    //    self.numberOfTimeUnitsBetweenPhotosInteger
    //    self.timeUnitBetweenPhotosTimeUnit
}

- (void)handleATapOnScreen:(UIGestureRecognizer *)theGestureRecognizer {
    if (self.cameraPreviewView.hidden) {
        self.cameraPreviewView.hidden = NO;
        [UIScreen mainScreen].brightness = self.previousBrightnessFloat;
        self.overlayView.hidden = YES;
    }
    [self startLongTermTimer];
}
- (void)handleLongTermTimerFired {
    UIScreen *aScreen = [UIScreen mainScreen];
    self.previousBrightnessFloat = aScreen.brightness;
    aScreen.brightness = 0.0;
    self.cameraPreviewView.hidden = YES;
    
    self.overlayView.hidden = NO;
}

//- (void)handleOneSecondTimerFired {
//    self.numberOfSecondsPassedInteger += 1;
//    [self updateTimerLabels];
//    // If enough time has passed, take a photo. Then set the counters for waiting between photos.
//    // Note that using == instead of >= works properly if seconds-to-wait is 0, as it skips taking a photo here (and takes it instead after the capture manager returns).
//    if (self.numberOfSecondsPassedInteger == self.numberOfTotalSecondsToWaitInteger) {
//        
//        // If the first photo, then show the photos label and the between-photos label.
//        if (self.numberOfPhotosTakenInteger == 0) {
//            
//            self.numberOfPhotosTakenLabel.hidden = NO;
//            self.numberOfTimeUnitsWaitedBetweenPhotosLabel.hidden = NO;
//            
//            // The first time the between-photos label is shown, it should show 0. Subsequently, 0 will also be when the between-photos time for the previous photo has passed, and we want to show that value instead. So we'll initialize at 0 here, only.
//            // If time is in seconds, then we don't need/want decimal precision.
//            NSString *aString = (self.timeUnitBetweenPhotosTimeUnit == GGKTimeUnitSeconds) ? @"0" : @"0.0";
//            self.numberOfTimeUnitsWaitedBetweenPhotosLabel.text = aString;
//        }
//        
//        self.numberOfSecondsPassedInteger = 0;
//        self.numberOfTotalSecondsToWaitInteger = self.numberOfTimeUnitsBetweenPhotosInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:self.timeUnitBetweenPhotosTimeUnit];
//        
//        // We'll take the photo last, in case there's something there that causes significant delay.
//        [self takePhoto];
//    }
//}
- (void)handleViewWillAppearToUser {
    [super handleViewWillAppearToUser];
//    [self getSavedTimerSettings];
}


- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender {
    
    if ([theSegue.identifier hasPrefix:@"ShowTimeUnitsSelector"]) {
        
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        
        GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)self.currentPopoverController.contentViewController;
        aTimeUnitsTableViewController.delegate = self;
        
        // Set the current time unit.
        GGKTimeUnit theCurrentTimeUnit = (theSender == self.timeUnitsToInitiallyWaitButton) ? self.timeUnitForTheInitialWaitTimeUnit : self.timeUnitBetweenPhotosTimeUnit;
        aTimeUnitsTableViewController.currentTimeUnit = theCurrentTimeUnit;
        
        // Note which button was tapped, to update later.
        self.currentPopoverButton = theSender;
    } else {
        
        [super prepareForSegue:theSegue sender:theSender];
    }
}

- (void)startLongTermTimer
{
//    NSLog(@"TADPVC: startLongTermTimer");
    
    [self.longTermTimer invalidate];
    self.longTermTimer = nil;
    
    // For testing.
//    self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger = 5;
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:self.numberOfSecondsToWaitBeforeDimmingTheScreenInteger target:self selector:@selector(handleLongTermTimerFired) userInfo:nil repeats:NO];
    self.longTermTimer = aTimer;
}

//- (IBAction)startTimer {
//
//    
//    // Show initial-wait label. If time is in seconds, then we don't need/want decimal precision.
//    NSString *aString = (self.timeUnitForTheInitialWaitTimeUnit == GGKTimeUnitSeconds) ? @"0" : @"0.0";
//    self.numberOfTimeUnitsInitiallyWaitedLabel.text = aString;
//    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = NO;
//    
//    // Show countdown label.
//    NSInteger theNumberOfSecondsToInitiallyWait = self.numberOfTimeUnitsToInitiallyWaitInteger * [GGKTimeUnits numberOfSecondsInTimeUnit:self.timeUnitForTheInitialWaitTimeUnit];
//    aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsToInitiallyWait];
//    self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
//    self.timeRemainingUntilNextPhotoLabel.hidden = NO;
//
//    self.numberOfPhotosTakenInteger = 0;
//    self.numberOfTotalSecondsToWaitInteger = theNumberOfSecondsToInitiallyWait;
//    self.numberOfSecondsPassedInteger = 0;
//    
//    // Allow for long-term dimming.
//    // Detect taps to reset long-term timer but also allow those taps through.
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
//    self.anyTapOnScreenGestureRecognizer.enabled = YES;
//    [self startLongTermTimer];
//
//}
//

- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender
{
    // Store the time unit for the proper setting.
    
    GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)sender;
    GGKTimeUnit theCurrentTimeUnit = aTimeUnitsTableViewController.currentTimeUnit;
    NSInteger anOkayInteger = theCurrentTimeUnit;
    
    NSString *theKey = (self.currentPopoverButton == self.timeUnitsToInitiallyWaitButton) ? self.timeUnitForInitialWaitKeyString : self.timeUnitBetweenPhotosKeyString;
    
    // Set the new value, then update the entire UI.
    [[NSUserDefaults standardUserDefaults] setInteger:anOkayInteger forKey:theKey];
    [self getSavedTimerSettings];
    
    [self.currentPopoverController dismissPopoverAnimated:YES];
}

- (void)updateTimerLabels {
    // Countdown label.
    // Time-to-wait may be 0, in which time passed will be greater.
    NSInteger theNumberOfSecondsUntilNextPhotoInteger = MAX(self.numberOfTotalSecondsToWaitInteger, self.numberOfSecondsPassedInteger) - self.numberOfSecondsPassedInteger;
    NSString *aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsUntilNextPhotoInteger];
    self.timeRemainingUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
    
    // Either initial-wait counter or between-photos counter.
    if (self.numberOfPhotosTakenInteger == 0) {
        
        NSString *aString;
        if (self.timeUnitForTheInitialWaitTimeUnit == GGKTimeUnitSeconds) {
            
            aString = [NSString stringWithFormat:@"%ld", (long)self.numberOfSecondsPassedInteger];
        } else {
            
            CGFloat theNumberOfTimeUnitsPassedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.numberOfSecondsPassedInteger timeUnit:self.timeUnitForTheInitialWaitTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsPassedFloat];
        }
        self.numberOfTimeUnitsInitiallyWaitedLabel.text = aString;
    } else {
        
        NSString *aString;
        if (self.timeUnitBetweenPhotosTimeUnit == GGKTimeUnitSeconds) {
            
            aString = [NSString stringWithFormat:@"%ld", (long)self.numberOfSecondsPassedInteger];
        } else {
            
            CGFloat theNumberOfTimeUnitsPassedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.numberOfSecondsPassedInteger timeUnit:self.timeUnitBetweenPhotosTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsPassedFloat];
        }
        self.numberOfTimeUnitsWaitedBetweenPhotosLabel.text = aString;
    }
}

//- (void)updateToAllowStartTimer {
//    // Undo stuff that allowed long-term dimming.
//    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [self.longTermTimer invalidate];
//    self.longTermTimer = nil;
//    self.anyTapOnScreenGestureRecognizer.enabled = NO;
//    self.overlayView.hidden = YES;
//    if (self.cameraPreviewView.hidden) {
//        
//        self.cameraPreviewView.hidden = NO;
//        [UIScreen mainScreen].brightness = self.previousBrightnessFloat;
//    }
//    
//    [self.oneSecondRepeatingTimer invalidate];
//    self.oneSecondRepeatingTimer = nil;
//}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [GGKUtilities matchFrameOfRotated90View:self.startTimerLeftButton withView:self.startTimerLeftProxyButton];
    [GGKUtilities matchFrameOfRotated90View:self.startTimerRightButton withView:self.startTimerRightProxyButton];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.maximumNumberOfTimeUnitsToInitiallyWaitInteger = 999;
//    self.maximumNumberOfPhotosInteger = 999;
//    self.maximumNumberOfTimeUnitsBetweenPhotosInteger = 999;

//    [self updateToAllowStartTimer];
    
    // Observe changes to the timer settings.
//    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitForTheInitialWaitKeyPathString options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosNumberOfTimeUnitsBetweenPhotosKeyPathString options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:GGKTakeDelayedPhotosTimeUnitBetweenPhotosKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    
    // Add a (disabled) gesture recognizer to detect taps while letting them through.
    UITapGestureRecognizer *aTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleATapOnScreen:)];
    aTapGestureRecognizer.cancelsTouchesInView = NO;
    aTapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:aTapGestureRecognizer];
    aTapGestureRecognizer.delegate = self;
    self.anyTapOnScreenGestureRecognizer = aTapGestureRecognizer;
    
    // Add an (inactive) overlay view with another gesture recognizer to detect taps but not let them through.
    UIView *anOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
    aTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleATapOnScreen:)];
    [anOverlayView addGestureRecognizer:aTapGestureRecognizer];
    anOverlayView.hidden = YES;
    [self.view addSubview:anOverlayView];
    self.overlayView = anOverlayView;

    // Side buttons.
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    aButton.titleLabel.font = self.startTimerLeftProxyButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.startTimerLeftProxyButton];
    self.startTimerLeftButton = aButton;
    aButton = [UIButton buttonWithType:UIButtonTypeSystem];
    aButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    aButton.titleLabel.font = self.startTimerRightProxyButton.titleLabel.font;
    [GGKUtilities matchFrameOfRotated90View:aButton withView:self.startTimerRightProxyButton];
    self.startTimerRightButton = aButton;
    NSString *aButtonTitleString = [self.startTimerBottomButton titleForState:UIControlStateNormal];
    for (UIButton *aButton in @[self.startTimerLeftButton, self.startTimerRightButton]) {
        aButton.backgroundColor = [UIColor whiteColor];
        [aButton setTitle:aButtonTitleString forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(playButtonSound) forControlEvents:UIControlEventTouchDown];
//        [aButton addTarget:self action:@selector(startTimer) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:aButton];
    }
    self.startTimerLeftProxyButton.hidden = YES;
    self.startTimerRightProxyButton.hidden = YES;
    // Corner radii.
    NSArray *aButtonArray = @[self.startTimerLeftButton, self.startTimerRightButton, self.startTimerBottomButton];
    for (UIButton *aButton in aButtonArray) {
        [GGKUtilities addBorderOfColor:[UIColor clearColor] toView:aButton];
    }
    self.tipLabel.layer.cornerRadius = 3.0f;
    self.timerSettingsView.layer.cornerRadius = 3.0f;
    self.cancelTimerButton.layer.cornerRadius = 5.0f;
    
    // Template for subclasses.
    
    // Set keys.
}
@end
