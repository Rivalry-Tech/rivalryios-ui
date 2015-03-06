//
//  TeamSelectTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"
#import "TeamSelectTableViewCell.h"

@interface TeamSelectTableViewController : UITableViewController
{
    //Data Helper
    DataHelper *helper;
    
    //Interface Connections
    IBOutlet UIBarButtonItem *loginButton;
    
    //Data Source
    NSArray *teams;
    
    //Settings Page
    BOOL fromSettings;
    BOOL invalidTeam;
}

@property (nonatomic) BOOL fromSettings;
@property (nonatomic) BOOL invalidTeam;

@end
