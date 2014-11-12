//
//  DDPAppDelegate.h
//  minijob
//
//  Created by Dario De pascalis on 25/05/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDPApplicationContext;

@interface DDPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDPApplicationContext *applicationContext;

@end
