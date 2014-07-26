//
//  NSUserDefaults+SecuredUserDefaults.h
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//
//
//  Reference https://github.com/UrbanApps/UAObfuscatedString
//  Reference https://github.com/nielsmouthaan/SecureNSUserDefaults
//

/*
7  security layers solution
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
1) Encrypt data (available)
2) stricted key rule
3) Obfuscate secret key (available)
4) Mutli encryption (On-going)
5) Detect data hijack
6) Bind UserDefault to device hardware
7) Frozen data preference file
 
* Support non-secured storage (done)
* Support iCloud backup (on-going)
* Support migrate (done)
* Detect jailbreak (on-going)
*/

#import <Foundation/Foundation.h>

#define EX_NSSTRING extern const NSString

EX_NSSTRING * NOTIFICATION_SECRET_KEY_NOT_SET __attribute__((deprecated("not support this anymore!")));
EX_NSSTRING * NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA;
EX_NSSTRING * NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA;
EX_NSSTRING * NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED __attribute__((deprecated("not support yet!")));
//################################################################################################################
typedef NS_ENUM(NSInteger, EncryptionAlgorithm)
{
    EncryptionDefault = 1 << 0,
    EncryptionSHA     = 1 << 1,
    EncryptionMD5     = 1 << 2,
    EncryptionAES     = 1 << 3
};

typedef NS_ENUM(NSInteger, iCloudMode)
{
    iCloudDefault = 1 <<0,
    iCloudAll     = 1 <<1
};
//################################################################################################################
@interface NSUserDefaults (SevenSecurityLayers)

+(void) migrate:(NSUserDefaults*) source to:(NSUserDefaults*) destination clear:(BOOL)clear;

+(instancetype) securedUserDefaults;
+(void) resetSecuredUserDefaults;
-(instancetype) setSecretKey:(NSString*) secretKey;
-(instancetype) setEncryption:(EncryptionAlgorithm) encryptionAlgorithm;
-(instancetype) setiCloud:(iCloudMode) iCloudMode;

@end
//################################################################################################################
@interface NSDictionary (SevenSecurityLayers)

-(NSString*) messageFromUserInfo;
-(NSString*) keyFromUserInfo;
-(id) valueFromUserInfo;

@end
//################################################################################################################
@interface NSString (SevenSecurityLayers)

- (NSString *) cloud __attribute__((unavailable("not support yet!")));
- (NSString *) nonSecured;
- (BOOL) isCloud __attribute__((unavailable("not support yet!")));
- (BOOL) isNonSecured;

@end
//################################################################################################################
@interface NSString (UAObfuscatedString)

- (NSString *)a;
- (NSString *)b;
- (NSString *)c;
- (NSString *)d;
- (NSString *)e;
- (NSString *)f;
- (NSString *)g;
- (NSString *)h;
- (NSString *)i;
- (NSString *)j;
- (NSString *)k;
- (NSString *)l;
- (NSString *)m;
- (NSString *)n;
- (NSString *)o;
- (NSString *)p;
- (NSString *)q;
- (NSString *)r;
- (NSString *)s;
- (NSString *)t;
- (NSString *)u;
- (NSString *)v;
- (NSString *)w;
- (NSString *)x;
- (NSString *)y;
- (NSString *)z;

- (NSString *)A;
- (NSString *)B;
- (NSString *)C;
- (NSString *)D;
- (NSString *)E;
- (NSString *)F;
- (NSString *)G;
- (NSString *)H;
- (NSString *)I;
- (NSString *)J;
- (NSString *)K;
- (NSString *)L;
- (NSString *)M;
- (NSString *)N;
- (NSString *)O;
- (NSString *)P;
- (NSString *)Q;
- (NSString *)R;
- (NSString *)S;
- (NSString *)T;
- (NSString *)U;
- (NSString *)V;
- (NSString *)W;
- (NSString *)X;
- (NSString *)Y;
- (NSString *)Z;

- (NSString *)_1;
- (NSString *)_2;
- (NSString *)_3;
- (NSString *)_4;
- (NSString *)_5;
- (NSString *)_6;
- (NSString *)_7;
- (NSString *)_8;
- (NSString *)_9;
- (NSString *)_0;

- (NSString *)_;
- (NSString *)space;
- (NSString *)dot;
- (NSString *)dash;
- (NSString *)comma;
- (NSString *)semicolon;
- (NSString *)colon;
- (NSString *)apostrophe;
- (NSString *)quotation;
- (NSString *)plus;
- (NSString *)equals;
- (NSString *)paren_left;
- (NSString *)paren_right;
- (NSString *)asterisk;
- (NSString *)ampersand;
- (NSString *)caret;
- (NSString *)percent;
- (NSString *)$;
- (NSString *)pound;
- (NSString *)at;
- (NSString *)exclamation;
- (NSString *)back_slash;
- (NSString *)forward_slash;
- (NSString *)curly_left;
- (NSString *)curly_right;
- (NSString *)bracket_left;
- (NSString *)bracket_right;
- (NSString *)bar;
- (NSString *)less_than;
- (NSString *)greater_than;
- (NSString *)underscore;

@end
//################################################################################################################