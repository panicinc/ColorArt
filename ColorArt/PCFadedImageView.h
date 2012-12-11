//
//  PCFadedImageView.h
//  ColorArt
//
//  Created by Wade Cosgrove on 12/4/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCFadedImageView : NSView
{
	NSImage *_image;
}

@property (retain) NSImage *image;

@end