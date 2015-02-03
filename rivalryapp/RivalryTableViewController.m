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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self refreshTable];
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
        return [friends count] + [bots count];
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
        
        if (indexPath.row >= [friends count])
        {
            PFObject *bot = [bots objectAtIndex:indexPath.row - friends.count];
            
            cell.teamNameLabel.text = [NSString stringWithFormat:@"%@ BOT", [bot[@"name"] uppercaseString]];
            
            cell.backgroundColor = [DataHelper colorFromHex:bot[@"PrimaryColor"]];
            cell.teamNameLabel.textColor = [DataHelper colorFromHex:bot[@"SecondaryColor"]];
            
            cell.meLabel.text = @"0";
            cell.themLabel.text = @"0";
            cell.meLabel.textColor = [DataHelper colorFromHex:bot[@"SecondaryColor"]];
            cell.themLabel.textColor = [DataHelper colorFromHex:bot[@"SecondaryColor"]];
            
            return cell;
        }
        else
        {
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
            
            NSNumber *meCallouts = callouts[0];
            NSNumber *themCallouts = callouts[1];
            
            cell.meLabel.text = [meCallouts stringValue];
            cell.themLabel.text = [themCallouts stringValue];
            
            double meDouble = [meCallouts doubleValue];
            double themDouble = [themCallouts doubleValue];
            
            if (meDouble > themDouble)
            {
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:cell.meLabel.text];
                [attributeString addAttribute:NSUnderlineStyleAttributeName
                                        value:[NSNumber numberWithInt:1]
                                        range:(NSRange){0,[attributeString length]}];
                cell.meLabel.attributedText = attributeString;
            }
            else if (meDouble < themDouble)
            {
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:cell.themLabel.text];
                [attributeString addAttribute:NSUnderlineStyleAttributeName
                                        value:[NSNumber numberWithInt:1]
                                        range:(NSRange){0,[attributeString length]}];
                cell.themLabel.attributedText = attributeString;
            }
            cell.meLabel.textColor = [DataHelper colorFromHex:friendTeam[@"SecondaryColor"]];
            cell.themLabel.textColor = [DataHelper colorFromHex:friendTeam[@"SecondaryColor"]];
            
            return cell;
        }
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
        if (indexPath.row < friends.count)
        {
            return YES;
        }
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
        if (indexPath.row < friends.count)
        {
            //Get Selected cell and flip it
            TeamSelectTableViewCell *selectedCell = (TeamSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            selectedCell.useTimer = YES;
            
            if (!selectedCell.flipped)
            {
                //Send callout
                [helper sendCallout:[friends objectAtIndex:indexPath.row] callback:^(BOOL successful)
                 {
                     if (successful)
                     {
                         NSLog(@"Callout Sent!");
                     }
                 }];
            }
            
            //Flip cell
            [selectedCell flip:^
            {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
            
            
        }
        else
        {
            TeamSelectTableViewCell *selectedCell = (TeamSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            selectedCell.useTimer = YES;
            
            PFObject *bot = [bots objectAtIndex:indexPath.row - friends.count];
            
            [selectedCell flip:^
            {
                int meCount = [selectedCell.meLabel.text intValue];
                meCount ++;
                selectedCell.meLabel.text = [NSString stringWithFormat:@"%d", meCount];
                
                UILocalNotification *botCallout = [[UILocalNotification alloc] init];
                botCallout.alertBody = [NSString stringWithFormat:@"%@ BOT says %@!", [bot[@"name"] uppercaseString], bot[@"callout"]];
                botCallout.fireDate = [NSDate date];
                botCallout.soundName = bot[@"audioFile"];
                [[UIApplication sharedApplication] scheduleLocalNotification: botCallout];
                
                int themCount = [selectedCell.themLabel.text intValue];
                themCount ++;
                selectedCell.themLabel.text = [NSString stringWithFormat:@"%d", themCount];
            }];
        }
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
    
    if (indexPath.row < friends.count)
    {
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
    
    return nil;
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
    
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable
{
    //Set section info
    numOfSections = 2;
    recruitSection = 0;
    friendsSection = 1;
    
    //Get data
    [self getData];
}

- (void)getData
{
    //Add progress indicator
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [helper getFriends:^(BOOL successful)
    {
        friendsDone = YES;
        
        //If friends are fetched, reload data
        if (successful)
        {
            friends = helper.friends;
        }
        
        if (botsDone)
        {
            [self finishLoading];
        }
    }];
    
    [helper getIntroBots:^(BOOL successful)
    {
        botsDone = YES;
        
        if (successful)
        {
            bots = helper.bots;
        }
        
        if (friendsDone)
        {
            [self finishLoading];
        }
    }];
}

- (void)finishLoading
{
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    [self.refreshControl endRefreshing];
}

#pragma mark - Unwind Segues

- (IBAction)unwindFromSettings:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)unwindFromRecruit:(UIStoryboardSegue *)segue
{
    
}

@end
