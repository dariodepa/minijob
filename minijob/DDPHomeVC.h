//
//  DDPHomeVC.h
//  minijob
//
//  Created by Dario De pascalis on 08/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDPApplicationContext;
@interface DDPHomeVC : UIViewController
@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (assign, nonatomic) UIViewController *caller;

- (IBAction)actionSearch:(id)sender;
- (IBAction)actionMySkills:(id)sender;
- (IBAction)unwindToHomeVC:(UIStoryboardSegue*)sender;
@end
