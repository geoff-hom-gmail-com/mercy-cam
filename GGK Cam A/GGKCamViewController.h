//
//  GGKCamViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKOverlayViewController.h"
#import <UIKit/UIKit.h>

@interface GGKCamViewController : UIViewController <GGKOverlayViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (void)overlayViewControllerDidFinishWithCamera;
// So, dismiss the camera.

// Show UI for taking a photo.
- (IBAction)takePhoto;

@end
