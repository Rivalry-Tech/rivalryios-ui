//
//  AppDelegate.m
//  rivalryapp
//
//  Created by Michael Bottone on 12/14/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Application Delegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Set up Parse
    [ParseCrashReporting enable];
    
    [Parse setApplicationId:@"VpoTYiqIfqYQtUWAzHxz55dbbecnjSv30wrX0ULj"
                  clientKey:@"U62N1GwoVE5sVa3T3mm7p6CthwQMO1GT3Y8mcIwq"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Set Global Navigation Bar Styles
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15.0],NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    //Clear badge
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    NSDictionary *notificaiton = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificaiton)
    {
        if ([notificaiton.allKeys indexOfObject:@"contentUrl"] != NSNotFound)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notificaiton[@"contentUrl"]]];
                exit(0);
            });
        }
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"reset"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"reset"];
        [PFUser logOut];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        currentInstallation[@"user"] = currentUser;
        [currentInstallation saveInBackground];
        
        DataHelper *helper = [DataHelper getInstance];
        PFObject *team = currentUser[@"primaryTeam"];
        PFQuery *teamQuery = [PFQuery queryWithClassName:@"Team"];
        [teamQuery whereKey:@"objectId" equalTo:team.objectId];
        teamQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [teamQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            helper.myTeam = object;
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            UIViewController *start = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rivalry"];
            [start.navigationItem setHidesBackButton:YES];
            [navController pushViewController:start animated:NO];
        }];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //Save device token for each user
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    DataHelper *helper = [DataHelper getInstance];
    if (helper.notifyRegister)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushRegistered" object:nil];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error.code == 3010)
    {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    }
    else
    {
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
    
    DataHelper *helper = [DataHelper getInstance];
    if (helper.notifyRegister)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushRegistered" object:nil];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    
    //Clear badge
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:notification.alertBody, @"alert", notification.soundName, @"sound", @"0", @"badge", nil];
    NSDictionary *aps = [NSDictionary dictionaryWithObjectsAndKeys:data, @"aps", nil];
    [PFPush handlePush:aps];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //Clear badge
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data Stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "rivalry.rivalryapp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"rivalryapp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"rivalryapp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator)
    {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving Support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
