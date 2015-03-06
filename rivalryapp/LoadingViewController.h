//
//  LoadingViewController.h
//  rivalryapp
//
//  Created by Michael Bottone on 3/6/15.
//  Copyright (c) 2015 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataHelper.h"
#import "TeamSelectTableViewController.h"

@interface LoadingViewController : UIViewController
{
    DataHelper *helper;
    
    BOOL resetTeam;
}

@end
