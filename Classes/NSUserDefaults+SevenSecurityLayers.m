//
//  NSUserDefaults+SecuredUserDefaults.m
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "NSUserDefaults+SevenSecurityLayers.h"
#import "CocoaSecurity.h"



#define kStoredObjectKey @"storedObject"
#define SUITE_NAME       @"com.hk.SevenSecurityLayers.userdefaults"

#define NSSTRING const NSString

NSSTRING * NOTIFICATION_SECRET_KEY_NOT_SET             = @"NOTIFICATION_SECRET_KEY_NOT_SET";
NSSTRING * NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA = @"NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA";
NSSTRING * NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA    = @"NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA";
NSSTRING * NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED  = @"NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED";

#pragma mark Implement NSDictionary+SecuredUserDefaults

@interface NSSecuredDictionary : NSDictionary

@end

@implementation NSDictionary (SevenSecurityLayers)

-(NSSecuredDictionary*) securedCopy
{
    return nil;
}

-(NSString *)messageFromUserInfo
{
    return [[self objectForKey:@"message"] description];
}

-(NSString *)keyFromUserInfo
{
    return [[self objectForKey:@"key"] description];
}

-(id)valueFromUserInfo
{
    return [self objectForKey:@"value"];
}

@end

#pragma mark Implement NSSecuredDictionary



@implementation NSSecuredDictionary

-(NSString *)messageFromUserInfo
{
    return [[self objectForKey:@"message"] description];
}

-(NSString *)keyFromUserInfo
{
    return [[self objectForKey:@"key"] description];
}

-(id)valueFromUserInfo
{
    return [self objectForKey:@"value"];
}

@end

@interface NSSecuredUserDefaults : NSUserDefaults

@end

#pragma mark Implemement NSUserDefaults+SevenSecurityLayers.h

@implementation NSUserDefaults (SevenSecurityLayers)

+(instancetype)securedUserDefaults
{
    return [NSSecuredUserDefaults securedUserDefaults];
}

-(instancetype)setSecretKey:(NSString *)secretKey
{
    return nil;
}

@end

@implementation NSSecuredUserDefaults

#pragma mark Implemement category

static id __securedObj = nil;
+(instancetype)securedUserDefaults
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __securedObj = [[NSSecuredUserDefaults alloc] initWithSuiteName:SUITE_NAME];
    });
    return __securedObj;
}

static NSString *__secretKey = nil;
-(instancetype)setSecretKey:(NSString *)secretKey
{
    // Check if we have a (valid) key needed to decrypt
    if(!secretKey.length)
    {
#ifdef DEBUG
        NSLog(@"NSSecuredUserDefaults >>> %@",@"Secret may not be nil");
#endif
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[NOTIFICATION_SECRET_KEY_NOT_SET copy] object:self userInfo:@{@"message": @"Secret may not be nil"}];
    }
    
    __secretKey = [secretKey copy];
    return self;
}

#pragma mark Getter method

-(id)objectForKey:(NSString *)defaultName
{
    // Check if we have a (valid) key needed to decrypt
    if(!__secretKey.length)
    {
#ifdef DEBUG
        NSLog(@"NSSecuredUserDefaults >>> %@",@"Secret may not be nil when storing an object securely");
#endif

        [[NSNotificationCenter defaultCenter] postNotificationName:[NOTIFICATION_SECRET_KEY_NOT_SET copy] object:self userInfo:@{@"message": @"Secret may not be nil when storing an object securely",@"key":defaultName}];
        
        return nil;
    }
    
    // Fetch data from user defaults
    NSData *data = [super objectForKey:defaultName];
    
    // Check if we have some data to decrypt, return nil if no
    if(data == nil) {
        return nil;
    }
    
    // Try to decrypt data
    @try {
        
        // Generate key and IV
        CocoaSecurityResult *keyData = [CocoaSecurity sha384:__secretKey];
        NSData *aesKey = [keyData.data subdataWithRange:NSMakeRange(0, 32)];
        NSData *aesIv = [keyData.data subdataWithRange:NSMakeRange(32, 16)];
        
        // Decrypt data
        CocoaSecurityResult *result = [CocoaSecurity aesDecryptWithData:data key:aesKey iv:aesIv];
        
        // Turn data into object and return
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:result.data];
        id object = [unarchiver decodeObjectForKey:kStoredObjectKey];
        [unarchiver finishDecoding];
        return object;
    }
    @catch (NSException *exception) {
        
#ifdef DEBUG
        // Whoops!
        NSLog(@"Cannot receive object from encrypted data storage: %@",exception.reason);
#endif
        [[NSNotificationCenter defaultCenter] postNotificationName:[NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA copy] object:self userInfo:@{@"message": [NSString stringWithFormat:@"Cannot receive object from encrypted data storage: %@",exception.reason],@"key":defaultName,@"value":@""}];
        
        return nil;
    }
    
    @finally {}
}

