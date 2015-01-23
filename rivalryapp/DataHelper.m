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

@synthesize teams, myTeam, bots, tutorialComplete, friends, interactions, contactFriends, requests;

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
            
            //Create query for interactions
            PFQuery *interactionQuery1 = [PFQuery queryWithClassName:@"Interaction"];
            [interactionQuery1 whereKey:@"User1" equalTo:currentUser];
            PFQuery *interactionQuery2 = [PFQuery queryWithClassName:@"Interaction"];
            [interactionQuery2 whereKey:@"User2" equalTo:currentUser];
            PFQuery *interactionQuery = [PFQuery orQueryWithSubqueries:@[interactionQuery1, interactionQuery2]];
            [interactionQuery includeKey:@"User1"];
            [interactionQuery includeKey:@"User2"];
            
            //Get interactions from Parse
            [interactionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
            {
                if (objects)
                {
                    interactions = objects;
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
            
            //Update user callout count
            [self updateUserCallout:(PFUser *)user];
            
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
    NSMutableArray *friends_m = [friends mutableCopy];
    [friends_m removeObject:user];
    friends = [NSArray arrayWithArray:friends_m];
    
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
    PFObject *oldTeam = currentUser[@"primaryTeam"];
    
    //Update currentUser
    currentUser.username = username;
    if (![password isEqualToString:@"AAAAAAAAAAAA"])
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
            currentUser[@"primaryTeam"] = oldTeam;
            myTeam = oldTeam;
            [DataHelper handleError:error];
            callback(NO);
        }
    }];
}

- (NSArray *)calloutCountsWithUser:(PFUser *)user;
{
    PFUser *currentUser = [PFUser currentUser];
    
    //Get the interaction for the given user
    NSUInteger index = [interactions indexOfObjectPassingTest:^BOOL(PFObject *obj, NSUInteger idx, BOOL *stop)
                        {
                            PFUser *user1 = obj[@"User1"];
                            PFUser *user2 = obj[@"User2"];
                            if ([user1.objectId isEqualToString:user.objectId] || [user2.objectId isEqualToString:user.objectId])
                            {
                                *stop = YES;
                                return *stop;
                            }
                            return NO;
                        }];
    
    //If the interaction exists
    if (index != NSNotFound)
    {
        //Get the counts from the interaction and return them in an array
        PFObject *interaction = [interactions objectAtIndex:index];
        PFUser *user1 = interaction[@"User1"];
        NSNumber *myCount, *theirCount;
        if ([user1.objectId isEqualToString:currentUser.objectId])
        {
            myCount = interaction[@"Count1"];
            theirCount = interaction[@"Count2"];
        }
        else
        {
            myCount = interaction[@"Count1"];
            theirCount = interaction[@"Count2"];
        }
        return @[myCount, theirCount];
    }
    else
    {
        //If the interaciton doesn't exist return zerosc
        NSNumber *zero = [NSNumber numberWithLongLong:0];
        return @[zero, zero];
    }
}

