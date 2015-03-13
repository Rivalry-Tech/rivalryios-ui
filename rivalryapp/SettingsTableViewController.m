//
//  SettingsTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 1/3/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //DataHelper get instance
    helper = [DataHelper getInstance];
    
    //Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    oldTeam = helper.myTeam;
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
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 5;
    }
    else if (section == 1)
    {
        return 1;
    }
    
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 30.0;
    }
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 30.0;
    }
    
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:[tableView rectForHeaderInSection:1]];
        headerView.backgroundColor = tableView.backgroundColor;
        return headerView;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:[tableView rectForFooterInSection:1]];
        footerView.backgroundColor = tableView.backgroundColor;
        return footerView;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
    {
        TeamSelectTableViewController *controller = [[TeamSelectTableViewController alloc] init];
        controller.fromSettings = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        [helper logout:^(BOOL successful)
        {
            [self performSegueWithIdentifier:@"logoutSegue" sender:self];
        }];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Keyboard Methods

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
    [self.tableView scrollToRowAtIndexPath:editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

#pragma mark - UITextFieldDelegate Methods

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
    
    //Create Login Button
    saveButton = [[UIButton alloc] init];
    saveButton.frame = CGRectMake(0, 0, 68, 30);
    saveButton.backgroundColor = [secondary colorWithAlphaComponent:1.0];
    [saveButton setTitle:@"SAVE" forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0];
    [saveButton setTitleColor:primary forState:UIControlStateNormal];
    [saveButton setTitleColor:[primary colorWithAlphaComponent:1.0] forState:UIControlStateDisabled];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    saveButton.layer.cornerRadius = 3.0;
    saveButton.layer.masksToBounds = YES;
    saveButton.titleEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
    [saveButton addTarget:self action:@selector(saveClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Padding
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -10.0;
    
    //Add Login Button to Nav Bar
    saveBarButton = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    saveBarButton.enabled = YES;
    self.navigationItem.rightBarButtonItems = @[space, saveBarButton];
    
    //Create Cancel Button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //Get rid of extra lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    //Style floating label text fields
    usernameField.placeholder = @"USERNAME (< 16 char.)";
    passwordField.placeholder = @"CHANGE PASSWORD";
    emailField.placeholder = @"EMAIL";
    phoneField.placeholder = @"PHONE (optional)";
    teamField.placeholder = @"TEAM";
    usernameField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    passwordField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    emailField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    phoneField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    teamField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    usernameField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    passwordField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    emailField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    phoneField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    teamField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    usernameField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    passwordField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    emailField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    phoneField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    teamField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    usernameField.clearButtonMode = UITextFieldViewModeNever;
    passwordField.clearButtonMode = UITextFieldViewModeNever;
    emailField.clearButtonMode = UITextFieldViewModeNever;
    phoneField.clearButtonMode = UITextFieldViewModeNever;
    teamField.clearButtonMode = UITextFieldViewModeNever;
    PFUser *currentUser = [PFUser currentUser];
    usernameField.text = currentUser.username;
    emailField.text = currentUser.email;
    NSNumber *phone = (NSNumber *)currentUser[@"phone"];
    if (![phone integerValue] == 0)
    {
        NSMutableString *formatPhone = [[phone stringValue] mutableCopy];
        [formatPhone insertString:@"(" atIndex:0];
        [formatPhone insertString:@")" atIndex:4];
        [formatPhone insertString:@" " atIndex:5];
        [formatPhone insertString:@"-" atIndex:9];
        phoneField.text = formatPhone;
    }
    teamField.text = [helper.myTeam[@"name"] uppercaseString];
    passwordField.text = @"AAAAAAAAAAAA";
}

- (void)cancelClicked
{
    helper.myTeam = oldTeam;
    [self exitSettings];
}

- (void)exitSettings
{
    [self performSegueWithIdentifier:@"exitSettings" sender:self];
}

- (void)saveClicked
{
    NSString *username = usernameField.text;
    NSString *password = passwordField.text;
    NSString *email = emailField.text;
    NSString *phone = phoneField.text;
    
    NSCharacterSet *badCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    if ([username rangeOfCharacterFromSet:badCharacters].location != NSNotFound)
    {
        [UIAlertView showWithTitle:@"Error" message:@"Username cannot contain special characters." cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    if (username.length > 12)
    {
        [UIAlertView showWithTitle:@"Error" message:@"Please enter a username with 12 or less characters." cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    if (password.length < 6)
    {
        [UIAlertView showWithTitle:@"Error" message:@"Please enter a password with more than 6 characters" cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    NSCharacterSet *charactersToRemove = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *plainNumber = [[phone componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    if (plainNumber.length != 10 && plainNumber.length != 0)
    {
        [UIAlertView showWithTitle:@"Error" message:@"Please enter a valid phone number with area code and number" cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [helper updateProfile:username password:password email:email phone:plainNumber callback:^(BOOL successful)
    {
        if (successful)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Settings Saved!";
            [self performSelector:@selector(exitSettings) withObject:nil afterDelay:1.0];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

@end
