//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

// Import order is modeled from http://qualitycoding.org/import-order/.
#import "GGKMercyCamAppDelegate.h"

#import "GGKDelayedPhotosModel.h"
#import "GGKInAppPurchaseManager.h"
#import "GGKLongTermViewController.h"
#import "GGKModel.h"
#import "GGKSoundModel.h"
#import "GGKDelayedSpacedPhotosViewController.h"
//#import "GGKDelayedPhotosViewController.h"
#import "TestFlight.h"

@interface GGKMercyCamAppDelegate ()
@end

@implementation GGKMercyCamAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [TestFlight takeOff:@"7fe86397-6095-4614-b633-25e1d5831861"];
    
    [self registerDefaults];
//    [self handleIfFirstLaunch];
    self.delayedPhotosModel = [[GGKDelayedPhotosModel alloc] init];
    self.model = [[GGKModel alloc] init];
    self.soundModel = [[GGKSoundModel alloc] init];
    
    GGKInAppPurchaseManager *theInAppPurchaseManager = [[GGKInAppPurchaseManager alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:theInAppPurchaseManager];
    self.inAppPurchaseManager = theInAppPurchaseManager;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)registerDefaults {
    NSDictionary *aDefaultsDictionary = @{GGKDelayedPhotosNumberOfPhotosToTakeIntegerKeyString:@3,
                                          GGKDelayedPhotosNumberOfSecondsToWaitIntegerKeyString:@2};
    [[NSUserDefaults standardUserDefaults] registerDefaults:aDefaultsDictionary];
}
@end
