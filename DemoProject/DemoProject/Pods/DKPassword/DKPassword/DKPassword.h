//
//  DKPassword.h
//  DKPassword
//
//  Created by Dmitry Kurilo on 1/19/14.
//  Copyright (c) 2014 Kurilo Dmitry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKPassword : NSObject

@property (strong) NSString* pass;
+(int)passwordStrength:(NSString*)password;


@end
