//
//  TeamSelectTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "TeamSelectTableViewController.h"

@interface TeamSelectTableViewController ()

@end

@implementation TeamSelectTableViewController

@synthesize fromSettings, invalidTeam;

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init DataHelper
    helper = [DataHelper getInstance];
    
    //Set UITableViewCell class
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"teamCell"];
    
    helper.tutorialComplete = NO;
    
    self.title = @"PICK YOUR TEAM";
    
    if (helper.invalidTeam)
    {
        invalidTeam = true;
    }
    
    if (fromSettings || invalidTeam)
    {
        self.title = @"PICK NEW TEAM";
    }
    
    //Get Data for Table
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
    //Only one section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of teams
    return [teams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create cell
    TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teamCell" forIndexPath:indexPath];
    
    //Get Team for Row
    PFObject *team = [teams objectAtIndex:indexPath.row];
    
    //Add Team Name to Cell
    NSString *teamName = team[@"name"];
    cell.teamNameLabel.text = [teamName uppercaseString];
    
    //Set Cell Styles
    cell.backgroundColor = [DataHelper colorFromHex:team[@"PrimaryColor"]];
    cell.teamNameLabel.textColor = [DataHelper colorFromHex:team[@"SecondaryColor"]];
    
    //Don't need the score labels yet
    cell.meLabel.text = @"";
    cell.themLabel.text = @"";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

#pragma mark - UITableViewController Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (fromSettings)
    {
        if (invalidTeam)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [helper updateTeam:[teams objectAtIndex:indexPath.row] callback:^(BOOL successful)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self.navigationController popViewControllerAnimated:YES];
             }];
        }
        else
        {
            helper.myTeam = [teams objectAtIndex:indexPath.row];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (invalidTeam)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [helper updateTeam:[teams objectAtIndex:indexPath.row] callback:^(BOOL successful)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self performSegueWithIdentifier:@"skipTutorial" sender:self];
        }];
    }
    else
    {
        //Custom call to segue from custom UITableViewCell
        helper.myTeam = [teams objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"skipToSignup" sender:self];
    }
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
    //Start progress indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Call data method for intro bots
    [helper getTeams:^(BOOL successful) {
        teams = helper.teams;
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)setViewStyles
{
    //Navigation Bar Styles
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20.0],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [DataHelper colorFromHex:@"#0099FF"];
    
    if (!fromSettings && !invalidTeam)
    {
        //Login Button Styles
        [loginButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0],NSFontAttributeName, nil] forState:UIControlStateNormal];
        loginButton.tintColor = [DataHelper colorFromHex:@"#0099FF"];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    //Set status bar to black
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 85.0;
    
    if (!fromSettings && !invalidTeam)
    {
        helper.myTeam = nil;
    }
    
    if (!fromSettings && invalidTeam)
    {
        [self.navigationItem setHidesBackButton:true];
    }
}

#pragma mark - Unwind Segues

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)segue
{
    
}

@end
