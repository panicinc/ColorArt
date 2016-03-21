//
//  SLColorArt.m
//  ColorArt
//
//  Created by Aaron Brethorst on 12/11/12.
//
// Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//
// Redistribution and use, with or without modification, are permitted provided that the following conditions are met:
//
// - Redistributions must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
// - Neither the name of Panic Inc nor the names of its contributors may be used to endorse or promote works derived from this software without specific prior written permission from Panic Inc.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL PANIC INC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "SLColorArt.h"

#define kColorThresholdMinimumPercentage 0.01

@interface NSColor (SLDarkAddition)

- (BOOL)sl_isDarkColor;
- (BOOL)sl_isDistinct:(NSColor*)compareColor;
- (NSColor*)sl_colorWithMinimumSaturation:(CGFloat)saturation;
- (BOOL)sl_isBlackOrWhite;
- (BOOL)sl_isContrastingColor:(NSColor*)color;

@end


@interface SLCountedColor : NSObject

@property (assign) NSUInteger count;
@property (strong) NSColor *color;

- (id)initWithColor:(NSColor*)color count:(NSUInteger)count;

@end


@interface SLColorArt ()

@property NSSize scaledSize;
@property(retain,readwrite) NSColor *backgroundColor;
@property(retain,readwrite) NSColor *primaryColor;
@property(retain,readwrite) NSColor *secondaryColor;
@property(retain,readwrite) NSColor *detailColor;
@end


@implementation SLColorArt

- (id)initWithImage:(NSImage*)image scaledSize:(NSSize)size
{
    self = [super init];

    if (self)
    {
        self.scaledSize = size;
		
		NSImage *finalImage = [self scaleImage:image size:size];
		self.scaledImage = finalImage;
		
		[self analyzeImage:image];
    }

    return self;
}


