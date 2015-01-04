//
//  LogInTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 1/1/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"

@interface LogInTableViewController : UITableViewController <UITextFieldDelegate>
{
    //DataHelper Instance
    DataHelper *helper;
    
    //Login Button
    UIButton *loginButton;
    UIBarButtonItem *loginBarButton;
    
    //Interface Connections
    IBOutlet UIFloatLabelTextField *usernameField;
    IBOutlet UIFloatLabelTextField *passwordField;
    IBOutlet UIButton *recoverButton;
}

@end
