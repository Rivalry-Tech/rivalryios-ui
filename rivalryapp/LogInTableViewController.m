//
//  LogInTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 1/1/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "LogInTableViewController.h"

@interface LogInTableViewController ()

@end

@implementation LogInTableViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get DataHelper instance
    helper = [DataHelper getInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Set all of the view styles
    [self setViewStyles];
    
    viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    viewTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:viewTap];
    barTap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    barTap.cancelsTouchesInView = NO;
    [self.navigationController.navigationBar addGestureRecognizer:barTap];
    
    [self checkLoginButton:@""];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:viewTap];
    [self.navigationController.navigationBar removeGestureRecognizer:barTap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        TeamSelectTableViewCell *cell = [[TeamSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"facebookCell"];
        
        cell.teamNameLabel.text = @"FACEBOOK";
        cell.backgroundColor = [DataHelper colorFromHex:@"#3B5998"];
        cell.teamNameLabel.textColor = [UIColor whiteColor];
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else if (indexPath.row == 4)
    {
        TeamSelectTableViewCell *cell = [[TeamSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"twitterCell"];
        
        cell.teamNameLabel.text = @"TWITTER";
        cell.backgroundColor = [DataHelper colorFromHex:@"#55ACEE"];
        cell.teamNameLabel.textColor = [UIColor whiteColor];
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self facebookLogin];
        });
    }
    else if (indexPath.row == 4)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self twitterLogin];
        });
    }
}

- (void)facebookLogin
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [helper loginWithFacebook:^(BOOL successful, BOOL newUser)
    {
        if (successful)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Login Successful!";
            
            if (newUser)
            {
                [UIAlertView showWithTitle:@"ERROR" message:@"Your user account doesn't have a team associated with it. Please pick one now." cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
                helper.invalidTeam = true;
                [self performSegueWithIdentifier:@"needTeam" sender:self];
            }
            else
            {
                [self performSelector:@selector(finishLogin) withObject:nil afterDelay:1.0];
            }
        }
        [hud hide:YES afterDelay:1.0];
     }];
}

