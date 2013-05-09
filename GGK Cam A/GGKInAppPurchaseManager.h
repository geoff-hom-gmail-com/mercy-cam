//
//  GGKInAppPurchaseManager.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/3/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

// Handles both product retrieval and purchase from the App Store. Notifies delegate when product info has been retrieved, when a purchase/transaction was successful, and when a purchase/transaction failed. Does not currently handle restored transactions.

#import <StoreKit/StoreKit.h>

// String for the product ID for giving a dollar.
extern NSString *GGKGiveDollarProductIDString;

@protocol GGKInAppPurchaseManagerDelegate

// Sent after a transaction completed.
- (void)inAppPurchaseManagerDidHandleCompletedTransaction:(id)sender;

// Sent after a transaction failed.
- (void)inAppPurchaseManagerDidHandleFailedTransaction:(id)sender;

// Sent after products were successfully received from the App Store.
- (void)inAppPurchaseManagerDidReceiveProducts:(id)sender;

@end

@interface GGKInAppPurchaseManager : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

// Array of products available for in-app purchase.
@property (nonatomic, strong) NSArray *availableProducts;

@property (weak, nonatomic) id <GGKInAppPurchaseManagerDelegate> delegate;

// Create payment object and add to queue. If purchasing disabled on device, alert user. Return whether the payment was added.
- (BOOL)buyProductWithID:(NSString *)theProductID;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
// The payment either completed, failed, or was restored. So, handle the transactions.

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
// So, notify delegate.

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;
// So, log the error.

- (void)requestDidFinish:(SKRequest *)request;
// So, log the success.

// Ask App Store for info on available products.
- (void)requestProductData;

@end
