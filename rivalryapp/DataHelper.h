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
    
}

//Singleton Object Method
+ (DataHelper *)getInstance;

//Helper Methods
+ (UIColor *)colorFromHex:(NSString *)hexString;

@end
