//
//  GGKMercyCameraViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKOverlayViewController.h"
#import <UIKit/UIKit.h>

@interface GGKMercyCameraViewController : UIViewController <GGKOverlayViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// Help the user understand/remember what the "take delayed photos" action does.
@property (weak, nonatomic) IBOutlet UILabel *takeDelayedPhotosExampleLabel;

- (void)overlayViewControllerDidFinishWithCamera;
// So, dismiss the camera.

// UIViewController override.
- (void)viewDidLoad;

// UIViewController override.
- (void)viewWillAppear:(BOOL)animated;

@end