- (void)getContactFriends:(void (^)(BOOL successful))callback
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
    {
        if (error || !granted)
        {
            NSLog(@"Address Book Error: %@", error);
            callback(NO);
            return;
        }
        
        CFArrayRef peopleFromAddressBook = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableDictionary *contactData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
        
        for (int i = 0; i < numberOfPeople; i++)
        {
            ABRecordRef personRecord = CFArrayGetValueAtIndex(peopleFromAddressBook, i);
            ABMutableMultiValueRef phonelist = ABRecordCopyValue(personRecord, kABPersonPhoneProperty);
            CFIndex numPhones = ABMultiValueGetCount(phonelist);
            CFStringRef nameRef = ABRecordCopyCompositeName(personRecord);
            NSString *name = CFBridgingRelease(nameRef);
            for (int j=0; j < numPhones; j++)
            {
                CFTypeRef numberRef = ABMultiValueCopyValueAtIndex(phonelist, j);
                NSString *number = CFBridgingRelease(numberRef);
                NSCharacterSet *charactersToRemove = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                NSString *plainNumber = [[number componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
                if (plainNumber.length >= 10)
                {
                    plainNumber = [plainNumber substringFromIndex:plainNumber.length - 10];
                }
                [contactData setValue:name forKey:plainNumber];
            }
        }
        
        NSMutableArray *phoneNumbers = [[contactData allKeys] mutableCopy];
        [phoneNumbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *plainNumber = obj;
            NSNumber *phoneNumber = [NSNumber numberWithLongLong:[plainNumber longLongValue]];
            if ([phoneNumber longLongValue] == 0)
            {
                [phoneNumbers removeObjectAtIndex:idx];
                [contactData removeObjectForKey:plainNumber];
            }
            else
            {
                [phoneNumbers replaceObjectAtIndex:idx withObject:phoneNumber];
            }
        }];
        
        PFUser *currentUser = [PFUser currentUser];
        PFQuery *phoneQuery = [PFUser query];
        [phoneQuery whereKey:@"phone" containedIn:phoneNumbers];
        [phoneQuery includeKey:@"primaryTeam"];
        PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
        PFQuery *friendsQuery = [friendsRelation query];
        friendsQuery.limit = 1000;
        [phoneQuery whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:friendsQuery];
        [phoneQuery whereKey:@"username" notEqualTo:currentUser.username];
        [phoneQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error)
            {
                [DataHelper handleError:error];
                callback(NO);
            }
            else
            {
                contactFriends = objects;
                callback(YES);
            }
        }];
    });
}

- (void)getFriendRequests:(void (^)(BOOL successful))callback
{
    //Create query for friends
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *requestRelation = [currentUser relationForKey:@"requests"];
    PFQuery *requestQuery = [requestRelation query];
    requestQuery.limit = 1000;
    [requestQuery includeKey:@"primaryTeam"];
    [requestQuery orderByAscending:@"username"];
    
    //Retrieve friends from Parse
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             requests = objects;
             callback(YES);
         }
         else
         {
             [DataHelper handleError:error];
             callback(NO);
         }
     }];
}

- (void)confirmFriendRequest:(PFUser *)newFriend callback:(void (^)(BOOL successful))callback
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *friendsRelation = [currentUser relationForKey:@"friends"];
    PFRelation *requestsRelation = [currentUser relationForKey:@"requests"];
    
    [[requests mutableCopy] removeObject:newFriend];
    [friendsRelation addObject:newFriend];
    [requestsRelation removeObject:newFriend];
    [currentUser saveEventually];
    
    NSDictionary *cloudParams = [NSDictionary dictionaryWithObjectsAndKeys:newFriend.username, @"friendUsername", nil];
    
    [PFCloud callFunctionInBackground:@"addFriend" withParameters:cloudParams block:^(id object, NSError *error)
    {
        if (error)
        {
            [DataHelper handleError:error];
            callback(NO);
        }
        else
        {
            callback(YES);
        }
    }];
}

- (void)sendFriendRequest:(NSString *)username or:(PFUser *)user callback:(void (^)(BOOL successful))callback
{
    NSError *error = nil;
    PFUser *currentUser = [PFUser currentUser];
    
    if (user == nil)
    {
        NSUInteger friendIndex = [friends indexOfObjectPassingTest:^BOOL(PFUser *user, NSUInteger idx, BOOL *stop) {
            *stop = [user.username isEqualToString:username];
            return *stop;
        }];
        
        if (friendIndex != NSNotFound)
        {
            [error.userInfo setValue:[NSString stringWithFormat:@"You and %@ are already friends.", username] forKey:@"error"];
            [DataHelper handleError:error];
            callback(NO);
            return;
        }
        
        if ([username isEqualToString:currentUser.username])
        {
            [error.userInfo setValue:@"You can't add yourself as a friend." forKey:@"error"];
            [DataHelper handleError:error];
            callback(NO);
            return;
        }
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:username];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             PFUser *friend = (PFUser *)object;
             if (friend != nil)
             {
                 [self sendRequestHelper:friend callback:callback];
             }
             else
             {
                 [error.userInfo setValue:[NSString stringWithFormat:@"%@ does not exist in our system", username] forKey:@"error"];
                 [DataHelper handleError:error];
                 callback(NO);
             }
         }];
    }
    else
    {
        [self sendRequestHelper:user callback:callback];
    }
}

