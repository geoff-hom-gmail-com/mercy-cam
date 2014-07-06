//
//  GGKTimeUnitsTableViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTimeUnitsTableViewController.h"

@interface GGKTimeUnitsTableViewController ()
@end

@implementation GGKTimeUnitsTableViewController

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [super tableView:theTableView cellForRowAtIndexPath:theIndexPath];
    // Add a checkmark to the currently selected time unit.
    NSString *theCurrentTimeUnitString = [GGKTimeUnits stringForTimeUnit:self.currentTimeUnit];
    UITableViewCellAccessoryType aTableViewCellAccessoryType;
    if ([cell.textLabel.text isEqualToString:theCurrentTimeUnitString]) {
        aTableViewCellAccessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        aTableViewCellAccessoryType = UITableViewCellAccessoryNone;
    }
    cell.accessoryType = aTableViewCellAccessoryType;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)theSelectedIndexPath {
    // Remove checkmark from the previously selected cell.
    NSString *thePreviouslySelectedTimeUnitString = [GGKTimeUnits stringForTimeUnit:self.currentTimeUnit];
    [[tableView indexPathsForVisibleRows] enumerateObjectsUsingBlock:^(NSIndexPath *anIndexPath, NSUInteger idx, BOOL *stop) {
        UITableViewCell *aCell = [tableView cellForRowAtIndexPath:anIndexPath];
        if ([aCell.textLabel.text isEqualToString:thePreviouslySelectedTimeUnitString]) {
            aCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }];
    // Show checkmark on the selected cell.
    UITableViewCell *theSelectedCell = [tableView cellForRowAtIndexPath:theSelectedIndexPath];
    theSelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    NSInteger theRowInteger = theSelectedIndexPath.row;
    self.currentTimeUnit = (GGKTimeUnit)theRowInteger;
    [self.delegate timeUnitsTableViewControllerDidSelectTimeUnit:self];
}
@end
