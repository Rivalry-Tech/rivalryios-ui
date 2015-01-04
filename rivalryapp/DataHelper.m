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

@synthesize teams, myTeam, bots, tutorialComplete, friends;

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

- (void)login:(NSString *)username password:(NSString *)password callback:(void (^)(BOOL successful))callback
{
    //Login through Parse
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if (user)
        {
            [user[@"primaryTeam"] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                myTeam = object;
                callback(YES);
            }];
        }
        else
        {
            [DataHelper handleError:error];
            callback(NO);
        }
    }];
}

- (void)signup:(NSString *)username password:(NSString *)password email:(NSString *)email phone:(NSString *)phone callback:(void (^)(BOOL successful))callback
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
            callback(YES);
        }
        else
        {
            [DataHelper handleError:error];
            callback(NO);
        }
    }];
}

- (void)getFriends:(void (^)(BOOL successful))callback
{
    //Create query for friends
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
    PFQuery *friendsQuery = [friendsRelation query];
    friendsQuery.limit = 1000;
    [friendsQuery includeKey:@"primaryTeam"];
    [friendsQuery orderByAscending:@"username"];
    
    //Retrieve friends from Parse
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (objects)
        {
            friends = objects;
            callback(YES);
        }
        else
        {
            [DataHelper handleError:error];
            callback(NO);
        }
    }];
}

- (void)sendCallout:(PFUser *)user callback:(void (^)(BOOL successful))callback
{
    //Find friends from Parse
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
    PFQuery *friendsQuery = [friendsRelation query];
    [friendsQuery whereKey:@"username" equalTo:user.username];
    [friendsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (user)
        {
            //Update team callout count
            NSNumber *calloutCount = (NSNumber *)myTeam[@"calloutCount"];
            calloutCount = [NSNumber numberWithInteger:[calloutCount integerValue] + 1];
            myTeam[@"calloutCount"] = calloutCount;
            [myTeam saveEventually];
            
            //Generate push payload
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@ says %@!", currentUser.username, myTeam[@"callout"]], @"alert",
                                  @"Increment", @"badge",
                                  myTeam[@"audioFile"], @"sound",
                                  [currentUser username], @"username",
                                  nil];
            
            //Which phone to send notificaiton to
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" matchesQuery:friendsQuery];
            
            //Create push
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:data];
            
            //Send push
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    callback(YES);
                }
                else
                {
                    [DataHelper handleError:error];
                    callback(NO);
                }
            }];
        }
        else
        {
            [DataHelper handleError:error];
            callback(NO);
        }
    }];
}

- (void)deleteFriend:(PFUser *)user callback:(void (^)(BOOL successful))callback
{
    //Remove friend in Parse
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
    [friendsRelation removeObject:user];
    [currentUser saveEventually];
    
    //Remove friend locally
    [[friends mutableCopy] removeObject:user];
    
    callback(YES);
}

- (void)updateProfile:(NSString *)username password:(NSString *)password email:(NSString *)email phone:(NSString *)phone callback:(void (^)(BOOL successful))callback
{
    //Get current user
    PFUser *currentUser = [PFUser currentUser];
    
    //Save old values
    NSString *oldUsername = currentUser.username;
    NSString *oldPassword = currentUser.password;
    NSString *oldEmail = currentUser.email;
    NSNumber *oldPhone = (NSNumber *)currentUser[@"phone"];
    
    //Update currentUser
    currentUser.username = username;
    if (![password isEqualToString:@""])
    {
        currentUser.password = password;
    }
    currentUser.email = email;
    currentUser[@"phone"] = [NSNumber numberWithLongLong:[phone longLongValue]];
    currentUser[@"primaryTeam"] = myTeam;
    
    //Save current user
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            callback(YES);
        }
        else
        {
            currentUser.username = oldUsername;
            currentUser.password = oldPassword;
            currentUser.email = oldEmail;
            currentUser[@"phone"] = oldPhone;
            currentUser[@"primaryTeam"] = myTeam;
            [DataHelper handleError:error];
            callback(NO);
        }
    }];
}

#pragma mark - Error Handling

+ (void)handleError:(NSError *)error
{
    if (error.userInfo[@"error"])
    {
        [UIAlertView showWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Server - %@", error.userInfo[@"error"]] cancelButtonTitle:@"Done" otherButtonTitles:nil tapBlock:nil];
    }
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
