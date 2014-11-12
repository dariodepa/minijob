//
//  DDPCity.h
//  minijob
//
//  Created by Dario De pascalis on 04/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDPCity : NSObject
@property(nonatomic, strong) NSString *oid;
@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSString *reference;
@property (nonatomic, strong) CLLocation *location;
@end
