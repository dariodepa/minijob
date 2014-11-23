//
//  DDPCommons.m
//  minijob
//
//  Created by Dario De pascalis on 02/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPCommons.h"
#import "DDPPreloadVC.h"

@implementation DDPCommons

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//FUNZIONI GRAFICA
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
+(void)customizeTitle:(UINavigationItem *)navigationItem {
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    navigationItem.titleView = titleLogo;
    navigationItem.title = nil;
}

+(UIButton *)enableButton:(UIButton *)button{
    button.enabled = YES;
    [button setAlpha:1];
    return button;
}

+(UIButton *)disableButton:(UIButton *)button{
    button.enabled = NO;
    [button setAlpha:0.75];
    return button;
}

+ (UIColor *)colorWithHexString:(NSString *)colorString
{
    colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if (colorString.length == 3)
        colorString = [NSString stringWithFormat:@"%c%c%c%c%c%c",
                       [colorString characterAtIndex:0], [colorString characterAtIndex:0],
                       [colorString characterAtIndex:1], [colorString characterAtIndex:1],
                       [colorString characterAtIndex:2], [colorString characterAtIndex:2]];
    
    if (colorString.length == 6)
    {
        int r, g, b;
        sscanf([colorString UTF8String], "%2x%2x%2x", &r, &g, &b);
        return [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    }
    return nil;
}

+ (UIColor *)colorWithHexValue:(int)hexValue
{
    float red   = ((hexValue & 0xFF0000) >> 16)/255.0;
    float green = ((hexValue & 0xFF00) >> 8)/255.0;
    float blue  = (hexValue & 0xFF)/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//FUNZIONI ELABORAZIONI DATE
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++//

+ (float)convertKmToMeters:(float)km{
    return (km*1000);
}

@end