- (void)twitterLogin
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [helper loginWithTwitter:^(BOOL successful, BOOL newUser)
    {
        if (successful)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Login Successful!";
            
            if (newUser)
            {
                [UIAlertView showWithTitle:@"ERROR" message:@"Your user account doesn't have a team associated with it. Please pick one now." cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
                TeamSelectTableViewController *controller = [[TeamSelectTableViewController alloc] init];
                controller.invalidTeam = true;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                [self performSelector:@selector(finishLogin) withObject:nil afterDelay:1.0];
            }
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

- (void)directToTutorial
{
    //TODO
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //Get next textfield in the order
    if (textField.tag == 1)
    {
        [passwordField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self loginClicked];
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self checkLoginButton:string];
    
    return YES;
}

- (void)checkLoginButton:(NSString *)string
{
    NSInteger dir = ([string isEqualToString:@""] ? -1 : 1);
    
    //Get the lengths of the text field inputs
    NSInteger uLength = usernameField.text.length + (usernameField.isEditing ? 1 : 0) * dir;
    NSInteger pLength = passwordField.text.length + (passwordField.isEditing ? 1 : 0) * dir;
    
    //If both are greater than zero, enable login button
    if (uLength > 0 && pLength > 0)
    {
        [self enableLogin];
    }
    else
    {
        [self disableLogin];
    }
}

#pragma mark - Custom Methods

- (void)setViewStyles
{
    UIColor *primary, *secondary;
    BOOL defaultTint = NO;
    UIColor *defaultColor = [DataHelper colorFromHex:@"#0099FF"];
    
    //If a team has been selected
    if (helper.myTeam == nil)
    {
        //Default Colors
        primary = [UIColor whiteColor];
        secondary = [UIColor blackColor];
        defaultTint = YES;
    }
    else
    {
        //Get Team Colors
        primary = [DataHelper colorFromHex:helper.myTeam[@"PrimaryColor"]];
        secondary = [DataHelper colorFromHex:helper.myTeam[@"SecondaryColor"]];
        
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
    
    //Navigation Bar Styles
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:secondary, NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20.0],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.barTintColor = primary;
    self.navigationController.navigationBar.tintColor = secondary;
    
    //Create Login Button
    loginButton = [[UIButton alloc] init];
    loginButton.frame = CGRectMake(0, 0, 68, 30);
    if (defaultTint)
    {
        loginButton.backgroundColor = [defaultColor colorWithAlphaComponent:0.5];
    }
    else
    {
        loginButton.backgroundColor = [secondary colorWithAlphaComponent:0.5];
    }
    [loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0];
    [loginButton setTitleColor:primary forState:UIControlStateNormal];
    [loginButton setTitleColor:[primary colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButton.layer.cornerRadius = 3.0;
    loginButton.layer.masksToBounds = YES;
    loginButton.titleEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
    [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Padding
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -10.0;
    
    //Add Login Button to Nav Bar
    loginBarButton = [[UIBarButtonItem alloc] initWithCustomView:loginButton];
    loginBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[space, loginBarButton];
    
    //Create Cancel Button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //Get rid of extra lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    recoverButton.imageView.image = [recoverButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    recoverButton.imageView.tintColor = [UIColor whiteColor];
    
    //Style floating label text fields
    usernameField.placeholder = @"USERNAME";
    passwordField.placeholder = @"PASSWORD";
    usernameField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    passwordField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    usernameField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    passwordField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    usernameField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    passwordField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    usernameField.clearButtonMode = UITextFieldViewModeNever;
    passwordField.clearButtonMode = UITextFieldViewModeNever;
    
    //Create generic gradient
    UIColor *clear = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    UIColor *shade = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)clear.CGColor, (id)shade.CGColor, nil];
    
    NSNumber *stop1 = [NSNumber numberWithFloat:0.0];
    NSNumber *stop2 = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stop1, stop2, nil];
    
    gradient = [CAGradientLayer layer];
    gradient.frame = facebookCell.bounds;
    gradient.colors = colors;
    gradient.locations = locations;
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(0.5, 1);
}

- (void)cancelClicked
{
    //Return to place that called login
    [self performSegueWithIdentifier:@"exitLogin" sender:self];
}

- (void)loginClicked
{
    //End all editing
    [self.tableView endEditing:YES];
    
    //Log In
    NSString *username = usernameField.text;
    NSString *password = passwordField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [helper login:username password:password callback:^(BOOL successful, BOOL resetTeam)
    {
        if (successful)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Login Successful!";
            [self performSelector:@selector(finishLogin) withObject:nil afterDelay:1.0];
        }
        if (resetTeam)
        {
            TeamSelectTableViewController *controller = [[TeamSelectTableViewController alloc] init];
            controller.fromSettings = YES;
            controller.invalidTeam = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

- (void)finishLogin
{
    [DataHelper registerNotificaitons:NO];
    [self performSegueWithIdentifier:@"loginToFriends" sender:self];
}

- (void)enableLogin
{
    //Enable Login Button
    loginBarButton.enabled = YES;
    loginButton.backgroundColor = [loginButton.backgroundColor colorWithAlphaComponent:1.0];
}

- (void)disableLogin
{
    //Disable Login Button
    loginBarButton.enabled = NO;
    loginButton.backgroundColor = [loginButton.backgroundColor colorWithAlphaComponent:0.5];
}

- (IBAction)forgotPasswordClicked:(id)sender
{
    [self.view endEditing:YES];
    [helper forgotPassword:^(BOOL successful) {
        if (successful)
        {
            [UIAlertView showWithTitle:@"Password Reset Sent!" message:@"You should receive an email shortly with instructions on how to reset your password." cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
        }
    }];
}

#pragma mark - Unwind Segues

- (IBAction)unwindFromLogout:(UIStoryboardSegue *)segue
{
    
}

@end
