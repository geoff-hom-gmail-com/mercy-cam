//
//  GGKSavedPhotosManager.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/29/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKSavedPhotosManager.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GGKSavedPhotosManager ()

// For retaining the popover and its content view controller.
@property (nonatomic, strong) UIPopoverController *savedPhotosPopoverController;

@end

@implementation GGKSavedPhotosManager

- (void)showMostRecentPhotoOnButton:(UIButton *)theButton
{
    // Show thumbnail on button.
    void (^showPhotoOnButton)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *thePhotoAsset, NSUInteger index, BOOL *stop) {
        
        // End of enumeration is signaled by nil.
        if (thePhotoAsset == nil) {
            
            return;
        }
        
        CGImageRef aPhotoThumbnailImageRef = [thePhotoAsset thumbnail];
        UIImage *aPhotoImage = [UIImage imageWithCGImage:aPhotoThumbnailImageRef];
        //        NSLog(@"TPVC sMRPOB image size: %@", NSStringFromCGSize(aPhotoImage.size));
        
        // Show photo and no text.
        [theButton setImage:aPhotoImage forState:UIControlStateNormal];
        [theButton setTitle:nil forState:UIControlStateNormal];
    };
    
    // Show most-recent photo in the given group on a given button.
    void (^showMostRecentPhotoInGroupOnButton)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *theGroup, BOOL *stop) {
        
        // End of enumeration is signaled by nil.
        if (theGroup == nil) {
            
            return;
        }
        
        [ theGroup setAssetsFilter:[ALAssetsFilter allPhotos] ];
        NSInteger theNumberOfPhotos = [theGroup numberOfAssets];
        
        // If no photos, show text.
        if (theNumberOfPhotos < 1) {
            
            [theButton setTitle:@"Saved photos" forState:UIControlStateNormal];
            [theButton setImage:nil forState:UIControlStateNormal];
            return;
        }
        
        NSIndexSet *theMostRecentPhotoIndexSet = [NSIndexSet indexSetWithIndex:(theNumberOfPhotos - 1)];
        [theGroup enumerateAssetsAtIndexes:theMostRecentPhotoIndexSet options:0 usingBlock:showPhotoOnButton];
    };
    
    ALAssetsLibrary *theAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [theAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:showMostRecentPhotoInGroupOnButton failureBlock:^(NSError *error) {
        
        NSLog(@"Warning: Couldn't see saved photos.");
    }];
}

@end
