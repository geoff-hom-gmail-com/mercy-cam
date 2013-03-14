//
//  GGKSimpleDelayedPhotoViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "GGKSimpleDelayedPhotoViewController.h"

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger = 3;

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger = 2;

NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString = @"Take delayed photos: number of photos";

NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString = @"Take delayed photos: number of seconds to initially wait";

@interface GGKSimpleDelayedPhotoViewController ()

// The text field currently being edited.
@property (strong, nonatomic) UITextField *activeTextField;

@property (strong, nonatomic) AVCaptureSession *captureSession;

// Number of photos to take for a given push of the shutter.
@property (assign, nonatomic) NSInteger numberOfPhotosToTake;

// Number of seconds to wait before taking first photo.
@property (assign, nonatomic) CGFloat numberOfSecondsToInitiallyWait;

// Adjust "Wait X seconds, then take Y photos," for whether the values are singular or plural.
- (void)adjustStringsForPlurals;

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// So, update the image in the button for showing the camera roll. If another photo is supposed to be taken, do it.

- (void)keyboardWillHide:(NSNotification *)theNotification;
// So, shift the view back to normal.

- (void)keyboardWillShow:(NSNotification *)theNotification;
// So, shift the view up, if necessary.

// Show most-recent photo on button for showing camera roll.
- (void)showMostRecentPhotoOnButton;

// Start taking photos, immediately.
- (void)startTakingPhotos;

@end

@implementation GGKSimpleDelayedPhotoViewController

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
    
    NSLog(@"SDPVC cancelTimer not implemented yet");
}

- (void)dealloc {
    
    [self.captureSession stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    NSLog(@"SDPVC image:didFinishSavingWithError called");
    [self showMostRecentPhotoOnButton];
    if (self.numberOfPhotosToTake > 0) {
        
        [self takePhoto];
    } else {
        
        self.startTimerButton.enabled = YES;
        self.timerStartedLabel.hidden = YES;
        self.cancelTimerButton.enabled = NO;
    }
}

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

- (void)showMostRecentPhotoOnButton {
    
    // Show thumbnail on button for showing camera roll.
    void (^showPhotoOnButton)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *photoAsset, NSUInteger index, BOOL *stop) {
        
        // End of enumeration is signalled by asset == nil.
        if (photoAsset == nil) {
            
            return;
        }
        
        CGImageRef aPhotoThumbnailImageRef = [photoAsset thumbnail];
        UIImage *aPhotoImage = [UIImage imageWithCGImage:aPhotoThumbnailImageRef];
        [self.cameraRollButton setImage:aPhotoImage forState:UIControlStateNormal];
    };
    
    // Show thumbnail of most-recent photo in group on button for showing camera roll.
    void (^showMostRecentPhotoInGroupOnButton)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        
        // If no photos, skip.
        [ group setAssetsFilter:[ALAssetsFilter allPhotos] ];
        NSInteger theNumberOfPhotos = [group numberOfAssets];
        if (theNumberOfPhotos < 1) {
            
            return;
        }
        
        NSIndexSet *theMostRecentPhotoIndexSet = [NSIndexSet indexSetWithIndex:(theNumberOfPhotos - 1)];
        [group enumerateAssetsAtIndexes:theMostRecentPhotoIndexSet options:0 usingBlock:showPhotoOnButton];
    };
    
    ALAssetsLibrary *theAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [theAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:showMostRecentPhotoInGroupOnButton failureBlock:^(NSError *error) {
        
        NSLog(@"Warning: Couldn't see saved photos.");
    }];
}

- (void)startTakingPhotos {

//    NSLog(@"SDPVC startTakingPhotos called");
    if (self.numberOfPhotosToTake > 0) {
        
        [self takePhoto];
    }
}

- (IBAction)startTimer {

    NSLog(@"SDPVC startTimer called");
    self.startTimerButton.enabled = NO;
    self.timerStartedLabel.hidden = NO;
    self.cancelTimerButton.enabled = YES;
    
    // need validator/formatter?
    
    self.numberOfSecondsToInitiallyWait = [self.numberOfSecondsToInitiallyWaitTextField.text floatValue];
    self.numberOfPhotosToTake = [self.numberOfPhotosToTakeTextField.text integerValue];
    
    NSTimeInterval initialWaitTimeInterval = self.numberOfSecondsToInitiallyWait;
    [NSTimer scheduledTimerWithTimeInterval:initialWaitTimeInterval target:self selector:@selector(startTakingPhotos) userInfo:nil repeats:NO];
    NSLog(@"SDPVC startTimer finished");
}

- (void)takePhoto {
    
    NSLog(@"SDPVC takePhoto called");
    self.numberOfPhotosToTake -= 1;
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureSession.outputs[0];
    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
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
    
    if (aCaptureConnection != nil) {
        
        [aCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:aCaptureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer != NULL) {
                
                NSData *theImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *theImage = [[UIImage alloc] initWithData:theImageData];
                UIImageWriteToSavedPhotosAlbum(theImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
    } else {
        
        NSLog(@"GGK warning: aCaptureConnection nil");
        UIImageWriteToSavedPhotosAlbum(nil, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"SDPVC vDL called");
    
    AVCaptureSession *aCaptureSession = [[AVCaptureSession alloc] init];
//    AVCaptureSession *aCaptureSession = //get from another class
    
    AVCaptureDevice *aCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *aCameraCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:aCameraCaptureDevice error:&error];
    if (!aCameraCaptureDeviceInput) {
        
        // handle error
        NSLog(@"GGK Warning: error getting camera input.");
    }
    if ([aCaptureSession canAddInput:aCameraCaptureDeviceInput]) {
        
        [aCaptureSession addInput:aCameraCaptureDeviceInput];
    }
    
    AVCaptureStillImageOutput *aCaptureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([aCaptureSession canAddOutput:aCaptureStillImageOutput]) {
        
        [aCaptureSession addOutput:aCaptureStillImageOutput];
    }
    
    aCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Add camera preview.
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:aCaptureSession];
    aCaptureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    CALayer *viewLayer = self.videoPreviewView.layer;
    [viewLayer addSublayer:aCaptureVideoPreviewLayer];
    
    self.captureSession = aCaptureSession;
    
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [aCaptureSession startRunning];
    }];
    
    [self showMostRecentPhotoOnButton];
    
    // Observe keyboard notifications to shift the screen up/down appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.timerStartedLabel.hidden = YES;
    self.cancelTimerButton.enabled = NO;
    
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
}

- (IBAction)viewPhotos {
    
    NSLog(@"viewPhotos called");
}

@end
