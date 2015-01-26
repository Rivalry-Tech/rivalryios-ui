//
//  InviteTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 1/23/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"
#import "TeamSelectTableViewCell.h"

@interface InviteTableViewController : UITableViewController <MFMessageComposeViewControllerDelegate>
{
    //DataHelper instance
    DataHelper *helper;
    
    //Data Source
    NSMutableDictionary *contacts;
    NSMutableArray *sendNumbers;
    NSArray *sortedContactKeys;
    
    //Send Button
    UIButton *sendButton;
    UIBarButtonItem *sendBarButton;
    
    //Message sender
    MFMessageComposeViewController *controller;
}

@end
