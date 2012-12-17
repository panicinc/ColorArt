//
//  UIImage+ColorArt.h
//  ColorArt
//
//  Created by Fred Leitz on 2012-12-17.
//  Copyright (c) 2012 Fred Leitz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLColorArt.h"

@interface UIImage (ColorArt)

- (SLColorArt*) colorArt;
- (SLColorArt*) colorArt:(CGSize)scale;

@end
