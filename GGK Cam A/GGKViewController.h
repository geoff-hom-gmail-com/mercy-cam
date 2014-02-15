//
//  GGKViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/8/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

@interface GGKViewController : UIViewController
// Override.
// Assume Nib is for portrait orientation.
- (void)awakeFromNib;
// Override.
- (void)dealloc;
// The view will appear to the user, so ensure it's up to date.
// A view can appear to the user in two ways: the app can make the view appear/disappear, or the app can enter the foreground (from the home screen, another app, or screen lock). -viewWillAppear: is called for the former but not the latter. UIApplicationWillEnterForegroundNotification is sent for the latter but not the former. To have a consistent UI, we'll have both options call -handleViewWillAppearToUser. So, subclasses should call super and override.
// The foreground notification may be received by a VC whose view isn't visible (e.g., not top of nav stack). To prevent unexpected updates, we'll add the observer in -viewWillAppear: and remove it in -viewWillDisappear:.
- (void)handleViewWillAppearToUser;
// The view disappeared from the user, so stop any visible updates.
// A view can disappear from the user in two ways: the app can make the view appear/disappear, or the app can enter the background (home button, go to another app, screen lock). -viewDidDisappear: is called for the former but not the latter. UIApplicationDidEnterBackgroundNotification is sent for the latter but not the former. To have a consistent UI, we'll have both options call -handleViewDidDisappearFromUser. So, subclasses should call super and override.
// The background notification may be received by a VC whose view isn't visible (e.g., not top of nav stack). To prevent unexpected updates, we'll add the observer in -viewWillAppear: and remove it in -viewWillDisappear:.
- (void)handleViewDidDisappearFromUser;
// Play sound as aural feedback for pressing button.
- (IBAction)playButtonSound;

// Story: When the user should see the UI in landscape, she does.
// Stub.
- (void)updateLayoutForLandscape;

// Story: When the user should see the UI in portrait, she does.
// Stub.
- (void)updateLayoutForPortrait;
// Override.
- (void)viewDidDisappear:(BOOL)animated;
// Override.
// Set up for portrait orientation.
- (void)viewDidLoad;
// Override.
- (void)viewWillAppear:(BOOL)animated;
// Override.
- (void)viewWillDisappear:(BOOL)animated;


// Override.
// Story: Whether user rotates device in the app, or from the home screen, this method will be called. User sees UI in correct orientation.
- (void)viewWillLayoutSubviews;

@end
