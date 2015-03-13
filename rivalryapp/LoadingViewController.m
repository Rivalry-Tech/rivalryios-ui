//
//  LoadingViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 3/6/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    helper = [DataHelper getInstance];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *dst = [segue destinationViewController];
    [dst.navigationItem setHidesBackButton:YES];
    if (resetTeam)
    {
        TeamSelectTableViewController *cont = (TeamSelectTableViewController *)dst;
        cont.invalidTeam = YES;
    }
}


- (void)setViewStyles
{
    //Navigation Bar Styles
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20.0],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [DataHelper colorFromHex:@"#0099FF"];
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    //Set status bar to black
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)getData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFUser *currentUser = [PFUser currentUser];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentUser)
    {
        currentInstallation[@"user"] = currentUser;
        [currentInstallation saveInBackground];
        
        PFObject *team = currentUser[@"primaryTeam"];
        if (team == nil)
        {
            [UIAlertView showWithTitle:@"ERROR" message:@"Your user account doesn't have a team associated with it. Please pick one now." cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
            resetTeam = YES;
            [self performSegueWithIdentifier:@"showStart" sender:self];
            return;
        }
        PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
        [teamQuery whereKey:@"objectId" equalTo:team.objectId];
        teamQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [teamQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
        {
            if (object)
            {
                helper.myTeam = object;
                [self performSegueWithIdentifier:@"showRivalry" sender:self];
            }
            else
            {
                [UIAlertView showWithTitle:@"ERROR" message:@"The your current team no longer exists in our system. Please select a new team." cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
                resetTeam = YES;
                [self performSegueWithIdentifier:@"showStart" sender:self];
            }
        }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self performSegueWithIdentifier:@"showStart" sender:self];
        });
        
    }
}

- (IBAction)unwindFromLogout:(UIStoryboardSegue *)segue
{
    helper = [DataHelper getInstance];
    [self getData];
}

@end
