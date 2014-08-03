//
//  GGKTakeDelayedPhotosAbstractViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//
// Abstract class for taking delayed photos. It should include most of what you need. Subclasses should work by blanking out features rather than adding them, so add new features here. 

// DEPRECATE?

#import "GGKAbstractPhotoViewController.h"
#import "GGKTimeUnits.h"
#import "GGKTimeUnitsTableViewController.h"

@interface GGKAbstractDelayedPhotosViewController : GGKAbstractPhotoViewController < UIGestureRecognizerDelegate>

// Override.
- (void)dealloc;

// Retrieve the timer settings from user defaults.
// Stub.
- (void)getSavedTimerSettings;

// Override.
- (void)viewDidLoad;
@end
