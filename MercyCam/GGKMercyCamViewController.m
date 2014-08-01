//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCamViewController.h"

//BOOL GGKCreateLaunchImages = YES;
BOOL GGKCreateLaunchImages = NO;

@implementation GGKMercyCamViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Make UI blank so we can make launch images via screenshot.
    if (GGKCreateLaunchImages) {
        self.navigationItem.title = @"";
        for (UIView *aSubView in self.view.subviews) {
            aSubView.hidden = YES;
        }
    }
}
@end
