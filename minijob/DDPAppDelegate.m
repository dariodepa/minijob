//
//  DDPAppDelegate.m
//  minijob
//
//  Created by Dario De pascalis on 25/05/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPAppDelegate.h"
#import "DDPApplicationContext.h"

@implementation DDPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"74BxjEts3p33KzE87t8BcjfA6bvr5ns2UOMjbxR6" clientKey:@"PfaDddxex0lTGtTJHtTDQeNzlRBmNVqkzeUlXbjv"];
    [PFFacebookUtils initializeFacebook];
    //[PFTwitterUtils initializeWithConsumerKey:@"your_twitter_consumer_key" consumerSecret:@"your_twitter_consumer_secret"];
    // Set default ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[DemoTableViewController alloc] init]];
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];

    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if (![defaults stringForKey:@"chatName"]) {
//        // first time it's run, create a userDefault
//        [defaults setObject:@"Chat Name" forKey:@"chatName"];
//        [defaults synchronize];
//    }
    
    
    DDPApplicationContext *context = [[DDPApplicationContext alloc] init];
    self.applicationContext = context;
    
    [self.applicationContext setConstantsPlist];
    return YES;
}


// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


@end
