//
//  DataHelper.h
//  rivalryapp
//
//  Created by Michael Bottone on 12/16/14.
//  Copyright (c) 2014 Rivalry Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Social/Social.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <malloc/malloc.h>

#import "MBProgressHUD.h"
#import "UIAlertView+Blocks.h"
#import "UIFloatLabelTextField.h"

@interface DataHelper : NSObject
{
    //Data Storage
    NSArray *teams;
    NSArray *bots;
    NSArray *friends;
    NSArray *interactions;
    NSArray *contactFriends;
    NSArray *requests;
    NSArray *contentProviders;
    NSMutableDictionary *contactData;
    
    //User Data Storage
    PFObject *myTeam;
    
    //Global Storage
    BOOL tutorialComplete;
    NSString *usernameStorage;
    
    //Timing Storage
    BOOL friendsDone;
    BOOL interactionsDone;
    BOOL notifyRegister;
}

//Data Storage Properties
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) NSArray *bots;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *interactions;
@property (nonatomic, strong) NSArray *contactFriends;
@property (nonatomic, strong) NSArray *requests;
@property (nonatomic, strong) NSArray *contentProviders;
@property (nonatomic, strong) NSMutableDictionary *contactData;

//User Data Storage Properties
@property (nonatomic, strong) PFObject *myTeam;

//Global Stoage Properties
@property (nonatomic) BOOL tutorialComplete;
@property (nonatomic) BOOL notifyRegister;
@property (nonatomic, strong) NSString *usernameStorage;

//Singleton Object Method
+ (DataHelper *)getInstance;

//Data Methods
- (void)getTeams:(void (^)(BOOL successful))callback;
- (void)getIntroBots:(void (^)(BOOL successful))callback;
- (void)login:(NSString *)username password:(NSString *)password callback:(void (^)(BOOL successful))callback;
- (void)signup:(NSString *)username password:(NSString *)password email:(NSString *)email phone:(NSString *)phone callback:(void (^)(BOOL successful))callback;
- (void)getFriends:(void (^)(BOOL successful))callback;
- (void)sendCallout:(PFUser *)user callback:(void (^)(BOOL successful))callback;
- (void)deleteFriend:(PFUser *)user callback:(void (^)(BOOL successful))callback;
- (void)updateProfile:(NSString *)username password:(NSString *)password email:(NSString *)email phone:(NSString *)phone callback:(void (^)(BOOL successful))callback;
- (NSArray *)calloutCountsWithUser:(PFUser *)user;
- (void)getContactFriends:(void (^)(BOOL successful))callback;
- (void)getFriendRequests:(void (^)(BOOL successful))callback;
- (void)getContentProviders:(void (^)(BOOL successful))callback;
- (void)confirmFriendRequest:(PFUser *)newFriend callback:(void (^)(BOOL successful))callback;
- (void)sendFriendRequest:(NSString *)username or:(PFUser *)user callback:(void (^)(BOOL successful))callback;
- (void)logout:(void (^)(BOOL successful))callback;
- (BOOL)followingProvider:(PFObject *)provider;
- (void)followProvider:(PFObject *)provider callback:(void (^)(BOOL successful))callback;
- (void)unfollowProvider:(PFObject *)provider callback:(void (^)(BOOL successful))callback;
- (void)forgotPassword:(void (^)(BOOL successful))callback;

//Error Handling
+ (void)handleError:(NSError *)error message:(NSString *)message;

//Helper Methods
+ (UIColor *)colorFromHex:(NSString *)hexString;
+ (NSString *)formatFlipTimer:(NSInteger)timeLeft;
+ (void)registerNotificaitons:(BOOL)doNotification;

@end