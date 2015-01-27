//
//  RivalryTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 1/3/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"
#import "TeamSelectTableViewCell.h"

@interface RivalryTableViewController : UITableViewController
{
    //DataHelper instance
    DataHelper *helper;
    
    //Data Source
    NSArray *friends;
    
    //Section info
    NSInteger numOfSections;
    NSInteger recruitSection;
    NSInteger friendsSection;
    
}

@end
