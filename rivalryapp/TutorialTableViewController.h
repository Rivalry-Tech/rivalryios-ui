//
//  RivalryTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 12/18/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"
#import "TeamSelectTableViewCell.h"

@interface TutorialTableViewController : UITableViewController
{
    //Data Helper
    DataHelper *helper;
    
    //Interface Connections
    IBOutlet UIBarButtonItem *loginButton;
    
    //Data Source
    NSArray *bots;
    NSMutableArray *botCounts;
    
    //Section Numbers
    NSInteger numberOfSections;
    NSInteger instructionsSection;
    NSInteger botsSection;
    
    //Tutorial Properties
    BOOL firstCalloutSent;
    BOOL tutorialFinished;
    PFObject *registerBot;
}

@end
