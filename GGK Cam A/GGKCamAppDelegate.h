//
//  GGKCamAppDelegate.h
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GGKInAppPurchaseManager;

@interface GGKCamAppDelegate : UIResponder <UIApplicationDelegate>

// For observing App Store transactions, regardless of where in the app the user is.
@property (nonatomic, strong) GGKInAppPurchaseManager *inAppPurchaseManager;

@property (strong, nonatomic) UIWindow *window;

- (void)applicationDidEnterBackground:(UIApplication *)application;
// So, save user defaults.

@end
