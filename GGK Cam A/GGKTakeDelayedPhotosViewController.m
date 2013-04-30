//
//  GGKSimpleDelayedPhotoViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
//#import <AVFoundation/AVFoundation.h>
#import "GGKCaptureManager.h"
#import "GGKSavedPhotosManager.h"
#import "GGKTakeDelayedPhotosViewController.h"

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger = 3;

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger = 2;

NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString = @"Take delayed photos: number of photos";

NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString = @"Take delayed photos: number of seconds to initially wait";

@interface GGKTakeDelayedPhotosViewController ()

// The text field currently being edited.
@property (nonatomic, strong) UITextField *activeTextField;

// For removing the observer later.
@property (nonatomic, strong) id appWillEnterForegroundObserver;

// For creating the session and managing the capture device.
@property (nonatomic, strong) GGKCaptureManager *captureManager;

// Number of photos to take for a given push of the shutter.
@property (nonatomic, assign) NSInteger numberOfPhotosToTake;

// Number of seconds to wait before taking first photo.
@property (nonatomic, assign) CGFloat numberOfSecondsToInitiallyWait;

// Story: User taps "Cancel." Timer is stopped.
@property (nonatomic, strong) NSTimer *numberOfSecondsToInitiallyWaitTimer;

// For working with photos in the camera roll.
@property (nonatomic, strong) GGKSavedPhotosManager *savedPhotosManager;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

// Adjust "Wait X seconds, then take Y photos," for whether the values are singular or plural.
- (void)adjustStringsForPlurals;

//-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// So, update the image in the button for showing the camera roll. If another photo is supposed to be taken, do it.

- (void)keyboardWillHide:(NSNotification *)theNotification;
// So, shift the view back to normal.

- (void)keyboardWillShow:(NSNotification *)theNotification;
// So, shift the view up, if necessary.

// KVO. Story: User can see when the focus/exposure is locked.
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

// Start taking photos, immediately.
- (void)startTakingPhotos;

// Story: User sees UI and knows to wait for photos to be taken, or to tap "Cancel."
- (void)updateForAllowingCancelTimer;

// Story: User sees UI and knows she can tap "Start timer."
- (void)updateForAllowingStartTimer;

// Story: When the user should see the UI in portrait, she does.
- (void)updateLayoutForPortrait;

// Story: View will appear to user. User sees updated view.
// UIViewController override. Listen for app coming from background/lock. Update view.
// Whether the view appears from another view in this app or from the app entering the foreground, the user should see an updated view. -viewWillAppear: is called for the former but not the latter. So, we listen for UIApplicationWillEnterForegroundNotification (and stop listening in -viewWillDisappear:).
- (void)viewWillAppear:(BOOL)animated;

// UIViewController override. Undo anything from -viewWillAppear:.
- (void)viewWillDisappear:(BOOL)animated;

@end

@implementation GGKTakeDelayedPhotosViewController

- (void)adjustStringsForPlurals {
    
    // "second(s), then take"
    NSString *aSecondsString = @"seconds";
    if ([self.numberOfSecondsToInitiallyWaitTextField.text intValue] == 1) {
        
        aSecondsString = @"second";
    }
    self.secondsLabel.text = [NSString stringWithFormat:@"%@, then take", aSecondsString];
    
    // "photo(s)."
    NSString *aPhotosString = @"photos";
    if ([self.numberOfPhotosToTakeTextField.text intValue] == 1) {
        
        aPhotosString = @"photo";
    }
    self.photosLabel.text = [NSString stringWithFormat:@"%@.", aPhotosString];
}

- (IBAction)cancelTimer {
    
    [self.numberOfSecondsToInitiallyWaitTimer invalidate];
    self.numberOfSecondsToInitiallyWaitTimer = nil;
    self.numberOfPhotosToTake = 0;
    [self updateForAllowingStartTimer];
}

- (void)captureManagerDidTakePhoto:(id)sender
{
    NSLog(@"captureManagerDidTakePhoto");
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
    if (self.numberOfPhotosToTake > 0) {
        
        [self takePhoto];
    } else {
        
        [self updateForAllowingStartTimer];
    }
}

- (void)dealloc {
    
    [self.captureManager.session stopRunning];
    [self removeObserver:self forKeyPath:@"captureManager.focusAndExposureStatus"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//
//    if (self.numberOfPhotosToTake > 0) {
//        
//        [self takePhoto];
//    } else {
//        
//        self.startTimerButton.enabled = YES;
//        self.timerStartedLabel.hidden = YES;
//        self.cancelTimerButton.enabled = NO;
//    }
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:@"captureManager.focusAndExposureStatus"]) {
        
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

- (IBAction)playButtonSound
{
    [self.soundModel playButtonTapSound];
}

- (void)startTakingPhotos {

//    NSLog(@"SDPVC startTakingPhotos called");
    if (self.numberOfPhotosToTake > 0) {
        
//        [self.captureManager takePhoto];
        [self takePhoto];
    }
}

- (IBAction)startTimer
{
//    NSLog(@"SDPVC startTimer called");
    [self updateForAllowingCancelTimer];
    
    self.numberOfSecondsToInitiallyWait = [self.numberOfSecondsToInitiallyWaitTextField.text floatValue];
    self.numberOfPhotosToTake = [self.numberOfPhotosToTakeTextField.text integerValue];
    
    NSTimeInterval initialWaitTimeInterval = self.numberOfSecondsToInitiallyWait;
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:initialWaitTimeInterval target:self selector:@selector(startTakingPhotos) userInfo:nil repeats:NO];
    self.numberOfSecondsToInitiallyWaitTimer = aTimer;
}

