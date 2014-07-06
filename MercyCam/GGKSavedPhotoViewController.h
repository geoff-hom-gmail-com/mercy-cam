//
//  GGKSavedPhotoViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/26/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GGKViewController.h"

@interface GGKSavedPhotoViewController : GGKViewController

// Story: User taps a thumbnail in an image picker. User sees larger version of image.
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

// Override.
- (void)viewDidLoad;

@end
