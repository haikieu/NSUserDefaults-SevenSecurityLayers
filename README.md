SecuredNSUserDefaults 
=====================

NSUserDefaults category for iOS and Mac OS X with additional methods to securely save data using strong AES 356-bit encryption. Especially, secure user data with just a little bit code change.

## How to use

In the implementation file, import NSUserDefaults+SecuredUserDefaults.h

```objective-c
#import "NSUserDefaults+SecuredUserDefaults.h"
```
Access a securedUserDefaults

```objective-c

//Recommend: Should put your secret key in any header file to secure your key.

[[NSUserDefault securedUserDefaults] setSecretkey:@"Your secret key"];

```

Store data

```objective-c

NSUserDefault *pref = [[NSUserDefault securedUserDefaults] setSecretkey:@"Your secret key"];

[pref setBool:YES forKey:@"DataIsSecured"];
[pref setString:@"AES 356-bit" forKey:@"KindOfEncrytion"];

[pref synchronize];

```
Retrieve data

```objective-c

bool yourBool = [pref boolForKey:@"DataIsSecured"];
NSString * yourString = [pref stringForKey:@"KindOfEncrytion"];

```

### Supported Property Types

PAPreferences supports the following property types:

 * NSInteger
 * NSString
 * NSArray
 * NSDictionary
 * NSURL
 * NSData
 * BOOL
 * float
 * double

### Contact

###Reference solution

https://github.com/nielsmouthaan/SecureNSUserDefaults


### MIT License
