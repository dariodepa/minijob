//
//  DDPImage.m
//  minijob
//
//  Created by Dario De pascalis on 02/06/14.
//  Copyright (c) 2014 Dario De Pascalis. All rights reserved.
//

#import "DDPImage.h"

@implementation DDPImage



-(void)loadImage:(PFFile *)imageFile
{
    NSLog(@"loadImage: %@", imageFile);
    [imageFile getDataInBackgroundWithBlock:^(NSData *fileData, NSError *error) {
        if (!error) {
            //PFFile *image = [PFFile fileWithName:@"image Profile" data:fileData];
            [self.delegate refreshImage:fileData];
        }
        else{
            NSLog(@"error: %@", error);
        }
    } progressBlock:^(int percentDone) {
        float progress=percentDone/100;
        NSLog(@"progress %f", progress);
        [self.delegate setProgressBar:nil progress:progress];
    }];
}


-(void)saveImage:(NSData *)imageData classParse:(PFObject *)classe
{
    PFFile *image = [PFFile fileWithName:@"imageProfile" data:imageData];
    [[PFUser currentUser] setObject:image forKey:@"imageProfile"];
    [[PFUser currentUser] saveInBackground];
}

-(void)saveImageWithoutDelegate:(UIImage *)image nameImage:(NSString *)nameImage key:(NSString *)key{
    NSLog(@"saveImageWithoutDelegate %@ - %@", nameImage, key);

    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:nameImage data:imageData];
    [[PFUser currentUser] setObject:imageFile forKey:key];
    [[PFUser currentUser] saveInBackground];
}

-(void)customRoundImage:(UIImageView *)customImageView
{
    customImageView.layer.cornerRadius = customImageView.frame.size.height/2;
    customImageView.layer.masksToBounds = YES;
    customImageView.layer.borderWidth = 2;
    customImageView.layer.borderColor = [UIColor whiteColor].CGColor;
}




+(UIImage *)scaleImage:(UIImage*)image toSize:(CGSize)size {
    CGSize newSizeWithAspectRatio = [DDPImage fitSize:image.size intoSize:size];
    
    UIGraphicsBeginImageContext(newSizeWithAspectRatio);
    [image drawInRect:CGRectMake(0, 0, newSizeWithAspectRatio.width, newSizeWithAspectRatio.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(CGSize)fitSize:(CGSize)size intoSize:(CGSize)newSize {
    CGSize scaledSize = size;
    
    // first scale on width
    float hScaleFactor;
    if (scaledSize.width > newSize.width) {
        hScaleFactor = newSize.width / size.width;
        scaledSize.width = size.width * hScaleFactor;
        scaledSize.height = size.height * hScaleFactor;
    }
    
    // then scale on height
    float vScaleFactor;
    if (scaledSize.height > newSize.height) {
        vScaleFactor = newSize.height / scaledSize.height;
        scaledSize.height = scaledSize.height * vScaleFactor;
        //        scaledSize.width = newSize.width / vScaleFactor;
        scaledSize.width = scaledSize.width * vScaleFactor;
    }
    return scaledSize;
}


+(UIImage *)scaleAndCropImage:(UIImage *)image intoSize:(CGSize)newSize {
    //SCALE
    CGSize size = image.size;
    float pWidth;
    float pHeight;
    pHeight = newSize.width * size.height / size.width;
    pWidth = newSize.width;
    if(pHeight<newSize.height){
        pWidth = newSize.height * size.width / size.height;
        pHeight = newSize.height;
    }
    size.height = pHeight;
    size.width = pWidth;
    //CROOP
    float posX = (newSize.width-size.width)/2;
    float posY = (newSize.height-size.height)/2;
    UIGraphicsBeginImageContext(newSize);//CGSizeMake(140, 140)
    
    [image drawInRect: CGRectMake(posX, posY, pWidth, pHeight)];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
    
    
//    CGSize size = image.size;
//    float hScaleFactor;
//    float vScaleFactor;
//    vScaleFactor = newSize.height / size.height;
//    hScaleFactor = newSize.width / size.width;
//    if(vScaleFactor<hScaleFactor){
//        size.height = newSize.height;
//        size.width = size.width * vScaleFactor;
//    }else{
//        size.width = newSize.width;
//        size.height = size.height * hScaleFactor;
//    }
//    //CROOP
//    float posX = (newSize.width-size.width)/2;
//    float posY = (newSize.height-size.height)/2;
//    UIGraphicsBeginImageContext(newSize);//CGSizeMake(140, 140)
//    
//    [image drawInRect: CGRectMake(posX, posY, newSize.width, newSize.height)];
//    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

}

+(void)rotateImageView:(UIImageView *)imageView angle:(float)angle{
    imageView.transform = CGAffineTransformMakeRotation(angle*M_PI/180);
}

+(void)rotateImageViewWithAnimation:(UIImageView *)imageView duration:(float)duration angle:(float)angle{
    
    [UIView animateWithDuration: duration
                          delay: 0.5
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         imageView.transform = CGAffineTransformMakeRotation(angle*M_PI/180);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:duration animations:^{
                             //imageView.transform = CGAffineTransformMakeRotation(angle*M_PI/180);
                         }];
                     }];
}

+ (UIImage *)reflectImageHorizontally:(UIImage *)image
{
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationLeftMirrored];
}

@end
