//
//  ViewController.m
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "NSUserDefaults+SecuredUserDefaults.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapResetBtn:(id)sender {
    [_pref setObject:@"" forKey:_key1.text];
    [_pref setObject:@"" forKey:_key2.text];
    [_pref setObject:@"" forKey:_key3.text];
    [_pref synchronize];
}

- (IBAction)onTapAboutBtn:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About" message:@"https://github.com/haikieu/NSUserDefaults-SecuredUserDefaults" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [alert show];
}

- (IBAction)onTapSetKey:(id)sender {
    _pref = [[NSUserDefaults securedUserDefaults] setSecretKey:_txtSecretKey.text];
}

- (IBAction)onSaveData:(id)sender {
    [self onTapSetKey:nil];
    [_pref setObject:_value1.text forKey:_key1.text];
    [_pref setObject:_value2.text forKey:_key2.text];
    [_pref setObject:_value3.text forKey:_key3.text];
    [_pref synchronize];
}

- (IBAction)onRetrieveData:(id)sender {
    [self onTapSetKey:nil];
    _value1.text = [_pref stringForKey:_key1.text];
    _value2.text = [_pref stringForKey:_key2.text];
    _value3.text = [_pref stringForKey:_key3.text];
}

- (IBAction)onClearView:(id)sender {
    _value1.text = _value2.text = _value3.text = @"";
}
@end
