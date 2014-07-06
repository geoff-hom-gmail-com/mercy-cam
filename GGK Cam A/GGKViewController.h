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

// The view disappeared from the user, so stop any repeating updates.
// A view disappears from the user in two ways: 1) the app makes the view appear/disappear and 2) the app  enters the background (go to home screen, another app or screen lock). -viewDidDisappear: is called for 1). UIApplicationDidEnterBackgroundNotification is sent for 2). To have a consistent UI, both will call this method. Subclasses should call super and override.
// The background notification can be received independent of a VC's visibility (i.e., position in the nav stack). To prevent this, we'll add the observer in -viewWillAppear: and remove it in -viewWillDisappear:.
- (void)handleViewDidDisappearFromUser;
// The view will appear to the user, so ensure it's up to date.
// A view appears in two ways: 1) the app makes the view appear/disappear and 2) the app enters the foreground (from the home screen, another app or screen lock). -viewWillAppear: is called for 1). UIApplicationWillEnterForegroundNotification is sent for 2). To have a consistent UI, both will call this method. Subclasses should call super and override.
// The foreground notification can be received independent of a VC's visibility (i.e., position in the nav stack). To prevent this, we'll add the observer in -viewWillAppear: and remove it in -viewWillDisappear:.
- (void)handleViewWillAppearToUser;
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
