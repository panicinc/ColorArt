//
//  PCFadedImageView.m
//  ColorArt
//
//  Created by Wade Cosgrove on 12/4/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import "PCFadedImageView.h"

@implementation PCFadedImageView

@synthesize image = _image;

- (void)dealloc
{
	[_image release];
	[super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
	NSSize imageSize = [self.image size];
    NSRect bounds = self.bounds;
	NSRect imageRect = NSMakeRect(bounds.size.width - imageSize.width, bounds.size.height - imageSize.height, imageSize.width, imageSize.height);

	[self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

	// lazy way to get fade color
	NSColor *backgroundColor = [[self window] backgroundColor];
		
	NSGradient *gradient = [[[NSGradient alloc] initWithColorsAndLocations:backgroundColor, 0.0, backgroundColor, .01, [backgroundColor colorWithAlphaComponent:0.05], 1.0, nil] autorelease];

	[gradient drawInRect:imageRect angle:0.0];
}


@end