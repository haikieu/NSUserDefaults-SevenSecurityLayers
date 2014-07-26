//
//  NSUserDefaults+SecuredUserDefaults.m
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "NSUserDefaults+SevenSecurityLayers.h"
#import "CocoaSecurity.h"

#define NSSTRING const NSString

NSSTRING * NOTIFICATION_SECRET_KEY_NOT_SET             = @"NOTIFICATION_SECRET_KEY_NOT_SET";
NSSTRING * NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA = @"NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA";
NSSTRING * NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA    = @"NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA";
NSSTRING * NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED  = @"NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED";

#if DEBUG

#define TEST_RELEASE_MODE 0

#endif
//################################################################################################################
@interface NSSecuredUserDefaults : NSUserDefaults @end
//################################################################################################################
@implementation NSSecuredUserDefaults
{
    __strong NSString * _secretKey;
    __strong NSString * _UUID;
    
    __strong NSData *_secretData;
    __strong NSData *_deviceIdentifierData;
    
     EncryptionAlgorithm _encryption;
}
static NSString * kStoredObjectKey;
static NSString * SUITE_NAME;
static NSString * _userDefaultsValueKey;
static NSString * _userDefaultsHashKey;
+(void)initialize
{
    kStoredObjectKey = @"".s.t.o.r.e.d.O.b.j.e.c.t;
    SUITE_NAME = @"".c.o.m.dot.h.k.dot.S.e.v.e.n.S.e.c.u.r.i.t.y.L.a.y.e.r.s.dot.u.s.e.r.d.e.f.a.u.l.t.s;
    
    _userDefaultsValueKey = @"".D.e.f.a.u.l.t.s.V.a.l.u.e.K.e.y;
    _userDefaultsHashKey = @"".D.e.f.a.u.l.t.s.H.a.s.h.K.e.y;
}

- (NSString *)_hashObject:(id)object
{
	if (_secretData == nil) {
		// Use if statement in case asserts are disabled
		NSAssert(NO, @"Provide a secret before using any secure writing or reading methods!");
		return nil;
	}
    
    // Copy object to make sure it is immutable (thanks Stephen)
    object = [object copy];
	
	// Archive & hash
	NSMutableData *archivedData = [[NSKeyedArchiver archivedDataWithRootObject:object] mutableCopy];
	[archivedData appendData:_secretData];
	if (_deviceIdentifierData != nil) {
		[archivedData appendData:_deviceIdentifierData];
	}
	NSString *hash = [self _hashData:archivedData];
	
	return hash;
}

- (NSString *)_hashData:(NSData *)data
{
	return [CocoaSecurity md5WithData:data].base64;
}

#pragma mark - Implemement category

static id __securedObj = nil;
+(instancetype)securedUserDefaults
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __securedObj = [[[NSSecuredUserDefaults alloc] initWithSuiteName:SUITE_NAME] setEncryption:EncryptionDefault];
    });
    return __securedObj;
}

-(instancetype)setSecretKey:(NSString *)secretKey
{
    // Check if we have a (valid) key needed to decrypt
    if(!secretKey.length)
    {
#ifdef DEBUG
        NSLog(@"NSSecuredUserDefaults >>> %@",@"Secret key may not be nil");
#endif
        [self raiseEncryptionKeyException];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef DEBUG
        _secretKey = [secretKey copy];
#else
        _secretKey = [CocoaSecurity md5:secretKey].hexLower;
#endif
        
    });
    
    return self;
}

-(instancetype)setUUID:(NSString *)UUID
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef DEBUG
        _UUID = [UUID copy];
#else
        _UUID = [CocoaSecurity md5:UUID].hexLower;;
#endif
    });
    
    return self;
}

-(instancetype)setEncryption:(enum EncryptionAlgorithm)encryptionAlgorithm
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _encryption = encryptionAlgorithm;
    });
    
    return self;
}

#pragma mark - traditional storage

#pragma mark - iCloud


#pragma mark - Encryption & Decryption

-(NSData*) encryptData:(NSData*) data key:(NSString*) key
{
    return nil;
}

