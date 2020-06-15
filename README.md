NSUserDefaults+SevenSecurityLayers.h (Obsoleted, this is no longer maintained)
=====================

* A category which provides an encryption layer for NSUserDefaults to securely save data . 
* Using strong AES 356-bit encryption

-------------------------------------
#### Benefit: 
##### * Secure user data just by one line of code.
##### * Support obfuscating your key in binary source
##### * Able to save data without encryption
###### * Enable to handle exceptional case via built-in NOTIFICATION
###### * Enable using standardUserDefaults as well as securedUserDefaults parallelly

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SLWW2XYDATUYS" target="_blank"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" alt="Make donation for Hai Kieu's github"/></a>

-------------------------------------

## How to use

Note: Remember to install dependency first 
 * CocoaSecurity 1.2.4 (https://github.com/kelp404/CocoaSecurity)

-----------------------------------

In the implementation file, import `NSUserDefaults+SevenSecurityLayers.h`
```objective-c
#import "NSUserDefaults+SevenSecurityLayers.h"
```
Initialize a secured UserDefaults with a secret key.
```objective-c

//Recommend: Should put the secret key in implementation file to secure your key.
//Warning: Must specify the secret key before using or you get **Exception**

NSUserDefault *pref = [[NSUserDefault securedUserDefaults] setSecretKey:@"Your secret key"];

// >>> DONE! That's it, a secured storage has been created already for you to save any data later. <<<

```
```objective-c

//Demonstrate saving data

[pref setBool:YES forKey:@"DataIsSecured"];
[pref setString:@"AES 356-bit" forKey:@"KindOfEncryption"];
[pref setString:@"v1.2.0 available" forKey:@"ObfuscateSecretKey"];
[pref setString:@"Able to save data without encryption" forKey:@"KeepOrigin"];
...
[pref synchronize];

```
```objective-c

//Demonstrate retrieving data

bool yourBool = [pref boolForKey:@"DataIsSecured"];
NSString * yourString = [pref stringForKey:@"KindOfEncrytion"];
...

```
### Advanced usage

* **v1.2.0** available

 * **Obfuscate your secret key**

      Shouldn't use this ~~NSString * theSecretKey = @"putYourKeyHere";~~

      Try this way :point_right: `NSString * theSecretKey = @"".p.u.t.Y.o.u.r.K.e.y.H.e.r.e;`

 * **Store data without encryption**

       `[pref setObject:@"yourValue" forKey:@"yourKey.nonSecured"];`
  
       Or
   
       `[pref setObject:@"yourValue" forKey:@"yourKey".nonSecured];`

 * **Migrate data to secured storage**

       `[NSUserDefaults migrate:[NSUserDefaults standardUserDefaults] to:pref clearSource:YES];`

### Supported NOTIFICATION Events

 * `NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA`
 * `NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA`
 * ~~NOTIFICATION_SECRET_KEY_NOT_SET~~
 * ~~NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED~~

### Supported Encryption Types

Seven Security Layers Solution supports the following property types:

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

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SLWW2XYDATUYS" target="_blank"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" alt="Make donation for Hai Kieu's github"/></a>

### Thanks to 

 * https://github.com/nielsmouthaan/SecureNSUserDefaults
 * https://github.com/UrbanApps/UAObfuscatedString

### MIT License

### Dependencies

 * CocoaSecurity 1.2.4 (https://github.com/kelp404/CocoaSecurity)

### Dependencies Installation
1. **git:**
```
$ git clone git://github.com/kelp404/CocoaSecurity.git
$ cd CocoaSecurity
$ git submodule update --init
```

2. **<a href="http://cocoapods.org/?q=CocoaSecurity" target="_blank">CocoadPods</a>:**  
add `Podfile` in your project path
```
platform :ios
pod 'CocoaSecurity'
```
```
$ pod install
```
