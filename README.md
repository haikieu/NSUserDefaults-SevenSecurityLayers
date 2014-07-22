NSUserDefaults+SecuredUserDefaults.h 
=====================

* NSUserDefaults category for iOS and Mac OS X with additional methods to securely save data . 
* Using strong AES 356-bit encryption

#Benefit: Secure user data just by a little bit code change. 

---------------------

## How to use

In the implementation file, import NSUserDefaults+SecuredUserDefaults.h

```objective-c
#import "NSUserDefaults+SecuredUserDefaults.h"
```
Access a securedUserDefaults

```objective-c

//Recommend: Should put the secret key in implementation files to secure your key.

[[NSUserDefault securedUserDefaults] setSecretkey:@"Your secret key"];

```

Begin to save some data

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

SecuredNSUserDefaults supports the following property types:

 * NSInteger
 * NSString
 * NSArray
 * string+array
 * NSDictionary
 * NSURL
 * NSData
 * BOOL
 * float
 * double

### Contact

Email: haikieu2907@gmail.com

###Reference solution

https://github.com/nielsmouthaan/SecureNSUserDefaults

### MIT License
