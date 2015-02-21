//
//  AppDelegate.h
//  rivalryapp
//
//  Created by Michael Bottone on 12/14/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "DataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL becomingActive;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

