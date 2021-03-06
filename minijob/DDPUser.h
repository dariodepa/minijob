//
//  DDPUser.h
//  minijob
//
//  Created by Dario De pascalis on 03/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DDPCity;
@class DDPApplicationContext;

@protocol DDPUserDelegate
- (void)getUserImageProfileReturn:(PFFile *)fileData;
- (void)removeUserImageProfileReturn;
- (void)loadUserProfileReturn:(PFObject *)object;
- (void)countAdsReturn:(int)count;
- (void)loadSkillsReturn:(NSArray *)arraySkills;
- (void)responderCountSkills:(int)count;
- (void)responder;
- (NSString *)responderId;
@end



@interface DDPUser : NSObject

@property (strong, nonatomic) DDPApplicationContext *applicationContext;
@property(nonatomic, assign) id <DDPUserDelegate> delegate;
//@property(nonatomic, assign) id <DDPUserDelegateSkills> delegateSkills;
@property(strong, nonatomic) NSString *userOid;
@property(strong, nonatomic) NSString *facebookId;
@property(strong, nonatomic) NSDate *birthday;
@property(strong, nonatomic) NSString *first_name;
@property(strong, nonatomic) NSString *last_name;
@property(strong, nonatomic) NSString *location;
@property(strong, nonatomic) CLLocation *position;
@property(strong, nonatomic) NSNumber *radius;
@property(strong, nonatomic) NSString *sex;
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) PFFile *imageProfile;
@property(strong, nonatomic) NSString *username;
@property(strong, nonatomic) NSString *telephone;





-(void)getImageProfile:(PFUser *)user forDelegate:(id<DDPUserDelegate>)delegate;
-(void)removeImageProfile:(PFUser *)user socialId:(NSString *)socialId forDelegate:(id<DDPUserDelegate>)delegate;

//DDPUserDelegateSkills
-(void)loadUserProfile:(NSString *)idProfile;
-(void)addSkillToProfile:(NSString *)categoryID;
-(void)removeSkillToProfile:(NSString *)categoryID;
-(void)removeSkillToProfileUsingId:(NSString *)skillID;
-(void)loadSkills:(PFUser *)user;
-(void)countSkills:(PFUser *)user;
-(void)countAds:(PFUser *)user;


@end
