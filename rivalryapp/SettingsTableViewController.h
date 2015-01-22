//
//  SettingsTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 1/3/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"
#import "TeamSelectTableViewController.h"

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate>
{
    //DataHelper instance
    DataHelper *helper;
    
    //Interface connections
    IBOutlet UIFloatLabelTextField *usernameField;
    IBOutlet UIFloatLabelTextField *passwordField;
    IBOutlet UIFloatLabelTextField *emailField;
    IBOutlet UIFloatLabelTextField *phoneField;
    IBOutlet UIFloatLabelTextField *teamField;
    
    //Save Button
    UIBarButtonItem *saveBarButton;
    UIButton *saveButton;
    
    //Keyboard moving properties
    NSIndexPath *editingIndexPath;
}

@end
