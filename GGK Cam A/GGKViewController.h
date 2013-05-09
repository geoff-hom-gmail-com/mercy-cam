//
//  GGKViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKViewController : UIViewController

// Override.
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

// Override.
// Set up for portrait orientation.
- (void)viewDidLoad;

// Override.
// Story: View will appear to user. User sees updated view.
// Listen for app coming from background/lock. Update view.
// Whether the view appears from another view in this app or from the app entering the foreground, the user should see an updated view. -viewWillAppear: is called for the former but not the latter. So, we listen for UIApplicationWillEnterForegroundNotification (and stop listening in -viewWillDisappear:).
- (void)viewWillAppear:(BOOL)animated;

// Override.
// Undo anything from -viewWillAppear:.
- (void)viewWillDisappear:(BOOL)animated;

// Override.
// Story: Whether user rotates device in the app, or from the home screen, this method will be called. User sees UI in correct orientation.
- (void)viewWillLayoutSubviews;

@end
