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

@interface DataHelper : NSObject
{
    //Data Storage
    NSArray *teams;
}

//Data Storage Properties
@property (nonatomic, strong) NSArray *teams;

//Singleton Object Method
+ (DataHelper *)getInstance;

//Data Methods
- (void)getTeams:(void (^)())callback;

//Helper Methods
+ (UIColor *)colorFromHex:(NSString *)hexString;

@end