- (void)takePhoto {
    
    NSLog(@"TDPVC takePhoto called");
    self.numberOfPhotosToTake -= 1;
    
    [self.captureManager takePhoto];
    
    // Give visual feedback that photo was taken: Flash the screen.
    UIView *aFlashView = [[UIView alloc] initWithFrame:self.videoPreviewView.frame];
    aFlashView.backgroundColor = [UIColor whiteColor];
    aFlashView.alpha = 0.8f;
    [self.view addSubview:aFlashView];
    [UIView animateWithDuration:0.6f animations:^{
        
        aFlashView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        [aFlashView removeFromSuperview];
    }];
}

//- (void)takePhoto {
//    
//    NSLog(@"SDPVC takePhoto called");
//    self.numberOfPhotosToTake -= 1;
//    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureManager.session.outputs[0];
//    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//    
//    // Give visual feedback that photo was taken: Flash the screen.
//    UIView *aFlashView = [[UIView alloc] initWithFrame:self.videoPreviewView.frame];
//    aFlashView.backgroundColor = [UIColor whiteColor];
//    aFlashView.alpha = 0.8f;
//    [self.view addSubview:aFlashView];
//    [UIView animateWithDuration:0.6f animations:^{
//        
//        aFlashView.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        
//        [aFlashView removeFromSuperview];
//    }];
//    
//    if (aCaptureConnection != nil) {
//        
//        [aCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:aCaptureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//            
//            if (imageDataSampleBuffer != NULL) {
//                
//                NSData *theImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                UIImage *theImage = [[UIImage alloc] initWithData:theImageData];
//                UIImageWriteToSavedPhotosAlbum(theImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//            }
//        }];
//    } else {
//        
//        NSLog(@"GGK warning: aCaptureConnection nil");
//        UIImageWriteToSavedPhotosAlbum(nil, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    }
//}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
    
    self.activeTextField = theTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    
    // Behavior depends on which text field was edited. Regardless, check the entered value. If not okay, set to an appropriate value. Store the value.
    
    NSString *theKey;
    id okayValue;
    
    if (theTextField == self.numberOfSecondsToInitiallyWaitTextField) {
        
        theKey = GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;
        okayValue = @([theTextField.text integerValue]);
        
        // number of seconds to initially wait should be an integer, 0 to 99.
        NSInteger okayValueInteger = [okayValue integerValue];
        if (okayValueInteger < 0) {
            
            okayValue = @0;
        } else if (okayValueInteger > 99) {
            
            okayValue = @99;
        }
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        
        theKey = GGKTakeDelayedPhotosNumberOfPhotosKeyString;
        okayValue = @([theTextField.text integerValue]);
        
        // number of photos should be from 1 to 99
        NSInteger okayValueInteger = [okayValue integerValue];
        if (okayValueInteger < 1) {
            
            okayValue = @1;
        } else if (okayValueInteger > 99) {
            
            okayValue = @99;
        }
    }
    
    // Since the entered value may have been converted, show the converted value.
    //don't need this line?
    theTextField.text = [okayValue stringValue];
    
    if (theTextField == self.numberOfSecondsToInitiallyWaitTextField || theTextField == self.numberOfPhotosToTakeTextField) {
        
        [self adjustStringsForPlurals];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:okayValue forKey:theKey];
        
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)updateForAllowingCancelTimer
{
    self.numberOfSecondsToInitiallyWaitTextField.enabled = NO;
    self.numberOfPhotosToTakeTextField.enabled = NO;
    self.numberOfSecondsWaitedLabel.hidden = NO;
    self.startTimerButton.enabled = NO;
    self.cancelTimerButton.enabled = YES;
}

- (void)updateForAllowingStartTimer
{
    self.numberOfSecondsToInitiallyWaitTextField.enabled = YES;
    self.numberOfPhotosToTakeTextField.enabled = YES;
    self.numberOfSecondsWaitedLabel.hidden = YES;
    self.numberOfPhotosTakenLabel.hidden = YES;
    self.startTimerButton.enabled = YES;
    self.cancelTimerButton.enabled = NO;
}

- (void)updateLayoutForPortrait
{
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.soundModel = [[GGKSoundModel alloc] init];
    self.savedPhotosManager = [[GGKSavedPhotosManager alloc] init];
    [self updateLayoutForPortrait];
    
    // Report focus (and exposure) status in real time.
    [self addObserver:self forKeyPath:@"captureManager.focusAndExposureStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    // Set up the camera.
    GGKCaptureManager *theCaptureManager = [[GGKCaptureManager alloc] init];
    theCaptureManager.delegate = self;
    [theCaptureManager setUpSession];
    [theCaptureManager addPreviewLayerToView:self.videoPreviewView];
    [theCaptureManager startSession];
    self.captureManager = theCaptureManager;
    
    // Observe keyboard notifications to shift the screen up/down appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Set parameters to most-recent.
    
    NSNumber *numberOfSecondsToInitiallyWaitNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    if (numberOfSecondsToInitiallyWaitNumber == nil) {
        
        numberOfSecondsToInitiallyWaitNumber = @(GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger);
    }
    self.numberOfSecondsToInitiallyWaitTextField.text = [numberOfSecondsToInitiallyWaitNumber stringValue];
    
    NSNumber *numberOfPhotosNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString];
    if (numberOfPhotosNumber == nil) {
        
        numberOfPhotosNumber = @(GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger);
    }
    self.numberOfPhotosToTakeTextField.text = [numberOfPhotosNumber stringValue];
    
    [self adjustStringsForPlurals];
    
    [self updateForAllowingStartTimer];
}

- (IBAction)viewPhotos {
    
    NSLog(@"viewPhotos called");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.appWillEnterForegroundObserver == nil) {
        
        self.appWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [self viewWillAppear:animated];
        }];
    }
    
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.appWillEnterForegroundObserver != nil) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self.appWillEnterForegroundObserver name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

@end
