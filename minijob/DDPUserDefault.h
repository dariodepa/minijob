//
//  DDPUserDefault.h
//  minijob2
//
//  Created by Dario De pascalis on 07/08/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDPCity;

@interface DDPUserDefault : NSObject


+ (void)saveCustomObject:(DDPCity *)object key:(NSString *)key;
+ (DDPCity *)loadCustomObjectWithKey:(NSString *)key;
@end
