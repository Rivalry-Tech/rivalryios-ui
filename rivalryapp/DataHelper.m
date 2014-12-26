//
//  DataHelper.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "DataHelper.h"

@implementation DataHelper

#pragma mark - Singleton Object Method

@synthesize teams, myTeam, bots;

static DataHelper *instance = nil;

+ (DataHelper *)getInstance
{
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [[DataHelper alloc] init];
        }
    }
    return instance;
}

#pragma mark - Data Methods

- (void)getTeams:(void (^)())callback
{
    //Create Query For the List of Teams
    PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
    [teamQuery orderByAscending:@"name"];
    
    //Cache the query
    if ([teamQuery hasCachedResult])
    {
        teamQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    else
    {
        teamQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    //Async call to Parse and return with callback
    [teamQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        teams = objects;
        callback();
    }];
}

- (void)getIntroBots:(void (^)())callback
{
    //Create Query to get the IntroBots from myTeam
    PFRelation *botsRelation = [myTeam relationForKey:@"introBots"];
    PFQuery *botsQuery = [botsRelation query];
    [botsQuery orderByAscending:@"name"];
    
    NSArray *myTeamArray = @[myTeam];
    
    //Async call to Parse and return with callback
    [botsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        bots = [myTeamArray arrayByAddingObjectsFromArray:objects];
        callback();
    }];
}

#pragma mark - Helper Methods

+ (UIColor *)colorFromHex:(NSString *)hexString
{
    if (hexString != nil && ![hexString isEqualToString:@""])
    {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        if ([hexString characterAtIndex:0] == '#')
        {
            [scanner setScanLocation:1];
        }
        [scanner scanHexInt:&rgbValue];
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    }
    else
    {
        return [UIColor whiteColor];
    }
}

@end