- (NSImage*)scaleImage:(NSImage*)image size:(NSSize)scaledSize
{
    NSSize imageSize = [image size];
    NSImage *squareImage = [[NSImage alloc] initWithSize:NSMakeSize(imageSize.width, imageSize.width)];
    NSImage *scaledImage = [[NSImage alloc] initWithSize:scaledSize];
    NSRect drawRect;

    // make the image square
    if ( imageSize.height > imageSize.width )
    {
        drawRect = NSMakeRect(0, imageSize.height - imageSize.width, imageSize.width, imageSize.width);
    }
    else
    {
        drawRect = NSMakeRect(0, 0, imageSize.height, imageSize.height);
    }

    [squareImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.width) fromRect:drawRect operation:NSCompositeSourceOver fraction:1.0];
    [squareImage unlockFocus];

    // scale the image to the desired size

    [scaledImage lockFocus];
    [squareImage drawInRect:NSMakeRect(0, 0, scaledSize.width, scaledSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [scaledImage unlockFocus];

    // convert back to readable bitmap data

    CGImageRef cgImage = [scaledImage CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    NSImage *finalImage = [[NSImage alloc] initWithSize:scaledImage.size];
    [finalImage addRepresentation:bitmapRep];
    return finalImage;
}

- (void)analyzeImage:(NSImage*)anImage
{
    NSCountedSet *imageColors = nil;
	NSColor *backgroundColor = [self findEdgeColor:anImage imageColors:&imageColors];
	NSColor *primaryColor = nil;
	NSColor *secondaryColor = nil;
	NSColor *detailColor = nil;
	BOOL darkBackground = [backgroundColor sl_isDarkColor];

	[self findTextColors:imageColors primaryColor:&primaryColor secondaryColor:&secondaryColor detailColor:&detailColor backgroundColor:backgroundColor];

	if ( primaryColor == nil )
	{
		NSLog(@"missed primary");
		if ( darkBackground )
			primaryColor = [NSColor whiteColor];
		else
			primaryColor = [NSColor blackColor];
	}

	if ( secondaryColor == nil )
	{
		NSLog(@"missed secondary");
		if ( darkBackground )
			secondaryColor = [NSColor whiteColor];
		else
			secondaryColor = [NSColor blackColor];
	}

	if ( detailColor == nil )
	{
		NSLog(@"missed detail");
		if ( darkBackground )
			detailColor = [NSColor whiteColor];
		else
			detailColor = [NSColor blackColor];
	}

    self.backgroundColor = backgroundColor;
    self.primaryColor = primaryColor;
	self.secondaryColor = secondaryColor;
    self.detailColor = detailColor;
}

- (NSColor*)findEdgeColor:(NSImage*)image imageColors:(NSCountedSet**)colors
{
	NSImageRep *imageRep = [[image representations] lastObject];

	if ( ![imageRep isKindOfClass:[NSBitmapImageRep class]] ) // sanity check
		return nil;

	NSInteger pixelsWide = [imageRep pixelsWide];
	NSInteger pixelsHigh = [imageRep pixelsHigh];

	NSCountedSet *imageColors = [[NSCountedSet alloc] initWithCapacity:pixelsWide * pixelsHigh];
	NSCountedSet *leftEdgeColors = [[NSCountedSet alloc] initWithCapacity:pixelsHigh];

	for ( NSUInteger x = 0; x < pixelsWide; x++ )
	{
		for ( NSUInteger y = 0; y < pixelsHigh; y++ )
		{
			NSColor *color = [(NSBitmapImageRep*)imageRep colorAtX:x y:y];

			if ( x == 0 )
			{
				[leftEdgeColors addObject:color];
			}

			[imageColors addObject:color];
		}
	}

	*colors = imageColors;


	NSEnumerator *enumerator = [leftEdgeColors objectEnumerator];
	NSColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[leftEdgeColors count]];

	while ( (curColor = [enumerator nextObject]) != nil )
	{
		NSUInteger colorCount = [leftEdgeColors countForObject:curColor];

        NSInteger randomColorsThreshold = (NSInteger)(pixelsHigh * kColorThresholdMinimumPercentage);
        
		if ( colorCount <= randomColorsThreshold ) // prevent using random colors, threshold based on input image height
			continue;

		SLCountedColor *container = [[SLCountedColor alloc] initWithColor:curColor count:colorCount];

		[sortedColors addObject:container];
	}

	[sortedColors sortUsingSelector:@selector(compare:)];


	SLCountedColor *proposedEdgeColor = nil;

	if ( [sortedColors count] > 0 )
	{
		proposedEdgeColor = [sortedColors objectAtIndex:0];

		if ( [proposedEdgeColor.color sl_isBlackOrWhite] ) // want to choose color over black/white so we keep looking
		{
			for ( NSInteger i = 1; i < [sortedColors count]; i++ )
			{
				SLCountedColor *nextProposedColor = [sortedColors objectAtIndex:i];

				if (((double)nextProposedColor.count / (double)proposedEdgeColor.count) > .3 ) // make sure the second choice color is 30% as common as the first choice
				{
					if ( ![nextProposedColor.color sl_isBlackOrWhite] )
					{
						proposedEdgeColor = nextProposedColor;
						break;
					}
				}
				else
				{
					// reached color threshold less than 40% of the original proposed edge color so bail
					break;
				}
			}
		}
	}

	return proposedEdgeColor.color;
}


- (void)findTextColors:(NSCountedSet*)colors primaryColor:(NSColor**)primaryColor secondaryColor:(NSColor**)secondaryColor detailColor:(NSColor**)detailColor backgroundColor:(NSColor*)backgroundColor
{
	NSEnumerator *enumerator = [colors objectEnumerator];
	NSColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[colors count]];
	BOOL findDarkTextColor = ![backgroundColor sl_isDarkColor];

	while ( (curColor = [enumerator nextObject]) != nil )
	{
		curColor = [curColor sl_colorWithMinimumSaturation:.15];

		if ( [curColor sl_isDarkColor] == findDarkTextColor )
		{
			NSUInteger colorCount = [colors countForObject:curColor];

			//if ( colorCount <= 2 ) // prevent using random colors, threshold should be based on input image size
			//	continue;

			SLCountedColor *container = [[SLCountedColor alloc] initWithColor:curColor count:colorCount];

			[sortedColors addObject:container];
		}
	}

	[sortedColors sortUsingSelector:@selector(compare:)];

	for ( SLCountedColor *curContainer in sortedColors )
	{
		curColor = curContainer.color;

		if ( *primaryColor == nil )
		{
			if ( [curColor sl_isContrastingColor:backgroundColor] )
				*primaryColor = curColor;
		}
		else if ( *secondaryColor == nil )
		{
			if ( ![*primaryColor sl_isDistinct:curColor] || ![curColor sl_isContrastingColor:backgroundColor] )
				continue;

			*secondaryColor = curColor;
		}
		else if ( *detailColor == nil )
		{
			if ( ![*secondaryColor sl_isDistinct:curColor] || ![*primaryColor sl_isDistinct:curColor] || ![curColor sl_isContrastingColor:backgroundColor] )
				continue;
            
			*detailColor = curColor;
			break;
		}
	}
}

