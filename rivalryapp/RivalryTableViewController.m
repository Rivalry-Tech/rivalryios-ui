//
//  RivalryTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/18/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "RivalryTableViewController.h"

@interface RivalryTableViewController ()

@end

@implementation RivalryTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init DataHelper
    helper = [DataHelper getInstance];
    
    //Create Section Numbers
    instructionsSection = 0;
    botsSection = 1;
    numberOfSections = 2;
    
    //Set cell class for bot cells
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"botCell"];
    
    //Get data for view
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Set styles each time view is displayed
    [self setViewStyles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == instructionsSection)
    {
        return 1;
    }
    else if (section == botsSection)
    {
        return [bots count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == instructionsSection)
    {
        //Create instructions Cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCell" forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.section == botsSection)
    {
        //Create Bot Cells. Reusing Team Select cells
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"botCell" forIndexPath:indexPath];
        
        //Get Team for Row
        PFObject *bot = [bots objectAtIndex:indexPath.row];
        
        //Add Team Name to Cell
        NSString *botName = [NSString stringWithFormat:@"%@ BOT", bot[@"name"]];
        cell.teamNameLabel.text = [botName uppercaseString];
        
        //Set Cell Styles
        cell.backgroundColor = [DataHelper colorFromHex:bot[@"PrimaryColor"]];
        cell.teamNameLabel.textColor = [DataHelper colorFromHex:bot[@"SecondaryColor"]];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Return bigger size for instructions
    if (indexPath.section == 0)
    {
        return 100.0;
    }
    return 85.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == botsSection)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *meLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20, headerView.frame.size.height)];
        meLabel.text = @"ME";
        meLabel.textAlignment = NSTextAlignmentLeft;
        meLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0];
        meLabel.textColor = [DataHelper colorFromHex:@"#616667"];
        [headerView addSubview:meLabel];
        
        UILabel *themLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20, headerView.frame.size.height)];
        themLabel.text = @"THEM";
        themLabel.textAlignment = NSTextAlignmentRight;
        themLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0];
        themLabel.textColor = [DataHelper colorFromHex:@"#616667"];
        [headerView addSubview:themLabel];
        
        return headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == botsSection)
    {
        return 25.0;
    }
    
    return 0.0;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Custom Methods

- (void)getData
{
    //Start progress indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Call data method for bots
    [helper getIntroBots:^{
        bots = helper.bots;
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)setViewStyles
{
    //Get Team Colors
    UIColor *primary = [DataHelper colorFromHex:helper.myTeam[@"PrimaryColor"]];
    UIColor *secondary = [DataHelper colorFromHex:helper.myTeam[@"SecondaryColor"]];
    
    //Navigation Bar Styles
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:secondary, NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20.0],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.barTintColor = primary;
    self.navigationController.navigationBar.tintColor = secondary;
    
    //Login Button Styles
    [loginButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0],NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    //TableView Styles
    [self.tableView setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
}

@end
