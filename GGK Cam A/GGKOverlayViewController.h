//
//  GGKOverlayViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GGKOverlayViewControllerDelegate

// Sent after the user tapped Cancel.
- (void)overlayViewControllerDidFinishWithCamera;

@end

@interface GGKOverlayViewController : UIViewController

@property (weak, nonatomic) id <GGKOverlayViewControllerDelegate> delegate;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

// Stop taking photos and dismiss camera.
- (IBAction)cancelPhoto;

// Take photo(s).
- (IBAction)takePhoto;

@end
