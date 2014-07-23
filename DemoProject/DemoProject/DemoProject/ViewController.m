//
//  ViewController.m
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "NSUserDefaults+SevenSecurityLayers.h"

@interface ViewController ()

@property(nonatomic,weak) NSUserDefaults * pref;

@end

@implementation ViewController

+(void)initialize
{
#ifdef DEBUG
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    
    NSLog(@"%@",documentPath);
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _pref = [NSUserDefaults securedUserDefaults];
    _key1.enabled = _key2.enabled = _key3.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NOTIFICATION_SECRET_KEY_NOT_SET:) name:[NOTIFICATION_SECRET_KEY_NOT_SET copy] object:_pref];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA:) name:[NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA copy] object:_pref];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA:) name:[NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA copy] object:_pref];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED:) name:[NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED copy] object:_pref];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Notification handler

-(void) NOTIFICATION_SECRET_KEY_NOT_SET:(NSNotification*) notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *message = [userInfo messageFromUserInfo];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Exceptional Case" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [alert show];
    
}

-(void) NOTIFICATION_CANNOT_RETRIEVE_ENCRYPTED_DATA:(NSNotification*) notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *message = [userInfo messageFromUserInfo];
    NSString *key = [userInfo keyFromUserInfo];
    NSString *value = [userInfo valueFromUserInfo];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Exceptional Case" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [alert show];
}

-(void) NOTIFICATION_CANNOT_STORE_ENCRYPTED_DATA:(NSNotification*) notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *message =
    [userInfo messageFromUserInfo];
    NSString *key = [userInfo keyFromUserInfo];
    NSString *value = [userInfo valueFromUserInfo];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Exceptional Case" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [alert show];
}

-(void) NOTIFICATION_STORED_DATA_HAS_BEEN_VIOLATED:(NSNotification*) notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *message = [userInfo messageFromUserInfo];
    NSString *key = [userInfo keyFromUserInfo];
    NSString *value = [userInfo valueFromUserInfo];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Exceptional Case" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [alert show];
}

#pragma mark Event Handler

- (IBAction)onTapResetBtn:(id)sender {
    [_pref setObject:@"" forKey:_key1.text];
    [_pref synchronize];
}

- (IBAction)onTapAboutBtn:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About" message:@"https://github.com/haikieu/NSUserDefaults-SevenSecurityLayers" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [alert show];
}

- (IBAction)onTapSetKey:(id)sender {
    _pref = [[NSUserDefaults securedUserDefaults] setSecretKey:_txtSecretKey.text];
}

- (IBAction)onSaveData:(id)sender {
    [self onTapSetKey:nil];
    [_pref setObject:_value1.text forKey:_key1.text];
    [_pref synchronize];
}

- (IBAction)onRetrieveData:(id)sender {
    [self onTapSetKey:nil];
    _value1.text = [_pref stringForKey:_key1.text];
}

- (IBAction)onClearView:(id)sender {
    _value1.text = _value2.text = _value3.text = @"";
}
@end
