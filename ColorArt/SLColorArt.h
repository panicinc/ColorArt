//
//  SLColorArt.h
//  ColorArt
//
//  Created by Aaron Brethorst on 12/11/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLColorArt : NSObject
@property(copy, readonly) NSColor *backgroundColor;
@property(copy, readonly) NSColor *primaryColor;
@property(copy, readonly) NSColor *secondaryColor;
@property(copy, readonly) NSColor *detailColor;
@property(nonatomic, copy) NSImage *scaledImage;

- (id)initWithImage:(NSImage*)image scaledSize:(NSSize)size;
@end
