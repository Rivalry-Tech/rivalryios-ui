//
//  SignUpTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 1/2/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"

@interface SignUpTableViewController : UITableViewController <UITextFieldDelegate>
{
    //DataHelper reference
    DataHelper *helper;
    
    //Signup Button
    UIButton *signupButton;
    UIBarButtonItem *signupBarButton;
    
    //Interface Connections
    IBOutlet UIFloatLabelTextField *usernameField;
    IBOutlet UIFloatLabelTextField *passwordField;
    IBOutlet UIFloatLabelTextField *emailField;
    IBOutlet UIFloatLabelTextField *phoneField;
    
    //Keyboard moving properties
    NSIndexPath *editingIndexPath;
    
    UITapGestureRecognizer *tap;
}

@end
