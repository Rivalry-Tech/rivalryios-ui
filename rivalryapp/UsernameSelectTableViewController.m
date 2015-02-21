//
//  UsernameSelectTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 2/19/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "UsernameSelectTableViewController.h"

@interface UsernameSelectTableViewController ()

@end

@implementation UsernameSelectTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    helper = [DataHelper getInstance];
    
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"emailCell"];
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"facebookCell"];
    [self.tableView registerClass:[TeamSelectTableViewCell class] forCellReuseIdentifier:@"twitterCell"];
    
    usernameField = [[UITextField alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setViewStyles];
    
    viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    viewTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:viewTap];
    barTap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    barTap.cancelsTouchesInView = NO;
    [self.navigationController.navigationBar addGestureRecognizer:barTap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:viewTap];
    [self.navigationController.navigationBar removeGestureRecognizer:barTap];
}

#pragma mark - Table view data source

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
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usernameCell" forIndexPath:indexPath];
        usernameField.frame = CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y + 10, cell.frame.size.width - 20, cell.frame.size.height - 20);
        [cell addSubview:usernameField];
        return cell;
    }
    else if (indexPath.row == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gapCell" forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 2)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emailCell" forIndexPath:indexPath];
        
        cell.teamNameLabel.text = @"EMAIL";
        cell.backgroundColor = [DataHelper colorFromHex:@"#353535"];
        cell.teamNameLabel.textColor = [UIColor whiteColor];
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else if (indexPath.row == 3)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"facebookCell" forIndexPath:indexPath];
        
        cell.teamNameLabel.text = @"FACEBOOK";
        cell.backgroundColor = [DataHelper colorFromHex:@"#3B5998"];
        cell.teamNameLabel.textColor = [UIColor whiteColor];
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else if (indexPath.row == 4)
    {
        TeamSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"twitterCell" forIndexPath:indexPath];
        
        cell.teamNameLabel.text = @"TWITTER";
        cell.backgroundColor = [DataHelper colorFromHex:@"#55ACEE"];
        cell.teamNameLabel.textColor = [UIColor whiteColor];
        cell.meLabel.text = @"";
        cell.themLabel.text = @"";
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usernameCell" forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {
        return 60.0;
    }
    return 85.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [helper checkUsername:usernameField.text callback:^(BOOL successful)
    {
        if (successful)
        {
            if (indexPath.row == 2)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self performSegueWithIdentifier:@"showEmailSignUp" sender:self];
                });
            }
            else if (indexPath.row == 3)
            {
                [helper loginWithFacebook:^(BOOL successful, BOOL newUser) {
                    if (successful)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [self performSegueWithIdentifier:@"signupToRecruit" sender:self];
                        });
                    }
                }];
            }
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Custom Methods

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
    
    //Create Cancel Button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //Get rid of extra lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: [DataHelper colorFromHex:@"#5C5C5C"]}];
    usernameField.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:30.0];
    usernameField.textColor = [UIColor whiteColor];
    usernameField.clearButtonMode = UITextFieldViewModeNever;
    usernameField.textAlignment = NSTextAlignmentCenter;
    usernameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    usernameField.spellCheckingType = UITextSpellCheckingTypeNo;
    usernameField.returnKeyType = UIReturnKeyDone;
    usernameField.enablesReturnKeyAutomatically = YES;
    usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    usernameField.delegate = self;
}

- (void)cancelClicked
{
    [self performSegueWithIdentifier:@"cancelSignup" sender:self];
}

@end
