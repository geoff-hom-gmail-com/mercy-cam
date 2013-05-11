//
//  GGKTimeUnitsTableViewController.h
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTimeUnits.h"

@protocol GGKTimeUnitsTableViewControllerDelegate

// Story: User selects a row corresponding to a time unit. Delegate is notified.
- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;

@end

@interface GGKTimeUnitsTableViewController : UITableViewController

@property (nonatomic, assign) GGKTimeUnit currentTimeUnit;

@property (weak, nonatomic) id <GGKTimeUnitsTableViewControllerDelegate> delegate;

@end
