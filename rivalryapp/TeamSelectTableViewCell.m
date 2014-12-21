//
//  TeamSelectTableViewCell.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "TeamSelectTableViewCell.h"

@implementation TeamSelectTableViewCell

@synthesize teamNameLabel, meLabel, themLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //Create generic gradient
        UIColor *clear = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        UIColor *shade = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        
        NSArray *colors = [NSArray arrayWithObjects:(id)clear.CGColor, (id)shade.CGColor, nil];
        
        NSNumber *stop1 = [NSNumber numberWithFloat:0.0];
        NSNumber *stop2 = [NSNumber numberWithFloat:1.0];
        
        NSArray *locations = [NSArray arrayWithObjects:stop1, stop2, nil];
        
        gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = colors;
        gradient.locations = locations;
        gradient.startPoint = CGPointMake(0.5, 0);
        gradient.endPoint = CGPointMake(0.5, 1);
        
        [self.layer insertSublayer:gradient atIndex:0];
        
        //Create Name Label
        teamNameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        teamNameLabel.textAlignment = NSTextAlignmentCenter;
        teamNameLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:30.0];
        [self.contentView addSubview:teamNameLabel];
        
        //Create Me Label
        meLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height)];
        meLabel.textAlignment = NSTextAlignmentLeft;
        meLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0];
        [self.contentView addSubview:meLabel];
        
        //Create Them Label
        themLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height)];
        themLabel.textAlignment = NSTextAlignmentRight;
        themLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0];
        [self.contentView addSubview:themLabel];
        
        //Create seperators
        seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 84, self.bounds.size.width, 1)];
        seperator.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:seperator];
        
        //Selection Style
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //Set frames if layout changes
    gradient.frame = self.bounds;
    teamNameLabel.frame = self.bounds;
    meLabel.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
    themLabel.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
    seperator.frame = CGRectMake(0, 84, self.bounds.size.width, 1);
}

@end
