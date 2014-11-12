//
//  DDPControllerNSO.m
//  minijob
//
//  Created by Dario De pascalis on 10/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPControllerNSO.h"
#import "DDPApplicationContext.h"
#import "DDPAuthenticationVC.h"

@implementation DDPControllerNSO

//*******************************************************************//
//METODI AUTHENTICATION
//*******************************************************************//
- (void)checkAutenticate:(NSString *)SESSION_TOKEN{
   NSLog(@"SESSION_TOKEN : %@", SESSION_TOKEN);
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_TOKEN];
    NSLog(@"initialize current user ----> : %@", sessionToken);
    if (!sessionToken) {
        NSLog(@"toLogin %@",self);
        [self goToAuthentication];
    }
    //[self goToAuthentication];
}

-(void)deleteSessionToken:(NSString *)SESSION_TOKEN{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SESSION_TOKEN];
    [defaults synchronize];
}

-(void)goToAuthentication{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    UIViewController *authController = [storyboard instantiateViewControllerWithIdentifier:@"IDtoAuthenticationVC"];
    [self.callerViewController presentViewController:authController animated:NO completion:nil];
}
//*******************************************************************//


//*******************************************************************//
//METODI PRELOAD
//*******************************************************************//
- (void)checkPreload{
        NSLog(@"controllPreload");
        bool preload = 0;
        NSArray *ARRAY_PRELOAD =  [self.applicationContext.constantsPlist valueForKey:@"ARRAY_PRELOAD"];
        NSString *LAST_LOADED_CATEGORIES = [self.applicationContext.constantsPlist valueForKey:@"LAST_LOADED_CATEGORIES"];
        NSString *LAST_MY_POSITION = [self.applicationContext.constantsPlist valueForKey:@"LAST_MY_POSITION"];
        //NSLog(@"array %@",[self.applicationContext getVariable:LAST_LOADED_CATEGORIES]);
        
        for (NSString *keyControll in ARRAY_PRELOAD){
            if([keyControll isEqualToString:@"LAST_LOADED_CATEGORIES"]){
                if(![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]){
                    preload = 1;
                }else{
                    NSLog(@"LAST_LOADED_CATEGORIES: %@",[self.applicationContext getVariable:LAST_LOADED_CATEGORIES]);
                }
            }
            else if([keyControll isEqualToString:@"MY_POSITION"]){
                if(![self.applicationContext getVariable:LAST_MY_POSITION]){
                    preload = 1;
                }else{
                    NSLog(@"LAST_MY_POSITION: %@",[self.applicationContext getVariable:LAST_MY_POSITION]);
                }
            }
            NSLog(@"keyControll: %@, %d",keyControll, preload);
        }
        if(preload == 1){
            [self goToPreload];
        }
}

-(void)goToPreload{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Preload" bundle:nil];
    UIViewController *preloadController = [storyboard instantiateViewControllerWithIdentifier:@"IDtoPreloadVC"];
    [self.callerViewController presentViewController:preloadController animated:NO completion:nil];
}
//*******************************************************************//

@end