- (void)sendRequestHelper:(PFUser *)friend callback:(void (^)(BOOL successful))callback
{
    PFUser *currentUser = [PFUser currentUser];
    NSDictionary *cloudParams = [NSDictionary dictionaryWithObjectsAndKeys:friend.username, @"friendUsername", nil];
    [PFCloud callFunctionInBackground:@"sendRequest" withParameters:cloudParams block:^(id object, NSError *error)
     {
         NSString *response = (NSString *)object;
         if (![response isEqualToString:@"Friend request already sent!"])
         {
             PFQuery *pushQuery = [PFInstallation query];
             [pushQuery whereKey:@"user" equalTo:friend];
             
             NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%@ has sent you a friend request.", currentUser.username], @"alert",
                                   @"Increment", @"badge",
                                   @"default", @"sound",
                                   [currentUser username], @"username",
                                   nil];
             
             PFPush *push = [[PFPush alloc] init];
             [push setQuery:pushQuery];
             [push setData:data];
             [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if(error)
                 {
                     [DataHelper handleError:error];
                     callback(NO);
                 }
                 else
                 {
                     callback(YES);
                 }
             }];
             
         }
     }];
}

#pragma mark - Hidden Helper Methods

- (void)updateUserCallout:(PFUser *)user
{
    PFUser *currentUser = [PFUser currentUser];
    
    //Get interaction for user
    NSUInteger index = [interactions indexOfObjectPassingTest:^BOOL(PFObject *obj, NSUInteger idx, BOOL *stop)
    {
        PFUser *user1 = obj[@"User1"];
        PFUser *user2 = obj[@"User2"];
        BOOL user1Bool = ([user1.objectId isEqualToString:user.objectId] || [user1.objectId isEqualToString:currentUser.objectId]);
        BOOL user2Bool = ([user2.objectId isEqualToString:user.objectId] || [user2.objectId isEqualToString:currentUser.objectId]);
        if (user1Bool && user2Bool)
        {
            *stop = YES;
            return *stop;
        }
        return NO;
    }];
    
    //If the interaction exists update it
    PFObject *interaction;
    if (index != NSNotFound)
    {
        //Find out which count to update and incriment it
        interaction = [interactions objectAtIndex:index];
        PFUser *user1 = (PFUser *)interaction[@"User1"];
        PFUser *user2 = (PFUser *)interaction[@"User2"];
        NSNumber *count, *newCount;
        if ([user1.objectId isEqualToString:currentUser.objectId])
        {
            count = (NSNumber *)interaction[@"Count1"];
            newCount = [NSNumber numberWithLongLong:[count longLongValue] + 1];
            interaction[@"Count1"] = newCount;
        }
        else if ([user2.objectId isEqualToString:currentUser.objectId])
        {
            count = (NSNumber *)interaction[@"Count2"];
            newCount = [NSNumber numberWithLongLong:[count longLongValue] + 1];
            interaction[@"Count2"] = newCount;
        }
        
        //Save the interaction
        [interaction saveInBackground];
    }
    else
    {
        //Create a new interaction if it doesn't exist and save it
        interaction = [PFObject objectWithClassName:@"Interaction"];
        interaction[@"User1"] = currentUser;
        interaction[@"User2"] = user;
        interaction[@"Count1"] = [NSNumber numberWithInt:1];
        interaction[@"Count2"] = [NSNumber numberWithInt:0];
        [interaction saveInBackground];
    }
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
