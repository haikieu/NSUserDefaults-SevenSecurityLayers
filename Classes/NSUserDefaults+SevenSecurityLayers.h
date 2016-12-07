//
//  NSUserDefaults+SecuredUserDefaults.h
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//
//

/*
7  security layers solution
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
1) Encrypt data (available)
2) stricted key rule
3) Obfuscate secret key, hide secret key in binary code (available)
3) Hash key, protect secret key in runtime (available)
4) Mutli encryption (On-going)
5) Detect data hijack (done)
6) Bind UserDefault to device hardware (done))
7) Frozen data preference file

* support multi notification handling model (done)
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
EX_NSSTRING * NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED;

typedef NS_ENUM(NSInteger, NotificationSecurity)
{
    NotificationSecretKeyNotSet    = 1,
    NotificationCannotRetrieveData = 2,
    NotificationCannotStoreData    = 3,
    NotificationDataIsViolated     = 4
};

//################################################################################################################
typedef NS_OPTIONS(NSInteger, CombineEncryption)
{
    CombineDefault = 1 << 0,
    CombineSHA     = 1 << 1,
    CombineMD5     = 1 << 2,
    CombineAES     = 1 << 3
};

typedef NS_OPTIONS(NSInteger, iCloudMode)
{
    iCloudDefault = 1 <<0,
    iCloudAll     = 1 <<1
};
@class CocoaSecurityResult;
typedef id (^ EncryptionAlgorimth)(NSString *key, NSObject *value, CocoaSecurityResult *secretKey, CocoaSecurityResult * UUID);
typedef id (^ DecryptionAlgorimth)(NSString *key, NSData *data, CocoaSecurityResult * secretKey, CocoaSecurityResult * UUID);
//################################################################################################################
NSString* UUID();

@interface NSUserDefaults (SevenSecurityLayers)

+(void) migrate:(NSUserDefaults*) source to:(NSUserDefaults*) destination clearSource:(BOOL)clear;

+(instancetype) securedUserDefaults;
+(void) resetSecuredUserDefaults;
-(instancetype) setSecretKey:(NSString*) secretKey;
-(instancetype) setUUID:(NSString *)UUID;
-(instancetype) setCombination:(CombineEncryption) combination;
-(instancetype) setiCloud:(iCloudMode) iCloudMode;
-(instancetype) setEncryption:(EncryptionAlgorimth)encryptBlock decryption:(DecryptionAlgorimth) decryptBlock;

@end
//################################################################################################################
@interface NSDictionary (SevenSecurityLayers)

-(NotificationSecurity) notificationFromUserInfo;
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

/*
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Urban Apps
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Reference https://github.com/UrbanApps/UAObfuscatedString
 
 */

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

- (NSString *)_A;
- (NSString *)_B;
- (NSString *)_C;
- (NSString *)_D;
- (NSString *)_E;
- (NSString *)_F;
- (NSString *)_G;
- (NSString *)_H;
- (NSString *)_I;
- (NSString *)_J;
- (NSString *)_K;
- (NSString *)_L;
- (NSString *)_M;
- (NSString *)_N;
- (NSString *)_O;
- (NSString *)_P;
- (NSString *)_Q;
- (NSString *)_R;
- (NSString *)_S;
- (NSString *)_T;
- (NSString *)_U;
- (NSString *)_V;
- (NSString *)_W;
- (NSString *)_X;
- (NSString *)_Y;
- (NSString *)_Z;

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
