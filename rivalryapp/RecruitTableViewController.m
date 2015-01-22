//
//  RecruitTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 1/12/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "RecruitTableViewController.h"

@interface RecruitTableViewController ()

@end

#pragma mark - UIViewController Methods

@implementation RecruitTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get DataHelper instance
    helper = [DataHelper getInstance];
    
    //Set UITableViewCell class
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"contactCell"];
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"socialCell"];
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"inviteCell"];
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"requestCell"];
    
    //Section Numbers
    numOfSections = 3;
    searchSection = 0;
    contactsSection = -1;
    requestSection = -1;
    inviteSection = 1;
    socialSection = 2;
    
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

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == searchSection)
    {
        return 1;
    }
    else if (section == contactsSection)
    {
        return [contactFriends count];
    }
    else if (section == inviteSection)
    {
        return 1;
    }
    else if (section == socialSection)
    {
        return 2;
    }
    else if (section == requestSection)
    {
        return [friendRequests count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == searchSection)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        
        [self createSearchField:cell];
        
        return cell;
    }
    else if (indexPath.section == contactsSection)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
        
        //Get Team for Row
        PFUser *friend = [contactFriends objectAtIndex:indexPath.row];
        
        //Add Team Name to Cell
        cell.teamNameLabel.text = friend.username;
        
        PFObject *friendTeam = friend[@"primaryTeam"];
        
        //Set Cell Styles
        cell.backgroundColor = [DataHelper colorFromHex:friendTeam[@"PrimaryColor"]];
        cell.teamNameLabel.textColor = [DataHelper colorFromHex:friendTeam[@"SecondaryColor"]];
        
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else if (indexPath.section == socialSection)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"socialCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0)
        {
            cell.teamNameLabel.text = @"FACEBOOK";
            cell.backgroundColor = [DataHelper colorFromHex:@"#3B5998"];
        }
        else
        {
            cell.teamNameLabel.text = @"TWITTER";
            cell.backgroundColor = [DataHelper colorFromHex:@"#55ACEE"];
        }
        
        cell.teamNameLabel.textColor = [UIColor whiteColor];
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else if (indexPath.section == inviteSection)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inviteCell" forIndexPath:indexPath];
        
        cell.backgroundColor = [DataHelper colorFromHex:@"#262A2C"];
        cell.teamNameLabel.text = @"CONTACTS";
        cell.teamNameLabel.textColor = [UIColor whiteColor];
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else if (indexPath.section == requestSection)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"requestCell" forIndexPath:indexPath];
        
        //Get Team for Row
        PFUser *friend = [friendRequests objectAtIndex:indexPath.row];
        
        //Add Team Name to Cell
        cell.teamNameLabel.text = friend.username;
        
        PFObject *friendTeam = friend[@"primaryTeam"];
        
        //Set Cell Styles
        cell.backgroundColor = [DataHelper colorFromHex:friendTeam[@"PrimaryColor"]];
        cell.teamNameLabel.textColor = [DataHelper colorFromHex:friendTeam[@"SecondaryColor"]];
        
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else
    {
        return [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == searchSection)
    {
        return 0.00001f;
    }
    else if (section == contactsSection)
    {
        return 50;
    }
    else if (section == socialSection)
    {
        return 50;
    }
    else if (section == inviteSection)
    {
        return 50;
    }
    else if (section == requestSection)
    {
        return 50;
    }
    
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == contactsSection)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:contactsSection]];
        headerView.backgroundColor = [self.tableView.backgroundColor colorWithAlphaComponent:0.8];
        
        //Create the contacts header Label
        UILabel *contactsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - 25, headerView.frame.size.width, 20)];
        contactsLabel.text = @"Contacts already using Rivalry!";
        contactsLabel.textAlignment = NSTextAlignmentCenter;
        contactsLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:18.0];
        contactsLabel.textColor = [DataHelper colorFromHex:@"#5C5C5C"];
        [headerView addSubview:contactsLabel];
        
        return headerView;
    }
    else if (section == socialSection)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:socialSection]];
        headerView.backgroundColor = [self.tableView.backgroundColor colorWithAlphaComponent:0.8];
        
        //Create the contacts header Label
        UILabel *socialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - 25, headerView.frame.size.width, 20)];
        socialLabel.text = @"Invite friends online";
        socialLabel.textAlignment = NSTextAlignmentCenter;
        socialLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:18.0];
        socialLabel.textColor = [DataHelper colorFromHex:@"#5C5C5C"];
        [headerView addSubview:socialLabel];
        
        return headerView;
    }
    else if (section == inviteSection)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:inviteSection]];
        headerView.backgroundColor = [self.tableView.backgroundColor colorWithAlphaComponent:0.8];
        
        //Create the contacts header Label
        UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - 25, headerView.frame.size.width, 20)];
        inviteLabel.text = @"Invite friends from your contacts";
        inviteLabel.textAlignment = NSTextAlignmentCenter;
        inviteLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:18.0];
        inviteLabel.textColor = [DataHelper colorFromHex:@"#5C5C5C"];
        [headerView addSubview:inviteLabel];
        
        return headerView;
    }
    else if (section == requestSection)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:requestSection]];
        headerView.backgroundColor = [self.tableView.backgroundColor colorWithAlphaComponent:0.8];
        
        //Create the contacts header Label
        UILabel *requestLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - 25, headerView.frame.size.width, 20)];
        requestLabel.text = @"Actice Friend Requests";
        requestLabel.textAlignment = NSTextAlignmentCenter;
        requestLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:18.0];
        requestLabel.textColor = [DataHelper colorFromHex:@"#5C5C5C"];
        [headerView addSubview:requestLabel];
        
        return headerView;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == socialSection)
    {
        if (indexPath.row == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self shareWithService:SLServiceTypeFacebook];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self shareWithService:SLServiceTypeTwitter];
            });
        }
    }
    else if (indexPath.section == requestSection)
    {
        PFUser *friend = [friendRequests objectAtIndex:indexPath.row];
        TeamSelectTableViewCell *selectedCell = (TeamSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        selectedCell.useTimer = NO;
        selectedCell.customFlipText = @"ACCEPTED!";
        selectedCell.customSubText = @"";
        [selectedCell flip:nil];
        [helper confirmFriendRequest:friend callback:^(BOOL successful)
        {
            if (successful)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self performSelectorOnMainThread:@selector(removeFriendRequest:) withObject:indexPath waitUntilDone:NO];
                });
                
            }
        }];
    }
}

