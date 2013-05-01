//
//  GGKSavedPhotosManager.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/29/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGKSavedPhotosManager : NSObject

// Show most-recent photo from camera roll on the given button.
- (void)showMostRecentPhotoOnButton:(UIButton *)theButton;

// Show the camera roll in a popover presented from the given button.
- (void)viewPhotosViaButton:(UIButton *)theButton;

@end
