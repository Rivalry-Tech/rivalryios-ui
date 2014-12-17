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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init DataHelper
    helper = [DataHelper getInstance];
    
    //Navigation Bar Styles
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20.0],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    //Login Button Styles
    [loginButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0],NSFontAttributeName, nil] forState:UIControlStateNormal];
    loginButton.tintColor = [DataHelper colorFromHex:@"#0099FF"];
    
    //Set UITableViewCell class
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"teamCell"];
    
    //Fetch Team Data
    PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
    [teamQuery orderByAscending:@"name"];
    teams = [teamQuery findObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [teams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teamCell" forIndexPath:indexPath];
    
    //Get Team for Row
    PFObject *team = [teams objectAtIndex:indexPath.row];
    
    //Add Team Name to Cell
    NSString *teamName = team[@"name"];
    cell.teamNameLabel.text = [teamName uppercaseString];
    
    //Set Cell Styles
    cell.backgroundColor = [DataHelper colorFromHex:team[@"PrimaryColor"]];
    cell.teamNameLabel.textColor = [DataHelper colorFromHex:team[@"SecondaryColor"]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
