//
//  TeamSelectTableViewCell.h
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamSelectTableViewCell : UITableViewCell
{
    //Interface Connections
    UILabel *teamNameLabel;
    UILabel *meLabel;
    UILabel *themLabel;
    
    //Cell Gradient
    CAGradientLayer *gradient;
    
    //Cell Seperator
    UIView *seperator;
}

//Interface Properties
@property (nonatomic, strong) UILabel *teamNameLabel;
@property (nonatomic, strong) UILabel *meLabel;
@property (nonatomic, strong) UILabel *themLabel;

@end
