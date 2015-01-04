//
//  TeamSelectTableViewCell.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "TeamSelectTableViewCell.h"

@implementation TeamSelectTableViewCell

@synthesize teamNameLabel, meLabel, themLabel, timer, timeLeft, flipped;

#pragma mark - UITableViewCell Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //Init Properties
        timer = nil;
        timeLeft = 0;
        flipped = false;
        
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
        meLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 40, self.bounds.size.height)];
        meLabel.textAlignment = NSTextAlignmentCenter;
        meLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0];
        [self.contentView addSubview:meLabel];
        
        //Create Them Label
        themLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 45, 0, 40, self.bounds.size.height)];
        themLabel.textAlignment = NSTextAlignmentCenter;
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
    meLabel.frame = CGRectMake(5, 0, 40, self.bounds.size.height);
    themLabel.frame = CGRectMake(self.bounds.size.width - 45, 0, 40, self.bounds.size.height);
    seperator.frame = CGRectMake(0, 84, self.bounds.size.width, 1);
}

- (void)prepareForReuse
{
    [timer invalidate];
    timer = nil;
    timeLeft = 0;
    
    //Add layers back to original view
    [self.layer insertSublayer:gradient atIndex:0];
    [self.contentView addSubview:seperator];
    
    [UIView transitionFromView:flipView toView:self.contentView duration:0 options:UIViewAnimationOptionTransitionNone completion:^(BOOL finished) {
        flipped = false;
    }];
}

#pragma mark - Flip Timer Methods

- (void)stopFlip
{
    [timer invalidate];
    timer = nil;
    timeLeft = 0;
    
    //Add layers back to original view
    [self.layer insertSublayer:gradient atIndex:0];
    [self.contentView addSubview:seperator];
    
    [UIView transitionFromView:flipView toView:self.contentView duration:0 options:UIViewAnimationOptionTransitionNone completion:^(BOOL finished) {
        flipped = false;
    }];
}

- (void)flip:(void (^)())callback
{
    //Only flip if not flipped
    if (!flipped)
    {
        //Set cell flip properties
        flipped = true;
        timeLeft = 2;
        flipCallback = callback;
        
        //Create view to flip to
        [self createFlipView];
        
        //Create animation
        [UIView transitionFromView:self.contentView toView:flipView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished)
        {
            //Create timer
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
        }];
    }
}

- (void)tick
{
    //Decrement timer and update label
    timeLeft --;
    timerLabel.text = [DataHelper formatFlipTimer:timeLeft];
    
    //Check if timer is finished
    if (timeLeft == 0)
    {
        [timer invalidate];
        timer = nil;
        [self flipBack];
    }
}

- (void)flipBack
{
    //Add layers back to original view
    [self.layer insertSublayer:gradient atIndex:0];
    [self.contentView addSubview:seperator];
    
    //Animate View
    [UIView transitionFromView:flipView toView:self.contentView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
        flipped = false;
        flipCallback();
    }];
}

#pragma mark - Custom Methods

- (void)createFlipView
{
    //Get access to Data Helper
    DataHelper *helper = [DataHelper getInstance];
    
    //Create flip view
    flipView = [[UIView alloc] initWithFrame:self.contentView.frame];
    flipView.backgroundColor = [DataHelper colorFromHex:helper.myTeam[@"PrimaryColor"]];
    [flipView.layer insertSublayer:gradient atIndex:0];
    [flipView addSubview:seperator];
    
    //Get Team Callout
    NSString *callout = [helper.myTeam[@"callout"] uppercaseString];
    
    //Create callout label
    UILabel *calloutLabel = [[UILabel alloc] initWithFrame:self.bounds];
    calloutLabel.textAlignment = NSTextAlignmentCenter;
    calloutLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:30.0];
    calloutLabel.textColor = [DataHelper colorFromHex:helper.myTeam[@"SecondaryColor"]];
    calloutLabel.text = [NSString stringWithFormat:@"%@ SENT!", callout];
    [flipView addSubview:calloutLabel];
    
    //Create timer label
    timerLabel = [[UILabel alloc] init];
    NSInteger height = self.contentView.frame.size.height;
    timerLabel.frame = CGRectMake(0, height - 35, self.contentView.frame.size.width, 35);
    timerLabel.textAlignment = NSTextAlignmentCenter;
    timerLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14.0];
    timerLabel.textColor = [DataHelper colorFromHex:helper.myTeam[@"SecondaryColor"]];
    timerLabel.alpha = 0.5;
    timerLabel.text = [DataHelper formatFlipTimer:timeLeft];
    [flipView addSubview:timerLabel];
}

@end
