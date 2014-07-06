//
//  GGKInAppPurchaseManager.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/3/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKInAppPurchaseManager.h"

#import <StoreKit/StoreKit.h>

NSString *GGKGiveDollarProductIDString = @"com.geoffhom.MercyCamera.GiveADollar";

@interface GGKInAppPurchaseManager ()

- (void)handleCompletedTransaction:(SKPaymentTransaction *)theTransaction;
// Store the purchase. Notify user.
// We store the purchase here, because the delegate may be nil. (The user may have moved to another section of the app

- (void)handleFailedTransaction:(SKPaymentTransaction *)theTransaction;
// Usually happens because user decided not to purchase. Remove from payment queue.

@end

@implementation GGKInAppPurchaseManager

- (BOOL)buyProductWithID:(NSString *)theProductID
{
    __block BOOL thePaymentWasAdded = NO;
    if ([SKPaymentQueue canMakePayments]) {
        
        // Find the product with the given ID.
        [self.availableProducts enumerateObjectsUsingBlock:^(SKProduct *aProduct, NSUInteger idx, BOOL *stop) {
            
            if ([aProduct.productIdentifier isEqualToString:theProductID]) {
                
                SKPayment *thePayment = [SKPayment paymentWithProduct:aProduct];
                [ [SKPaymentQueue defaultQueue] addPayment:thePayment ];
                thePaymentWasAdded = YES;
                *stop = YES;
            }
        }];
    } else {
        
        // Warn user that purchases are disabled.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't Purchase" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alertView.message = [ NSString stringWithFormat:@"You can't purchase this, because in-app purchases are currently disabled on this device. To change this, open the Settings app, then go to General -> Restrictions -> In-App Purchases."];
        [alertView show];
    }
    return thePaymentWasAdded;
}

- (void)handleCompletedTransaction:(SKPaymentTransaction *)theTransaction {
    
    [ [SKPaymentQueue defaultQueue] finishTransaction:theTransaction ];
    [self.delegate inAppPurchaseManagerDidHandleCompletedTransaction:self];
}

- (void)handleFailedTransaction:(SKPaymentTransaction *)theTransaction {
    
    // If the transaction failed *not* because the user cancelled, then notify the user.
    if (theTransaction.error.code != SKErrorPaymentCancelled) {
        
        UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:@"Error" message:theTransaction.error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil ];
        [alertView show];
    }
    [ [SKPaymentQueue defaultQueue] finishTransaction:theTransaction ];
    [self.delegate inAppPurchaseManagerDidHandleFailedTransaction:self];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)theTransactions {
    
    for (SKPaymentTransaction *aTransaction in theTransactions) {
        
        switch (aTransaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                
                NSLog(@"Transaction completed: yay");
                [self handleCompletedTransaction:aTransaction];
                break;
            case SKPaymentTransactionStateFailed:
                
                NSLog(@"Transaction failed");
                [self handleFailedTransaction:aTransaction];
                break;
            case SKPaymentTransactionStateRestored:
                
                NSLog(@"Transaction restored: not expected?");
                //                [self handleRestoredTransaction:aTransaction];
                break;
            default:
                
                break;
        }
    }
}

- (void)productsRequest:(SKProductsRequest *)theRequest didReceiveResponse:(SKProductsResponse *)theResponse
{
    NSLog(@"pR dRR");
    
    // We're not checking for an Internet connection specifically. If there's no Internet, then an empty products array will be here.
    // Do something only if we have a product.
    if (theResponse.products.count >= 1) {
        
        NSLog(@"pR dRR: 1+ products found");
        self.availableProducts = theResponse.products;
        [self.delegate inAppPurchaseManagerDidReceiveProducts:self];
    } else {
        
        if (theResponse.invalidProductIdentifiers.count >= 1) {
            
            [theResponse.invalidProductIdentifiers enumerateObjectsUsingBlock:^(NSString *aProductIdentifierString, NSUInteger idx, BOOL *stop) {
                
                NSLog(@"Invalid product: %@", aProductIdentifierString);
            }];
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)theError
{
    NSLog(@"request didFailWithError: %@", [theError localizedDescription]);
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"requestDidFinish");
}

- (void)requestProductData
{
    NSSet *theProductIDsSet = [NSSet setWithObject:GGKGiveDollarProductIDString];
    SKProductsRequest *theProductsRequest= [[SKProductsRequest alloc] initWithProductIdentifiers:theProductIDsSet];
    theProductsRequest.delegate = self;
    [theProductsRequest start];
    NSLog(@"requestProductData");
}

@end
