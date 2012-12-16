//
//  CAViewController.h
//  ColorArtiOS
//
//  Created by Fred Leitz on 2012-12-12.
//  Copyright (c) 2012 Fred Leitz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFadedImageView.h"
@interface CAViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet PCFadedImageView *fadedImageView;
@property (strong, nonatomic) UIImagePickerController* imagePicker;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UILabel *subHeadline;
@property (weak, nonatomic) IBOutlet UILabel *text;

@end
