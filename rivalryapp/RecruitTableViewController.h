//
//  RecruitTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 1/12/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"
#import "TeamSelectTableViewCell.h"

@interface RecruitTableViewController : UITableViewController
{
    //DataHelper instance
    DataHelper *helper;
    
    //Save Button
    UIBarButtonItem *doneBarButton;
    UIButton *doneButton;
    
    //Interface Properties
    UITextField *searchField;
    
    //Section Numbers
    NSInteger numOfSections;
    NSInteger searchSection;
    NSInteger requestSection;
    NSInteger contactsSection;
    NSInteger inviteSection;
    NSInteger socialSection;
    
    //Data Source
    NSArray *contactFriends;
    NSArray *friendRequests;
    
    //Data Timing
    BOOL contactsDone;
    BOOL requestsDone;
}

@end