@end


@implementation NSColor (SLDarkAddition)

- (BOOL)sl_isDarkColor
{
	NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat r, g, b, a;

	[convertedColor getRed:&r green:&g blue:&b alpha:&a];

	CGFloat lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;

	if ( lum < .5 )
	{
		return YES;
	}

	return NO;
}


- (BOOL)sl_isDistinct:(NSColor*)compareColor
{
	NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	NSColor *convertedCompareColor = [compareColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat r, g, b, a;
	CGFloat r1, g1, b1, a1;

	[convertedColor getRed:&r green:&g blue:&b alpha:&a];
	[convertedCompareColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];

	CGFloat threshold = .25; //.15

	if ( fabs(r - r1) > threshold ||
		fabs(g - g1) > threshold ||
		fabs(b - b1) > threshold ||
		fabs(a - a1) > threshold )
    {
        // check for grays, prevent multiple gray colors

        if ( fabs(r - g) < .03 && fabs(r - b) < .03 )
        {
            if ( fabs(r1 - g1) < .03 && fabs(r1 - b1) < .03 )
                return NO;
        }

        return YES;
    }

	return NO;
}


- (NSColor*)sl_colorWithMinimumSaturation:(CGFloat)minSaturation
{
	NSColor *tempColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	if ( tempColor != nil )
	{
		CGFloat hue = 0.0;
		CGFloat saturation = 0.0;
		CGFloat brightness = 0.0;
		CGFloat alpha = 0.0;

		[tempColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

		if ( saturation < minSaturation )
		{
			return [NSColor colorWithCalibratedHue:hue saturation:minSaturation brightness:brightness alpha:alpha];
		}
	}

	return self;
}


- (BOOL)sl_isBlackOrWhite
{
	NSColor *tempColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	if ( tempColor != nil )
	{
		CGFloat r, g, b, a;

		[tempColor getRed:&r green:&g blue:&b alpha:&a];

		if ( r > .91 && g > .91 && b > .91 )
			return YES; // white

		if ( r < .09 && g < .09 && b < .09 )
			return YES; // black
	}

	return NO;
}


- (BOOL)sl_isContrastingColor:(NSColor*)color
{
	NSColor *backgroundColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	NSColor *foregroundColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	if ( backgroundColor != nil && foregroundColor != nil )
	{
		CGFloat br, bg, bb, ba;
		CGFloat fr, fg, fb, fa;

		[backgroundColor getRed:&br green:&bg blue:&bb alpha:&ba];
		[foregroundColor getRed:&fr green:&fg blue:&fb alpha:&fa];

		CGFloat bLum = 0.2126 * br + 0.7152 * bg + 0.0722 * bb;
		CGFloat fLum = 0.2126 * fr + 0.7152 * fg + 0.0722 * fb;

		CGFloat contrast = 0.;

		if ( bLum > fLum )
			contrast = (bLum + 0.05) / (fLum + 0.05);
		else
			contrast = (fLum + 0.05) / (bLum + 0.05);

		//return contrast > 3.0; //3-4.5 W3C recommends 3:1 ratio, but that filters too many colors
		return contrast > 1.6;
	}

	return YES;
}


@end


@implementation SLCountedColor

- (id)initWithColor:(NSColor*)color count:(NSUInteger)count
{
	self = [super init];

	if ( self )
	{
		self.color = color;
		self.count = count;
	}

	return self;
}

- (NSComparisonResult)compare:(SLCountedColor*)object
{
	if ( [object isKindOfClass:[SLCountedColor class]] )
	{
		if ( self.count < object.count )
		{
			return NSOrderedDescending;
		}
		else if ( self.count == object.count )
		{
			return NSOrderedSame;
		}
	}
    
	return NSOrderedAscending;
}


@end
