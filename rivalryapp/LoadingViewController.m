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
        PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
        [teamQuery whereKey:@"objectId" equalTo:team.objectId];
        teamQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [teamQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            helper.myTeam = object;
//            UINavigationController *navController = self.navigationController;
//            UIViewController *start = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rivalry"];
//            [start.navigationItem setHidesBackButton:YES];
//            [navController pushViewController:start animated:NO];
            [self performSegueWithIdentifier:@"showRivalry" sender:self];
        }];
    }
    else
    {
        [self performSegueWithIdentifier:@"showStart" sender:self];
    }
}

@end
