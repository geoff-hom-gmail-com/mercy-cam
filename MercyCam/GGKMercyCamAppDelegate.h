//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

@class GGKDelayedPhotosModel, GGKInAppPurchaseManager, GGKModel, GGKSoundModel;

@interface GGKMercyCamAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) GGKDelayedPhotosModel *delayedPhotosModel;
// For observing App Store transactions, regardless of where in the app the user is.
@property (nonatomic, strong) GGKInAppPurchaseManager *inAppPurchaseManager;
@property (strong, nonatomic) GGKModel *model;
// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;
@property (strong, nonatomic) UIWindow *window;
// So, save user defaults.
- (void)applicationDidEnterBackground:(UIApplication *)application;
// Register default values.
- (void)registerDefaults;
@end
