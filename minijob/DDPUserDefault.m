//
//  DDPUserDefault.m
//  minijob2
//
//  Created by Dario De pascalis on 07/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPUserDefault.h"
#import "DDPCity.h"

@implementation DDPUserDefault

+ (void)saveCustomObject:(DDPCity *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

+ (DDPCity *)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    DDPCity *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}


@end
