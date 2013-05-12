//
//  GGKTakeDelayedPhotosAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosAbstractViewController.h"

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfPhotosInteger = 1;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsBetweenPhotosInteger = 0;

const NSInteger GGKTakeDelayedPhotosMinimumNumberOfTimeUnitsToInitiallyWaitInteger = 0;

@interface GGKTakeDelayedPhotosAbstractViewController ()

// This timer goes off every second, so the user can get visual feedback. Need this property to invalidate later.
@property (nonatomic, strong) NSTimer *updateUITimer;

@end

@implementation GGKTakeDelayedPhotosAbstractViewController

- (IBAction)cancelTimer
{
    [self updateToAllowStartTimer];
}

- (void)captureManagerDidTakePhoto:(id)sender
{
    [super captureManagerDidTakePhoto:sender];
    
    if (self.numberOfPhotosRemainingToTake == 0) {
        
        [self updateToAllowStartTimer];
    }
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString]) {
        
        NSString *aString = @"";
        switch (self.captureManager.focusAndExposureStatus) {
                
            case GGKCaptureManagerFocusAndExposureStatusContinuous:
                aString = @"Continuous";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocking:
                aString = @"Locking…";
                break;
                
            case GGKCaptureManagerFocusAndExposureStatusLocked:
                aString = @"Locked";
                break;
                
            default:
                break;
        }
        self.focusLabel.text = [NSString stringWithFormat:@"Focus:\n  %@", aString];
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)handleInitialWaitDone
{
    NSLog(@"handleInitialWaitDone");
    [self.initialWaitTimer invalidate];
    self.initialWaitTimer = nil;
    
    // well, we want to stop the initial-wait timer.
    // and take a photo
    // if there's a between-photos timer, start that
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

- (void)handleUpdateUITimerFired
{
}

- (IBAction)startTimer
{
    [self updateToAllowCancelTimer];
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleUpdateUITimerFired) userInfo:nil repeats:YES];
    self.updateUITimer = aTimer;
    
    // Template for subclasses.
    
//    NSInteger theNumberOfSecondsToInitiallyWait = ??;
    
//    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:theNumberOfSecondsToInitiallyWait target:self selector:@selector(handleInitialWaitDone) userInfo:nil repeats:NO];
//    self.initialWaitTimer = aTimer;
}

- (void)updateToAllowCancelTimer
{
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = NO;
    self.numberOfPhotosToTakeTextField.enabled = NO;
    self.numberOfTimeUnitsInitiallyWaitedLabel.text = @"0";
    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = NO;
    self.startTimerButton.enabled = NO;
    self.cancelTimerButton.enabled = YES;
}

- (void)updateToAllowStartTimer
{
    [self.updateUITimer invalidate];
    self.updateUITimer = nil;
    [self.initialWaitTimer invalidate];
    self.initialWaitTimer = nil;
    self.numberOfPhotosRemainingToTake = 0;
    
    self.numberOfTimeUnitsToInitiallyWaitTextField.enabled = YES;
    self.numberOfPhotosToTakeTextField.enabled = YES;
    self.numberOfTimeUnitsInitiallyWaitedLabel.hidden = YES;
    self.numberOfPhotosTakenLabel.hidden = YES;
    self.startTimerButton.enabled = YES;
    self.cancelTimerButton.enabled = NO;
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//}

@end
