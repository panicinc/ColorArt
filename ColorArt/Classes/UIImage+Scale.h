//
//  UIImage+Scale.h
//  ColorArt
//
//  Created by Fred Leitz on 2012-12-15.
//  Copyright (c) 2012 Fred Leitz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)
- (UIImage*) scaledToSize:(CGSize)newSize;
@end