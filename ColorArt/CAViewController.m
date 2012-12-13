//
//  CAViewController.m
//  ColorArtiOS
//
//  Created by Fred Leitz on 2012-12-12.
//  Copyright (c) 2012 Fred Leitz. All rights reserved.
//

#import "CAViewController.h"
#import "SLColorArt.h"  

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"DSC_0062.jpg"];
    SLColorArt *colorArt = [[SLColorArt alloc] initWithImage:image scaledSize:self.fadedImageView.frame.size];
    
    self.fadedImageView.image = colorArt.scaledImage;
    self.fadedImageView.backgroundColor = colorArt.backgroundColor;
    self.view.backgroundColor = colorArt.backgroundColor;
    self.headline.textColor = colorArt.primaryColor;
    self.subHeadline.textColor = colorArt.secondaryColor;
    self.text.textColor = colorArt.detailColor;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
