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
//    [self.oneSecondRepeatingTimer invalidate];
//    self.oneSecondRepeatingTimer = nil;
//    self.numberOfPhotosToTake = 0;
//    [self updateForAllowingStartTimer];
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
    ;
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

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//}

@end
