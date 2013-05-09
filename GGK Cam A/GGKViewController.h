//
//  GGKViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKViewController : UIViewController

// UIViewController override.
// Assume Nib is for portrait orientation.
- (void)awakeFromNib;

// Play sound as aural feedback for pressing button.
- (IBAction)playButtonSound;

// Story: When the user should see the UI in landscape, she does.
// Stub.
- (void)updateLayoutForLandscape;

// Story: When the user should see the UI in portrait, she does.
// Stub.
- (void)updateLayoutForPortrait;

// UIViewController override.
// Set up for portrait orientation.
- (void)viewDidLoad;

// UIViewController override.
// Story: Whether user rotates device in the app, or from the home screen, this method will be called. User sees UI in correct orientation.
- (void)viewWillLayoutSubviews;

@end