-(NSData*) decryptData:(NSData*) data key:(NSString*) key
{
    return nil;
}

-(void)setSecuredObject:(id)value forKey:(NSString *)defaultName
{
    // Check if we have a (valid) key needed to encrypt
    if(!_secretKey.length)
    {
#ifdef DEBUG
        NSLog(@"NSSecuredUserDefaults >>> %@",@"Secret may not be nil when storing an object securely");
#endif
        [self raiseEncryptionKeyException];
        
        return;
    }
    
    @try {
        
        // Create data object from dictionary
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:value forKey:kStoredObjectKey];
        [archiver finishEncoding];
        
        // Generate key and IV
        CocoaSecurityResult *keyData = [CocoaSecurity sha384:_secretKey];
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

-(id)securedObjectForKey:(NSString *)defaultName
{
    // Check if we have a (valid) key needed to decrypt
    if(!_secretKey.length)
    {
#ifdef DEBUG
        NSLog(@"NSSecuredUserDefaults >>> %@",@"Secret may not be nil or blank when storing an object securely");
#endif
        [self raiseEncryptionKeyException];
        
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
        CocoaSecurityResult *keyData = [CocoaSecurity sha384:_secretKey];
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


#pragma mark - Storage business

-(void)setObject:(id)value forKey:(NSString *)defaultName
{
    if(defaultName.isNonSecured)
    {
        [super setObject:value forKey:defaultName];
    }
    else
    {
        [self setSecuredObject:value forKey:defaultName];
    }
}

-(id)objectForKey:(NSString *)defaultName
{
    if(defaultName.isNonSecured)
    {
        return [super objectForKey:defaultName];
    }
    
    return [self securedObjectForKey:defaultName];
}

#pragma mark - Getter method

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

#pragma mark - Setter method

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

#pragma mark - throw Exception

-(void) raiseEncryptionKeyException
{
    [[NSException exceptionWithName:@"EncryptionKeyException" reason:@"Secret key should not be nil" userInfo:nil] raise];
}

#pragma mark - Debug
-(NSString *)debugDescription
{
    NSString * dic = [super debugDescription];
    
#ifdef DEBUG
    dic = [[self dictionaryRepresentation] description];
#endif
    
    return dic;
}

#pragma mark - Reset secured userdefaults

+(void)resetSecuredUserDefaults
{
    [[NSUserDefaults securedUserDefaults] removePersistentDomainForName:SUITE_NAME];
}

@end
//################################################################################################################
#pragma mark - Implement NSUserDefaults+SevenSecurityLayers.h
//################################################################################################################
@implementation NSUserDefaults (SevenSecurityLayers)

+(instancetype)securedUserDefaults
{
    return [NSSecuredUserDefaults securedUserDefaults];
}

+(void)resetSecuredUserDefaults
{
    [NSSecuredUserDefaults resetSecuredUserDefaults];
}

-(instancetype)setSecretKey:(NSString *)secretKey                           {   return nil; }
-(instancetype)setEncryption:(enum EncryptionAlgorithm)encryptionAlgorithm  {   return nil; }
-(instancetype)setiCloud:(enum iCloudMode)iCloudMode                        {   return nil; }

+(void)migrate:(NSUserDefaults *)source to:(NSUserDefaults *)destination clearSource:(BOOL)clear
{
    [source.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        [destination setObject:obj forKey:key];
        
        if(clear)
           [source removeObjectForKey:key];
    }];
    
    if(clear)
        [source synchronize];
    [destination synchronize];
}

@end
//################################################################################################################
#pragma mark - Implement NSDictionary+SevenSecurityLayers
//################################################################################################################
@implementation NSDictionary (SevenSecurityLayers)

-(NSString *)messageFromUserInfo    {   return [[self objectForKey:@"message"] description];    }
-(NSString *)keyFromUserInfo        {   return [[self objectForKey:@"key"] description];        }
-(id)valueFromUserInfo              {   return [self objectForKey:@"value"];                    }

@end
//################################################################################################################
#pragma mark - Implement NSString+SevenSecurityLayers
//################################################################################################################
@implementation NSString (SevenSecurityLayers)

- (NSString *)cloud { return [self stringByAppendingString:@".cloud"]; }
- (NSString *)nonSecured { return [self stringByAppendingString:@".nonSecured"]; }

-(BOOL)isCloud
{
    return !([self rangeOfString:@"".cloud options:NSCaseInsensitiveSearch].location == NSNotFound);
}
-(BOOL)isNonSecured
{
    return !([self rangeOfString:@"".nonSecured options:NSCaseInsensitiveSearch].location == NSNotFound);
}

@end
//################################################################################################################
#pragma mark - Implement NSString+UAObfuscatedString
//################################################################################################################
@implementation NSString (UAObfuscatedString)

#pragma mark - Obfuscating a-z
- (NSString *)a { return [self stringByAppendingString:@"a"]; }
- (NSString *)b { return [self stringByAppendingString:@"b"]; }
- (NSString *)c { return [self stringByAppendingString:@"c"]; }
- (NSString *)d { return [self stringByAppendingString:@"d"]; }
- (NSString *)e { return [self stringByAppendingString:@"e"]; }
- (NSString *)f { return [self stringByAppendingString:@"f"]; }
- (NSString *)g { return [self stringByAppendingString:@"g"]; }
- (NSString *)h { return [self stringByAppendingString:@"h"]; }
- (NSString *)i { return [self stringByAppendingString:@"i"]; }
- (NSString *)j { return [self stringByAppendingString:@"j"]; }
- (NSString *)k { return [self stringByAppendingString:@"k"]; }
- (NSString *)l { return [self stringByAppendingString:@"l"]; }
- (NSString *)m { return [self stringByAppendingString:@"m"]; }
- (NSString *)n { return [self stringByAppendingString:@"n"]; }
- (NSString *)o { return [self stringByAppendingString:@"o"]; }
- (NSString *)p { return [self stringByAppendingString:@"p"]; }
- (NSString *)q { return [self stringByAppendingString:@"q"]; }
- (NSString *)r { return [self stringByAppendingString:@"r"]; }
- (NSString *)s { return [self stringByAppendingString:@"s"]; }
- (NSString *)t { return [self stringByAppendingString:@"t"]; }
- (NSString *)u { return [self stringByAppendingString:@"u"]; }
- (NSString *)v { return [self stringByAppendingString:@"v"]; }
- (NSString *)w { return [self stringByAppendingString:@"w"]; }
- (NSString *)x { return [self stringByAppendingString:@"x"]; }
- (NSString *)y { return [self stringByAppendingString:@"y"]; }
- (NSString *)z { return [self stringByAppendingString:@"z"]; }

#pragma mark - Obfuscating A-Z
- (NSString *)A { return [self stringByAppendingString:@"A"]; }
- (NSString *)B { return [self stringByAppendingString:@"B"]; }
- (NSString *)C { return [self stringByAppendingString:@"C"]; }
- (NSString *)D { return [self stringByAppendingString:@"D"]; }
- (NSString *)E { return [self stringByAppendingString:@"E"]; }
- (NSString *)F { return [self stringByAppendingString:@"F"]; }
- (NSString *)G { return [self stringByAppendingString:@"G"]; }
- (NSString *)H { return [self stringByAppendingString:@"H"]; }
- (NSString *)I { return [self stringByAppendingString:@"I"]; }
- (NSString *)J { return [self stringByAppendingString:@"J"]; }
- (NSString *)K { return [self stringByAppendingString:@"K"]; }
- (NSString *)L { return [self stringByAppendingString:@"L"]; }
- (NSString *)M { return [self stringByAppendingString:@"M"]; }
- (NSString *)N { return [self stringByAppendingString:@"N"]; }
- (NSString *)O { return [self stringByAppendingString:@"O"]; }
- (NSString *)P { return [self stringByAppendingString:@"P"]; }
- (NSString *)Q { return [self stringByAppendingString:@"Q"]; }
- (NSString *)R { return [self stringByAppendingString:@"R"]; }
- (NSString *)S { return [self stringByAppendingString:@"S"]; }
- (NSString *)T { return [self stringByAppendingString:@"T"]; }
- (NSString *)U { return [self stringByAppendingString:@"U"]; }
- (NSString *)V { return [self stringByAppendingString:@"V"]; }
- (NSString *)W { return [self stringByAppendingString:@"W"]; }
- (NSString *)X { return [self stringByAppendingString:@"X"]; }
- (NSString *)Y { return [self stringByAppendingString:@"Y"]; }
- (NSString *)Z { return [self stringByAppendingString:@"Z"]; }

#pragma mark - Obfuscating Numbers
- (NSString *)_1 { return [self stringByAppendingString:@"1"]; }
- (NSString *)_2 { return [self stringByAppendingString:@"2"]; }
- (NSString *)_3 { return [self stringByAppendingString:@"3"]; }
- (NSString *)_4 { return [self stringByAppendingString:@"4"]; }
- (NSString *)_5 { return [self stringByAppendingString:@"5"]; }
- (NSString *)_6 { return [self stringByAppendingString:@"6"]; }
- (NSString *)_7 { return [self stringByAppendingString:@"7"]; }
- (NSString *)_8 { return [self stringByAppendingString:@"8"]; }
- (NSString *)_9 { return [self stringByAppendingString:@"9"]; }
- (NSString *)_0 { return [self stringByAppendingString:@"0"]; }

#pragma mark - Obfuscating Punctuation
- (NSString *)space { return [self stringByAppendingString:@" "]; }
- (NSString *)point { return [self stringByAppendingString:@"."]; }
- (NSString *)dash { return [self stringByAppendingString:@"-"]; }
- (NSString *)comma { return [self stringByAppendingString:@","]; }
- (NSString *)semicolon { return [self stringByAppendingString:@";"]; }
- (NSString *)colon { return [self stringByAppendingString:@":"]; }
- (NSString *)apostrophe { return [self stringByAppendingString:@"'"]; }
- (NSString *)quotation { return [self stringByAppendingString:@"\""]; }
- (NSString *)plus { return [self stringByAppendingString:@"+"]; }
- (NSString *)equals { return [self stringByAppendingString:@"="]; }
- (NSString *)paren_left { return [self stringByAppendingString:@"("]; }
- (NSString *)paren_right { return [self stringByAppendingString:@")"]; }
- (NSString *)asterisk { return [self stringByAppendingString:@"*"]; }
- (NSString *)ampersand { return [self stringByAppendingString:@"&"]; }
- (NSString *)caret { return [self stringByAppendingString:@"^"]; }
- (NSString *)percent { return [self stringByAppendingString:@"%"]; }
- (NSString *)$ { return [self stringByAppendingString:@"$"]; }
- (NSString *)pound { return [self stringByAppendingString:@"#"]; }
- (NSString *)at { return [self stringByAppendingString:@"@"]; }
- (NSString *)exclamation { return [self stringByAppendingString:@"!"]; }
- (NSString *)back_slash { return [self stringByAppendingString:@"\\"]; }
- (NSString *)forward_slash { return [self stringByAppendingString:@"/"]; }
- (NSString *)curly_left { return [self stringByAppendingString:@"{"]; }
- (NSString *)curly_right { return [self stringByAppendingString:@"}"]; }
- (NSString *)bracket_left { return [self stringByAppendingString:@"["]; }
- (NSString *)bracket_right { return [self stringByAppendingString:@"]"]; }
- (NSString *)bar { return [self stringByAppendingString:@"|"]; }
- (NSString *)less_than { return [self stringByAppendingString:@"<"]; }
- (NSString *)greater_than { return [self stringByAppendingString:@">"]; }
- (NSString *)underscore { return [self stringByAppendingString:@"_"]; }

#pragma mark - Obfuscating Aliases
- (NSString *)_ { return [self space]; }
- (NSString *)dot { return [self point]; }

@end
//################################################################################################################
