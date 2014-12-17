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

#pragma mark - Helper Methods

+ (UIColor *)colorFromHex:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