-(NSData *)dataForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSData class]]) {
		return object;
	} else {
		return nil;
	}
}

-(NSURL *)URLForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSURL class]]) {
		return object;
	} else {
		return nil;
	}
}

-(NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSDictionary class]]) {
		return object;
	} else {
		return nil;
	}
}

-(NSArray *)arrayForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSArray class]]) {
		return object;
	} else {
		return nil;
	}
}

-(NSArray *)stringArrayForKey:(NSString *)defaultName
{
    id objects = [self objectForKey:defaultName];
	if([objects isKindOfClass:[NSArray class]]) {
		for(id object in objects) {
			if(![object isKindOfClass:[NSString class]]) {
				return nil;
			}
		}
		return objects;
	} else {
		return nil;
	}
}

-(NSString *)stringForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSString class]]) {
		return object;
	} else {
		return nil;
	}
}

- (BOOL)boolForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSNumber class]]) {
		return [object boolValue];
	} else {
		return NO;
	}
}

- (NSInteger)integerForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSNumber class]]) {
		return [object integerValue];
	} else {
		return 0;
	}
}

- (double)doubleForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSNumber class]]) {
		return [object doubleValue];
	} else {
		return 0;
	}
}

- (float)floatForKey:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
	if([object isKindOfClass:[NSNumber class]]) {
		return [object floatValue];
	} else {
		return 0.f;
	}
}

#pragma Setter method

-(void)setObject:(id)value forKey:(NSString *)defaultName
{
    // Check if we have a (valid) key needed to encrypt
    if(!__secretKey.length)
    {
#ifdef DEBUG
        NSLog(@"NSSecuredUserDefaults >>> %@",@"Secret may not be nil when storing an object securely");
#endif
        [[NSNotificationCenter defaultCenter] postNotificationName:[NOTIFICATION_SECRET_KEY_NOT_SET copy] object:self userInfo:@{@"message": @"Secret may not be nil when storing an object securely",@"key":defaultName}];
        
        return;
    }
    
    @try {
        
        // Create data object from dictionary
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:value forKey:kStoredObjectKey];
        [archiver finishEncoding];
        
        // Generate key and IV
        CocoaSecurityResult *keyData = [CocoaSecurity sha384:__secretKey];
        NSData *aesKey = [keyData.data subdataWithRange:NSMakeRange(0, 32)];
        NSData *aesIv = [keyData.data subdataWithRange:NSMakeRange(32, 16)];
        
        // Encrypt data
        CocoaSecurityResult *result = [CocoaSecurity aesEncryptWithData:data key:aesKey iv:aesIv];
        
        // Save data in user defaults
        [super setObject:result.data forKey:defaultName];
    }
    @catch (NSException *exception) {
        
#ifdef DEBUG
        // Whoops!
        NSLog(@"Cannot store object securely: %@",exception.reason);
#endif
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA copy] object:self userInfo:@{@"message": [NSString stringWithFormat:@"Cannot store object securely: %@",exception.reason],@"key":defaultName,@"value":value}];
    }
    @finally {}
}


- (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    [self setObject:[NSNumber numberWithBool:value] forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName
{
    [self setObject:[NSNumber numberWithFloat:value] forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
    [self setObject:[NSNumber numberWithInteger:value] forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:defaultName];
}

- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName
{
    [self setObject:url forKey:defaultName];
}

@end

