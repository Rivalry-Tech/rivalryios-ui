//
//  RivalryTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 1/3/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "RivalryTableViewController.h"

@interface RivalryTableViewController ()

@end

@implementation RivalryTableViewController

#pragma mark - UIViewController Mehods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get DataHelper instance
    helper = [DataHelper getInstance];
    
    //Use TeamSelectTableViewCell
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"friendCell"];
    
    //Set section info
    numOfSections = 2;
    recruitSection = 0;
    friendsSection = 1;
    
    //Get data
    [self getData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setViewStyles];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == recruitSection)
    {
        return 1;
    }
    else if (section == friendsSection)
    {
        return [friends count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == recruitSection)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recruitCell" forIndexPath:indexPath];
        
        return cell;
    }
    else if (indexPath.section == friendsSection)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
        
        //Get Team for Row
        PFUser *friend = [friends objectAtIndex:indexPath.row];
        
        //Add Team Name to Cell
        cell.teamNameLabel.text = friend.username;
        
        PFObject *friendTeam = friend[@"primaryTeam"];
        
        //Set Cell Styles
        cell.backgroundColor = [DataHelper colorFromHex:friendTeam[@"PrimaryColor"]];
        cell.teamNameLabel.textColor = [DataHelper colorFromHex:friendTeam[@"SecondaryColor"]];
        
        //Get User callouts
        NSArray *callouts = [helper calloutCountsWithUser:friend];
        
        cell.meLabel.text = [callouts[0] stringValue];
        cell.themLabel.text = [callouts[1] stringValue];
        cell.meLabel.textColor = [DataHelper colorFromHex:friendTeam[@"SecondaryColor"]];
        cell.themLabel.textColor = [DataHelper colorFromHex:friendTeam[@"SecondaryColor"]];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recruitCell" forIndexPath:indexPath];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == friendsSection)
    {
        return YES;
    }
    
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == recruitSection)
    {
        return 30;
    }
    else if (section == friendsSection)
    {
        return 30;
    }
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //Padding for recruit button
    if (section == recruitSection)
    {
        return 20.0;
    }
    
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == recruitSection)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:recruitSection]];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    else if (section == friendsSection)
    {
        //Create Header View
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:friendsSection]];
        headerView.backgroundColor = [self.tableView.backgroundColor colorWithAlphaComponent:0.8];
        
        //Create the ME Label
        UILabel *meLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.frame.size.width - 30, headerView.frame.size.height)];
        meLabel.text = @"ME";
        meLabel.textAlignment = NSTextAlignmentLeft;
        meLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0];
        meLabel.textColor = [DataHelper colorFromHex:@"#5C5C5C"];
        [headerView addSubview:meLabel];
        
        //Create the THEM label
        UILabel *themLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20, headerView.frame.size.height)];
        themLabel.text = @"THEM";
        themLabel.textAlignment = NSTextAlignmentRight;
        themLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0];
        themLabel.textColor = [DataHelper colorFromHex:@"#5C5C5C"];
        [headerView addSubview:themLabel];
        
        return headerView;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //Padding for recruit button
    if (section == recruitSection)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:recruitSection]];
        footerView.backgroundColor = [UIColor clearColor];
        
        return footerView;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == recruitSection)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self performSegueWithIdentifier:@"showRecruit" sender:self];
        });
    }
    else if (indexPath.section == friendsSection)
    {
        //Get Selected cell and flip it
        TeamSelectTableViewCell *selectedCell = (TeamSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        selectedCell.useTimer = YES;
        
        //Flip cell
        [selectedCell flip:^
        {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        //Send callout
        [helper sendCallout:[friends objectAtIndex:indexPath.row] callback:^(BOOL successful)
        {
            if (successful)
            {
                //Callout Sent
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Need this, but don't need implementation
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"MUTE" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//    {
//        //TODO - MUTE PEOPLE
//    }];
    
    UITableViewRowAction *unfriendAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"UNFRIEND" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        //Delete friend from server
        [helper deleteFriend:[friends objectAtIndex:indexPath.row] callback:^(BOOL successful)
        {
            //Delete Friend Successful
        }];
        
        //Delete row from table view
        [tableView beginUpdates];
        NSMutableArray *mutableFriends = [friends mutableCopy];
        [mutableFriends removeObjectAtIndex:indexPath.row];
        friends = mutableFriends;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
    }];
    
    return @[unfriendAction];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Custom Methods

- (void)setViewStyles
{
    //Get Team Colors
    UIColor *primary = [DataHelper colorFromHex:helper.myTeam[@"PrimaryColor"]];
    UIColor *secondary = [DataHelper colorFromHex:helper.myTeam[@"SecondaryColor"]];
    
    //Set status bar style
    if (helper.myTeam[@"lightStatus"] == [NSNumber numberWithBool:YES])
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
    
    //Navigation Bar Styles
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:secondary, NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20.0],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.barTintColor = primary;
    self.navigationController.navigationBar.tintColor = secondary;
    
    //Hide back button
    [self.navigationItem setHidesBackButton:YES];
    
    //Set username as title
    PFUser *currentUser = [PFUser currentUser];
    self.title = currentUser.username;
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    //Get rid of extra lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)getData
{
    //Add progress indicator
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [helper getFriends:^(BOOL successful)
    {
        //If friends are fetched, reload data
        if (successful)
        {
            friends = helper.friends;
            [self.tableView reloadData];
        }
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    }];
}

#pragma mark - Unwind Segues

- (IBAction)unwindFromSettings:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)unwindFromRecruit:(UIStoryboardSegue *)segue
{
    
}

@end
