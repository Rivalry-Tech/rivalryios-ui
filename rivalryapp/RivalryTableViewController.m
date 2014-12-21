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
    
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated
{
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCell" forIndexPath:indexPath];
        
        return cell;
    }
    else if (indexPath.section == botsSection)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCell" forIndexPath:indexPath];
        
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
    if (indexPath.section == 0)
    {
        return 100.0;
    }
    return 85.0;
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
