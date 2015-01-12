//
//  RecruitTableViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 1/12/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"

@interface RecruitTableViewController : UITableViewController
{
    //DataHelper instance
    DataHelper *helper;
    
    //Save Button
    UIBarButtonItem *doneBarButton;
    UIButton *doneButton;
}

@end
