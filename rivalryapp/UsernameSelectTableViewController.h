//
//  UsernameSelectTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 2/19/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataHelper.h"
#import "TeamSelectTableViewCell.h"

@interface UsernameSelectTableViewController : UITableViewController <UITextFieldDelegate>
{
    //DataHelper instance
    DataHelper *helper;
    
    UITapGestureRecognizer *viewTap;
    UITapGestureRecognizer *barTap;
    
    UITextField *usernameField;
    
    IBOutlet UIBarButtonItem *loginButton;
}

@end
