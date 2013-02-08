//
//  GGKSimpleDelayedPhotoViewController.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKSimpleDelayedPhotoViewController : UIViewController

// Camera input is shown here.
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

// Take photo(s).
- (IBAction)takePhoto;

@end
