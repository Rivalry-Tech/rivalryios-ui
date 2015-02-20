//
//  SignUpTableViewController.m
//  rivalryapp
//
//  Created by Michael Bottone on 1/2/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import "SignUpTableViewController.h"

@interface SignUpTableViewController ()

@end

@implementation SignUpTableViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get DataHelper instance
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

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
    else if (textField.tag == 2)
    {
        [phoneField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self signupClicked];
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger dir = ([string isEqualToString:@""] ? -1 : 1);
    
    //Get the lengths of the text field inputs
    NSInteger pLength = passwordField.text.length + (passwordField.isEditing ? 1 : 0) * dir;
    NSInteger eLength = emailField.text.length + (emailField.isEditing ? 1 : 0) * dir;
    
    //If all are greater than zero, enable login button
    if (pLength > 0 && eLength > 0)
    {
        [self enableSignup];
    }
    else
    {
        [self disableSignup];
    }
    
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
    signupButton = [[UIButton alloc] init];
    signupButton.frame = CGRectMake(0, 0, 68, 30);
    signupButton.backgroundColor = [secondary colorWithAlphaComponent:0.5];
    [signupButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
    signupButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0];
    [signupButton setTitleColor:primary forState:UIControlStateNormal];
    [signupButton setTitleColor:[primary colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    signupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signupButton.layer.cornerRadius = 3.0;
    signupButton.layer.masksToBounds = YES;
    signupButton.titleEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
    [signupButton addTarget:self action:@selector(signupClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Padding
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -10.0;
    
    //Add Login Button to Nav Bar
    signupBarButton = [[UIBarButtonItem alloc] initWithCustomView:signupButton];
    signupBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[space, signupBarButton];
    
    //Create Cancel Button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //Get rid of extra lines
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Make bar opaque to preserve colors
    self.navigationController.navigationBar.translucent = NO;
    
    //Style floating label text fields
    passwordField.placeholder = @"PASSWORD";
    emailField.placeholder = @"EMAIL";
    phoneField.placeholder = @"PHONE (optional)";
    passwordField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    emailField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    phoneField.floatLabelActiveColor = [DataHelper colorFromHex:@"#0098FF"];
    passwordField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    emailField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    phoneField.floatLabelPassiveColor = [DataHelper colorFromHex:@"#5C5C5C"];
    passwordField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    emailField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    phoneField.floatLabelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    passwordField.clearButtonMode = UITextFieldViewModeNever;
    emailField.clearButtonMode = UITextFieldViewModeNever;
    phoneField.clearButtonMode = UITextFieldViewModeNever;
}

- (void)cancelClicked
{
    [self performSegueWithIdentifier:@"cancelSignup" sender:self];
}

- (void)signupClicked
{
    NSString *username = helper.usernameStorage;
    NSString *email = emailField.text;
    NSString *password = passwordField.text;
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [helper signup:username password:password email:email phone:plainNumber callback:^(BOOL successful)
    {
        if (successful)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Signup Successful!";
            [self performSelector:@selector(finishSignup) withObject:nil afterDelay:1.0];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

- (void)finishSignup
{
    [self performSegueWithIdentifier:@"signupToFriends" sender:self];
}

- (void)enableSignup
{
    //Enable Signup Button
    signupBarButton.enabled = YES;
    signupButton.backgroundColor = [signupButton.backgroundColor colorWithAlphaComponent:1.0];
}

- (void)disableSignup
{
    //Disable Signup Button
    signupBarButton.enabled = NO;
    signupButton.backgroundColor = [signupButton.backgroundColor colorWithAlphaComponent:0.5];
}

@end
