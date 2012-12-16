//
//  CAViewController.m
//  ColorArtiOS
//
//  Created by Fred Leitz on 2012-12-12.
//  Copyright (c) 2012 Fred Leitz. All rights reserved.
//

#import "CAViewController.h"
#import "SLColorArt.h"  
#import "UIImage+Scale.h"
@interface CAViewController ()

@end

@implementation CAViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)colorizeForImage:(UIImage *)image
{
    image = [image scaledToSize:self.fadedImageView.frame.size];
    SLColorArt *colorArt = [[SLColorArt alloc] initWithImage:image scaledSize: self.fadedImageView.frame.size];
    CGRect f = self.fadedImageView.frame;
    f.size = colorArt.scaledImage.size;
    self.fadedImageView.backgroundColor = colorArt.backgroundColor;
    self.fadedImageView.image = colorArt.scaledImage;
    self.view.backgroundColor = colorArt.backgroundColor;
    self.headline.textColor = colorArt.primaryColor;
    self.subHeadline.textColor = colorArt.secondaryColor;
    self.text.textColor = colorArt.detailColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"Beatles-Abbey-Road-album.jpg"];
    //    UIImage *image = [UIImage imageNamed:@"DSC_0062.jpg"];
    
    [self colorizeForImage:image];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickImage)]];
    // Do any additional setup after loading the view from its nib.
}


- (void) pickImage {
    UIImagePickerController* picker = self.imagePicker;
    
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:picker animated:YES];
}

//Tells the delegate that the user picked a still image or movie.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self colorizeForImage:image];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
