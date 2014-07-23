//
//  ViewController.h
//  DemoProject
//
//  Created by Hai Kieu on 7/22/14.
//  Copyright (c) 2014 haikieu2907@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)onTapResetBtn:(id)sender;

- (IBAction)onTapAboutBtn:(id)sender;

- (IBAction)onTapSetKey:(id)sender;

- (IBAction)onSaveData:(id)sender;

- (IBAction)onRetrieveData:(id)sender;

- (IBAction)onClearView:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *txtSecretKey;
@property (strong, nonatomic) IBOutlet UITextField *key1;
@property (strong, nonatomic) IBOutlet UITextField *key2;
@property (strong, nonatomic) IBOutlet UITextField *key3;
@property (strong, nonatomic) IBOutlet UITextField *value1;
@property (strong, nonatomic) IBOutlet UITextField *value2;
@property (strong, nonatomic) IBOutlet UITextField *value3;


@end
