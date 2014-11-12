//
//  DDPStringUtil.h
//  minijob
//
//  Created by Dario De pascalis on 06/07/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDPStringUtil : NSObject

+(BOOL) validEmail:(NSString *) candidate;
+(NSString *)dateFormatter:(NSDate *)date;

@end
