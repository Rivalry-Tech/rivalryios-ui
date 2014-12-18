//
//  TeamSelectTableViewCell.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "TeamSelectTableViewCell.h"

@implementation TeamSelectTableViewCell

@synthesize teamNameLabel;

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
        
        //Create Name Label
        teamNameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        teamNameLabel.textAlignment = NSTextAlignmentCenter;
        teamNameLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:30.0];
        
        //Add Label to Cell
        [self.contentView addSubview:teamNameLabel];
        
        //Add gradient to cell
        [self.layer insertSublayer:gradient atIndex:0];
        
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
    seperator.frame = CGRectMake(0, 84, self.bounds.size.width, 1);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
