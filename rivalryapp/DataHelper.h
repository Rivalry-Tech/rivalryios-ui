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

#import "MBProgressHUD.h"
#import "UIAlertView+Blocks.h"
#import "UIFloatLabelTextField.h"

@interface DataHelper : NSObject
{
    //Data Storage
    NSArray *teams;
    NSArray *bots;
    
    //User Data Storage
    PFObject *myTeam;
    
    //Global Storage
    BOOL tutorialComplete;
}

//Data Storage Properties
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) NSArray *bots;

//User Data Storage Properties
@property (nonatomic, strong) PFObject *myTeam;

//Global Stoage Properties
@property (nonatomic) BOOL tutorialComplete;

//Singleton Object Method
+ (DataHelper *)getInstance;

//Data Methods
- (void)getTeams:(void (^)())callback;
- (void)getIntroBots:(void (^)())callback;
- (void)login:(NSString *)username password:(NSString *)password callback:(void (^)())callback;
- (void)signup:(NSString *)username password:(NSString *)password email:(NSString *)email phone:(NSString *)phone callback:(void (^)())callback;

//Helper Methods
+ (UIColor *)colorFromHex:(NSString *)hexString;
+ (NSString *)formatFlipTimer:(NSInteger)timeLeft;
+ (void)registerNotificaitons;

@end
