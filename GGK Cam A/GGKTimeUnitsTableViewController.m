//
//  GGKTimeUnitsTableViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTimeUnitsTableViewController.h"

NSString *GGKTimeUnitDaysString = @"days";

NSString *GGKTimeUnitHoursString = @"hours";

NSString *GGKTimeUnitMinutesString = @"minutes";

NSString *GGKTimeUnitSecondsString = @"seconds";

@interface GGKTimeUnitsTableViewController ()

@end

@implementation GGKTimeUnitsTableViewController

+ (NSString *)stringForTimeUnit:(GGKTimeUnit)theTimeUnit
{
    NSString *aTimeUnitString;
    switch (theTimeUnit) {
            
        case GGKTimeUnitSeconds:
            aTimeUnitString = GGKTimeUnitSecondsString;
            break;
            
        case GGKTimeUnitMinutes:
            aTimeUnitString = GGKTimeUnitMinutesString;
            break;
            
        case GGKTimeUnitHours:
            aTimeUnitString = GGKTimeUnitHoursString;
            break;
            
        case GGKTimeUnitDays:
            aTimeUnitString = GGKTimeUnitDaysString;
            break;
            
        default:
            break;
    }
    return aTimeUnitString;
}

+ (GGKTimeUnit)timeUnitForString:(NSString *)theTimeUnitString
{
    GGKTimeUnit theTimeUnit = GGKTimeUnitSeconds;
    if ([theTimeUnitString isEqualToString:GGKTimeUnitSecondsString]) {
        
        theTimeUnit = GGKTimeUnitSeconds;
    } else if ([theTimeUnitString isEqualToString:GGKTimeUnitMinutesString]) {
        
        theTimeUnit = GGKTimeUnitMinutes;
    } else if ([theTimeUnitString isEqualToString:GGKTimeUnitHoursString]) {
        
        theTimeUnit = GGKTimeUnitHours;
    } else if ([theTimeUnitString isEqualToString:GGKTimeUnitDaysString]) {
        
        theTimeUnit = GGKTimeUnitDays;
    }
    return theTimeUnit;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Add a checkmark to the currently selected time unit.
    NSString *theCurrentTimeUnitString = [GGKTimeUnitsTableViewController stringForTimeUnit:self.currentTimeUnit];
    UITableViewCellAccessoryType aTableViewCellAccessoryType;
    if ([cell.textLabel.text isEqualToString:theCurrentTimeUnitString]) {
        
        aTableViewCellAccessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        
        aTableViewCellAccessoryType = UITableViewCellAccessoryNone;
    }
    cell.accessoryType = aTableViewCellAccessoryType;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)theSelectedIndexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    // Remove checkmark from the previously selected cell.
    NSString *thePreviouslySelectedTimeUnitString = [GGKTimeUnitsTableViewController stringForTimeUnit:self.currentTimeUnit];
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
    self.currentTimeUnit = theRowInteger;
    [self.delegate timeUnitsTableViewControllerDidSelectTimeUnit:self];
}

@end
