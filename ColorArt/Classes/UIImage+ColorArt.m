//
//  UIImage+ColorArt.m
//  ColorArt
//
//  Created by Fred Leitz on 2012-12-17.
//  Copyright (c) 2012 Fred Leitz. All rights reserved.
//

#import "UIImage+ColorArt.h"
#import "UIImage+Scale.h"
@implementation UIImage (ColorArt)

- (SLColorArt *)colorArt:(CGSize)scale{
    return [[SLColorArt alloc] initWithImage:[self scaledToSize: scale]];
}

- (SLColorArt *)colorArt{
    return [self colorArt:CGSizeMake(512, 512)];
}

@end
