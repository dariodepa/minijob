//
//  DDPCommons.h
//  minijob
//
//  Created by Dario De pascalis on 02/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDPCommons : NSObject

+(void)customizeTitle:(UINavigationItem *)navigationItem;
//BUTTON
+(UIButton *)enableButton:(UIButton *)button;
+(UIButton *)disableButton:(UIButton *)button;

+ (UIColor *)colorWithHexString:(NSString *)colorString;
+ (UIColor *)colorWithHexValue:(int)hexValue;

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
@end
