//
//  InviteTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 1/23/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "InviteTableViewController.h"

@interface InviteTableViewController ()

@end

@implementation InviteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Get DataHelper instance
    helper = [DataHelper getInstance];
    
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"contactCell"];
    
    sendNumbers = [[NSMutableArray alloc] initWithObjects:nil];
    
    controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        PFUser *currentUser = [PFUser currentUser];
        PFObject *myTeam = helper.myTeam;
        NSString *rawMessage = [NSString stringWithFormat:@"I'm using the Rivalry! app to say %@ to my friends.  Check it out and add me as %@!  You can download it here: http://www.rivalryapp.com", myTeam[@"callout"], currentUser.username];
        controller.body = rawMessage;
        controller.subject = @"Join me on Rivalry!";
        controller.messageComposeDelegate = self;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    //Get Team for Row
    NSString *plainNumber = [sortedContactKeys objectAtIndex:indexPath.row];
    NSString *name = [contacts objectForKey:plainNumber];
    
    //Add Team Name to Cell
    cell.teamNameLabel.text = [name uppercaseString];
    if ([sendNumbers containsObject:plainNumber])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    //Set Cell Styles
    cell.backgroundColor = [DataHelper colorFromHex:@"#262A2C"];
    cell.teamNameLabel.textColor = [UIColor whiteColor];
    
    cell.meLabel.text = @"";
    cell.themLabel.text = @"";
    
    cell.tintColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamSelectTableViewCell *cell = (TeamSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [sendNumbers addObject:[sortedContactKeys objectAtIndex:indexPath.row]];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [sendNumbers removeObject:[sortedContactKeys objectAtIndex:indexPath.row]];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Custom Methods

- (void)getData
{
    contacts = [[NSMutableDictionary alloc] initWithDictionary:helper.contactData];
    sortedContactKeys = [contacts keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        NSString *name1 = (NSString *)obj1;
        NSString *name2 = (NSString *)obj2;
        return [name1 compare:name2];
    }];
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
    sendButton = [[UIButton alloc] init];
    sendButton.frame = CGRectMake(0, 0, 68, 30);
    sendButton.backgroundColor = [secondary colorWithAlphaComponent:1.0];
    [sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0];
    [sendButton setTitleColor:primary forState:UIControlStateNormal];
    [sendButton setTitleColor:[primary colorWithAlphaComponent:1.0] forState:UIControlStateDisabled];
    sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    sendButton.layer.cornerRadius = 3.0;
    sendButton.layer.masksToBounds = YES;
    [sendButton addTarget:self action:@selector(sendClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Padding
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -10.0;
    
    //Add Done Button to Nav Bar
    sendBarButton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    sendBarButton.enabled = YES;
    self.navigationItem.rightBarButtonItems = @[space, sendBarButton];
    
    //Get rid of extra lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)sendClicked
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if([MFMessageComposeViewController canSendText])
        {
            controller.recipients = sendNumbers;
            [self presentViewController:controller animated:YES completion:^{
                //Presenting Done
            }];
        }
    });
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invite Sent!" message:@"Get ready to show your spirit to all of your friends!" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alert show];
        }];
    }
    else if (result == MessageComposeResultCancelled)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            //Dismiss finished
        }];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem sending the message. Try again later" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

@end
