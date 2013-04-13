//
//  GGKTakePhotoViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKTakePhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Tap to see camera roll. This button shows the most-recent photo in the roll.
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;

// Tap to start the timer for taking photos.
//@property (weak, nonatomic) IBOutlet UIButton *startTimerButton;

// To let user know, visually, that the timer started.
//@property (weak, nonatomic) IBOutlet UILabel *timerStartedLabel;

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

// UIViewController override. For stopping the capture session.
- (void)dealloc;

// Story: User taps on a button (touch down). User hears a sound, giving her more feedback that she pressed it.
- (IBAction)playButtonSound;

// Take a photo.
- (IBAction)takePhoto;

// Story: User took photos. User viewed photos. User decided to delete some photos.
// So, let the user view the taken photos and (optionally) remove them.
- (IBAction)viewPhotos;

// UIViewController override.
- (void)viewWillAppear:(BOOL)animated;

@end
