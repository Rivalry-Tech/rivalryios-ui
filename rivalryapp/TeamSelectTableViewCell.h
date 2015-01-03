//
//  TeamSelectTableViewCell.h
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"

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
    
    //Flipping Properties
    NSTimer *timer;
    NSInteger timeLeft;
    BOOL flipped;
    UIView *flipView;
    UILabel *timerLabel;
    void (^flipCallback)();
}

//Interface Properties
@property (nonatomic, strong) UILabel *teamNameLabel;
@property (nonatomic, strong) UILabel *meLabel;
@property (nonatomic, strong) UILabel *themLabel;

//Flipping Properties
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSInteger timeLeft;
@property (nonatomic) BOOL flipped;

//Flip Timer Methods
- (void)flip:(void (^)())callback;
- (void)stopFlip;

@end
