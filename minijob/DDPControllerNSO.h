//
//  DDPControllerNSO.h
//  minijob
//
//  Created by Dario De pascalis on 10/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDPApplicationContext;

@interface DDPControllerNSO : NSObject

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property (assign, nonatomic) UIViewController *callerViewController;


-(void)checkAutenticate:(NSString *)SESSION_TOKEN;
-(void)checkPreload;

@end

