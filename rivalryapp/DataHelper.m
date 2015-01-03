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

@synthesize teams, myTeam, bots, tutorialComplete;

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

- (void)login:(NSString *)username password:(NSString *)password callback:(void (^)())callback
{
    //Login through Parse
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if (user)
        {
            callback();
        }
    }];
}

- (void)signup:(NSString *)username password:(NSString *)password email:(NSString *)email phone:(NSString *)phone callback:(void (^)())callback
{
    //Create new user
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email = email;
    newUser[@"phone"] = [NSNumber numberWithLongLong:[phone longLongValue]];
    newUser[@"messageCounter"] = @{};
    newUser[@"primaryTeam"] = myTeam;
    
    //Signup new user with Parse
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            callback();
        }
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

+ (NSString *)formatFlipTimer:(NSInteger)timeLeft
{
    //Format minutes
    float minutes = timeLeft / 60;
    NSString *minutesString = [NSString stringWithFormat:@"%02d", (int)floorf(minutes)];
    
    //Format seconds
    int seconds = timeLeft % 60;
    NSString *secondsString = [NSString stringWithFormat:@"%02d", seconds];
    
    //Return timer
    return [NSString stringWithFormat:@"%@:%@", minutesString, secondsString];
}

+ (void)registerNotificaitons
{
    UIApplication *application = [UIApplication sharedApplication];
    
    //Register for push notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) //Version > iOS 8.0
    {
        //Types to register
        UIUserNotificationType types = (UIUserNotificationTypeAlert |
                                        UIUserNotificationTypeBadge |
                                        UIUserNotificationTypeSound);
        
        //Create accept and decline actions for friend requests
        UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
        acceptAction.identifier = @"ACCEPT_IDENTIFIER";
        acceptAction.title = @"Accept";
        acceptAction.activationMode = UIUserNotificationActivationModeBackground;
        acceptAction.destructive = NO;
        acceptAction.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
        declineAction.identifier = @"DECLINE_IDENTIFIER";
        declineAction.title = @"Decline";
        declineAction.activationMode = UIUserNotificationActivationModeBackground;
        declineAction.destructive = YES;
        declineAction.authenticationRequired = NO;
        
        //Create category for friend requests
        UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
        inviteCategory.identifier = @"INVITE_CATEGORY";
        
        [inviteCategory setActions:@[acceptAction, declineAction]
                        forContext:UIUserNotificationActionContextDefault];
        
        //Create reply action for callouts
        UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
        replyAction.identifier = @"REPLY_IDENTIFIER";
        replyAction.title = @"Fight back!";
        replyAction.activationMode = UIUserNotificationActivationModeBackground;
        replyAction.destructive = NO;
        replyAction.authenticationRequired = NO;
        
        //Create category for callouts
        UIMutableUserNotificationCategory *messageCategory = [[UIMutableUserNotificationCategory alloc] init];
        messageCategory.identifier = @"MESSAGE_CATEGORY";
        
        [messageCategory setActions:@[replyAction]
                         forContext:UIUserNotificationActionContextDefault];
        
        //Set categories and settings
        NSSet *categories = [NSSet setWithObjects:inviteCategory, messageCategory, nil];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        
        //Register for notifications
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else //Version < iOS 8.0
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

@end
