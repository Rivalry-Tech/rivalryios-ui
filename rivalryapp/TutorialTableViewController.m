//
//  RivalryTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/18/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "TutorialTableViewController.h"

@interface TutorialTableViewController ()

@end

@implementation TutorialTableViewController

#pragma mark - UIViewController Methods

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
    
    //Setup Tutorial
    firstCalloutSent = helper.tutorialComplete;
    tutorialFinished = helper.tutorialComplete;
    
    //Register with Notification Center for tutorial completion
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTutorial) name:@"pushRegistered" object:nil];
    
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

#pragma mark - UITableView Data Source

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
        if (tutorialFinished)
        {
            return 2;
        }
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
        if (tutorialFinished)
        {
            if (indexPath.row == 0)
            {
                //Create instructions Cell
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"harassCell" forIndexPath:indexPath];
                return cell;
            }
            else
            {
                //Create recruit Cell
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recruitCell" forIndexPath:indexPath];
                return cell;
            }
        }
        else
        {
            //Create instructions Cell
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCell" forIndexPath:indexPath];
            return cell;
        }
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
        
        cell.meLabel.text = @"0";
        cell.themLabel.text = @"0";
        cell.meLabel.textColor = [DataHelper colorFromHex:bot[@"SecondaryColor"]];
        cell.themLabel.textColor = [DataHelper colorFromHex:bot[@"SecondaryColor"]];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == botsSection)
    {
        //Create Header View
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:botsSection]];
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
    else if (section == instructionsSection)
    {
        if (tutorialFinished)
        {
            //Create header for signup button
            UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:instructionsSection]];
            headerView.backgroundColor = [UIColor clearColor];
            
            return headerView;
        }
        else
        {
            //Padding for instructions
            UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:instructionsSection]];
            headerView.backgroundColor = [UIColor clearColor];
        
            return headerView;
        }
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //Padding for signup button
    if (section == instructionsSection && tutorialFinished)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:instructionsSection]];
        footerView.backgroundColor = [UIColor clearColor];
        
        return footerView;
    }
    else if (section == botsSection)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:instructionsSection]];
        footerView.backgroundColor = [UIColor clearColor];
        
        return footerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //Headers and padding
    if (section == botsSection)
    {
        return 30.0;
    }
    else if (section == instructionsSection)
    {
        if (tutorialFinished)
        {
            return 30.0;
        }
        return 10.0;
    }
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //Padding for sign up button
    if (section == instructionsSection && tutorialFinished)
    {
        return 20.0;
    }
    else if (section == botsSection)
    {
        return 20.0;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Return bigger size for instructions
    if (indexPath.section == instructionsSection && !tutorialFinished)
    {
        return 100.0;
    }
    else if (indexPath.section == instructionsSection && tutorialFinished && indexPath.row == 0)
    {
        return 30.0;
    }
    return 85.0;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == botsSection)
   {
       //Get Selected cell and flip it
       TeamSelectTableViewCell *selectedCell = (TeamSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
       [selectedCell flip:^{
           PFObject *bot = [bots objectAtIndex:indexPath.row];
           //If this is the first callout, start the tutorial
           if (!firstCalloutSent)
           {
               firstCalloutSent = YES;
               [self performSelector:@selector(notificaitonTutorial:) withObject:bot afterDelay:1.0];
           }
           [self sendBotCallout:bot];
       }];
   }
   else if (indexPath.section == instructionsSection)
   {
       if (tutorialFinished)
       {
           dispatch_async(dispatch_get_main_queue(), ^
           {
               [self performSegueWithIdentifier:@"showSignUp" sender:self];
           });
       }
   }
}

- (void)sendBotCallout:(PFObject *)bot
{
    UILocalNotification *botCallout = [[UILocalNotification alloc] init];
    botCallout.alertBody = bot[@"callout"];
    botCallout.fireDate = [NSDate date];
    botCallout.soundName = bot[@"audioFile"];
    [[UIApplication sharedApplication] scheduleLocalNotification: botCallout];
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
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    //Set status bar style
    if (helper.myTeam[@"lightStatus"] == [NSNumber numberWithBool:YES])
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}

- (void)notificaitonTutorial:(PFObject *)bot
{
    //Get Bot data
    NSString *botName = [bot[@"name"] uppercaseString];
    NSString *callout = bot[@"callout"];
    
    //Show recieving alert and register for notificaitons
    [UIAlertView showWithTitle:@"Recieving..." message:[NSString stringWithFormat:@"%@ BOT is trying to send you %@!\nEnable notifications on the next screen to recieve callouts from your friends!", botName, callout] cancelButtonTitle:@"Okay!" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [DataHelper registerNotificaitons];
        [self sendBotCallout:bot];
    }];
}

- (void)finishTutorial
{
   if (!tutorialFinished)
   {
       //Finish tutoiral and show sign up button
       tutorialFinished = YES;
       helper.tutorialComplete = YES;
       [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:instructionsSection] withRowAnimation:UITableViewRowAnimationFade];
   }
}

#pragma mark - Unwind Segues

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)unwindFromSignup:(UIStoryboardSegue *)segue
{
    
}

@end
