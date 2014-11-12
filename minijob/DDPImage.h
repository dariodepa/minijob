//
//  DDPImage.h
//  minijob
//
//  Created by Dario De pascalis on 02/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol DDPImageDownloaderDelegate
//- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (void)setProgressBar:(NSIndexPath *)indexPath progress:(float)progress;
- (void)refreshImage:(NSData *)fileData;
@end


@interface DDPImage : NSObject
//@interface DDPLoadImage: NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>
@property (nonatomic, assign) id <DDPImageDownloaderDelegate> delegate;

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) int imageWidth;
@property (nonatomic, assign) int imageHeight;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSIndexPath *indexPathInTableView;


-(void)loadImage:(PFFile *)imageFile;
-(void)saveImage:(NSData *)imageData classParse:(PFObject *)classe;
-(void)saveImageWithoutDelegate:(UIImage *)image nameImage:(NSString *)nameImage key:(NSString *)key;

-(void)customRoundImage:(UIImageView *)customImageView;

+(UIImage *)scaleImage:(UIImage*)image toSize:(CGSize)size;
+(CGSize)fitSize:(CGSize)size intoSize:(CGSize)newSize;
+(UIImage *)scaleAndCropImage:(UIImage *)image intoSize:(CGSize)newSize;
+(void)rotateImageViewWithAnimation:(UIImageView *)imageView duration:(float)duration angle:(float)angle;
+(void)rotateImageView:(UIImageView *)imageView angle:(float)angle;

+(UIImage *)reflectImageHorizontally:(UIImage *)image;
@end
