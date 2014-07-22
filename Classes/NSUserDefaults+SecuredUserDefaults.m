//
//  NSUserDefaults+SecuredUserDefaults.m
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "NSUserDefaults+SecuredUserDefaults.h"

#define SUITE_NAME @"com.hk.secured.userdefaults"

@interface NSSecuredUserDefaults : NSUserDefaults

@end

@implementation NSSecuredUserDefaults

+(void)initialize
{
   
}

@end

@implementation NSUserDefaults (SecuredUserDefaults)

static id __securedObj = nil;
+(instancetype)securedUserDefaults
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __securedObj = [[NSSecuredUserDefaults alloc] initWithSuiteName:SUITE_NAME];
    });
    return __securedObj;
}

@end
