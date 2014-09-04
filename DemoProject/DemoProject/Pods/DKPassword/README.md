# DKPassword

DKPassword is a simple password strength checker written in Objective-C. 

## Adding to Your Project

Simply add the following to your Podfile, if you're using CocoaPods:

```ruby
pod 'DKPassword'
```

DKPassword **requires ARC**.

## Working with the DKPassword

Just call this method, it will return password strength, on scale from 0 to 100. 

```objective-c
+(int)passwordStrength:(NSString*)password;
```