- (void)removeFriendRequest:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    NSMutableArray *friendRequests_m = [friendRequests mutableCopy];
    [friendRequests_m removeObjectAtIndex:indexPath.row];
    friendRequests = [NSArray arrayWithArray:friendRequests_m];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    if (friendRequests.count == 0)
    {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:requestSection] withRowAnimation:UITableViewRowAnimationLeft];
        numOfSections --;
        requestSection = -1;
        if (contactsSection != -1)
        {
            contactsSection --;
        }
        socialSection --;
        inviteSection --;
    }
    [self.tableView endUpdates];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Custom Methods

- (void)getData
{
    contactsDone = NO;
    requestsDone = NO;
    
    //Add progress indicator
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    [helper getContactFriends:^(BOOL successful)
    {
        contactsDone = YES;
        
        //If friends are fetched, reload data
        if (successful)
        {
            contactFriends = helper.contactFriends;
        }
        
        if (requestsDone)
        {
            [self setupSectionsAndReload];
        }
    }];
    
    [helper getFriendRequests:^(BOOL successful)
    {
        requestsDone = YES;
        
        //If friends are fetched, reload data
        if (successful)
        {
            friendRequests = helper.requests;
        }
        
        if (contactsDone)
        {
            [self setupSectionsAndReload];
        }
    }];
}

- (void)setupSectionsAndReload
{
    if ([contactFriends count] > 0)
    {
        numOfSections ++;
        contactsSection = searchSection + 1;
        inviteSection ++;
        socialSection ++;
    }
    
    if ([friendRequests count] > 0)
    {
        numOfSections ++;
        requestSection = searchSection + 1;
        if (contactsSection != -1)
        {
            contactsSection ++;
        }
        inviteSection ++;
        socialSection ++;
    }
    
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
}

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
    
    //Create Login Button
    doneButton = [[UIButton alloc] init];
    doneButton.frame = CGRectMake(0, 0, 68, 30);
    doneButton.backgroundColor = [secondary colorWithAlphaComponent:1.0];
    [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0];
    [doneButton setTitleColor:primary forState:UIControlStateNormal];
    [doneButton setTitleColor:[primary colorWithAlphaComponent:1.0] forState:UIControlStateDisabled];
    doneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    doneButton.layer.cornerRadius = 3.0;
    doneButton.layer.masksToBounds = YES;
    [doneButton addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Padding
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -10.0;
    
    //Add Done Button to Nav Bar
    doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    doneBarButton.enabled = YES;
    self.navigationItem.rightBarButtonItems = @[space, doneBarButton];
    
    //Get rid of extra lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
}

- (void)doneClicked
{
    [self performSegueWithIdentifier:@"exitRecruit" sender:self];
}

- (void)createSearchField:(UITableViewCell *)cell
{
    searchField = [[UITextField alloc] initWithFrame:cell.contentView.frame];
    searchField.textAlignment = NSTextAlignmentCenter;
    searchField.textColor = [UIColor whiteColor];
    searchField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchField.spellCheckingType = UITextSpellCheckingTypeNo;
    searchField.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:30.0];
    searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    NSAttributedString *searchPlaceholder = [[NSAttributedString alloc] initWithString:@"SEARCH" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:30.0], NSForegroundColorAttributeName:[DataHelper colorFromHex:@"#545454"]}];
    searchField.attributedPlaceholder = searchPlaceholder;
    [cell addSubview:searchField];
}

- (void)shareWithService:(NSString *)serviceType
{
    SLComposeViewController *shareController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
    SLComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result)
    {
        [shareController dismissViewControllerAnimated:YES completion:^{
            //Share Controller Dismissed
        }];
        
        if (result == SLComposeViewControllerResultCancelled)
        {
            //Canceled
        }
        else if (result == SLComposeViewControllerResultDone)
        {
            //Posted
        }
    };
    
    PFUser *currentUser = [PFUser currentUser];
    [shareController setInitialText:[NSString stringWithFormat:@"This is so cool! Download 'Rivalry!' and add me as %@!", currentUser.username]];
    [shareController addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/rivalry!/id931709155?mt=8&uo=4"]];
    [shareController setCompletionHandler:completionHandler];
    [self presentViewController:shareController animated:YES completion:^{
        //Share Controller Shown
    }];
}

@end
