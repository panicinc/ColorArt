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

#define kColorThresholdMinimumPercentage 0.001
#define kColorThresholdMaximumercentageForFading 0.8
#define kAnalyzingSize NSMakeSize(128, 128)
#define kEdgeMargin kAnalyzingSize.width * 0.1


// ----------------------------------------------------
#pragma mark - NSImage Additions
// ----------------------------------------------------

@interface NSImage (Additions)
- (NSBitmapImageRep *)bitmapImageRepresentation;
- (NSImage *)scaledImageWithSize:(NSSize)size;
@end

@implementation NSImage (Additions)

- (NSBitmapImageRep *)bitmapImageRepresentation {
    int width = [self size].width;
    int height = [self size].height;
    
    if(width < 1 || height < 1)
        return nil;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes: NULL
                             pixelsWide: width
                             pixelsHigh: height
                             bitsPerSample: 8
                             samplesPerPixel: 4
                             hasAlpha: YES
                             isPlanar: NO
                             colorSpaceName: NSDeviceRGBColorSpace
                             bytesPerRow: width * 4
                             bitsPerPixel: 32];
    
    NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep: rep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: ctx];
    [self drawAtPoint: NSZeroPoint fromRect: NSZeroRect operation: NSCompositeCopy fraction: 1.0];
    [ctx flushGraphics];
    [NSGraphicsContext restoreGraphicsState];
    
    return rep;
}

- (NSImage *)scaledImageWithSize:(NSSize)size {
    if (NSEqualSizes(self.size, NSZeroSize)) return nil;
    
    NSSize imageSize = self.size;
    NSImage *squareImage = [[NSImage alloc] initWithSize:NSMakeSize(imageSize.width, imageSize.width)];
    NSImage *scaledImage = [[NSImage alloc] initWithSize:size];
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
    [self drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.width) fromRect:drawRect operation:NSCompositeSourceOver fraction:1.0];
    [squareImage unlockFocus];
    
    // scale the image to the desired size
    
    [scaledImage lockFocus];
    [self drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [scaledImage unlockFocus];
    
    // convert back to readable bitmap data
    
    CGImageRef cgImage = [scaledImage CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    NSImage *finalImage = [[NSImage alloc] initWithSize:scaledImage.size];
    [finalImage addRepresentation:bitmapRep];
    
    return finalImage;
}

@end



// ----------------------------------------------------
#pragma mark - NSColor Additions
// ----------------------------------------------------

@implementation NSColor (DarkAddition)

- (BOOL)pc_isDarkColor
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

- (CGFloat)pc_distinctionBetweenColor:(NSColor *)compareColor
{
    NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	NSColor *convertedCompareColor = [compareColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat r, g, b, a;
	CGFloat r1, g1, b1, a1;
    
	[convertedColor getRed:&r green:&g blue:&b alpha:&a];
	[convertedCompareColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
	return (fabs(r - r1) + fabs(g - g1) + fabs(b - b1)) / 3.f;
}

- (BOOL)pc_isDistinct:(NSColor*)compareColor
{
	NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	NSColor *convertedCompareColor = [compareColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat r, g, b, a;
	CGFloat r1, g1, b1, a1;
    
	[convertedColor getRed:&r green:&g blue:&b alpha:&a];
	[convertedCompareColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
	CGFloat threshold = .15f;
    
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


- (NSColor *)pc_colorWithMinimumSaturation:(CGFloat)minSaturation
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


- (BOOL)pc_isBlackOrWhite
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


- (BOOL)pc_isContrastingColor:(NSColor*)color
{
    return [self pc_contrastOnBackgroundColor:color] > 0.3f;
}

- (CGFloat)pc_contrastOnBackgroundColor:(NSColor *)backgroundColor {
    backgroundColor = [backgroundColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	NSColor *foregroundColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    CGFloat br, bg, bb;
    CGFloat fr, fg, fb;
    
    [backgroundColor getRed:&br green:&bg blue:&bb alpha:nil];
    [foregroundColor getRed:&fr green:&fg blue:&fb alpha:nil];
    
    return (fabs(br - fr) + fabs(bg - fg) + fabs(bb - fb)) / 3.f;
}

- (CGFloat)pc_colorStandardDeviation {
    CGFloat r, g, b;
    [[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:nil];
    
    float average = (r + g + b) / 3.f;
    return (fabs(average - r) + fabs(average - g) + fabs(average - b)) / 3.f;
}


@end



// ----------------------------------------------------
#pragma mark - PCCountedColor
// ----------------------------------------------------

@interface PCCountedColor : NSObject

@property (assign) NSUInteger count;
@property (strong) NSColor *color;

- (id)initWithColor:(NSColor*)color count:(NSUInteger)count;

@end


@implementation PCCountedColor

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

- (CGFloat)orderBy {
    return self.count * (25.f + (0.75f * self.color.pc_colorStandardDeviation));
}

- (NSString *)description {
    return [NSString localizedStringWithFormat:@"<%@ %ldx r:%f g:%f b:%f>",
            NSStringFromClass(self.class), self.count, self.color.redComponent, self.color.greenComponent, self.color.blueComponent];
}


@end



// ----------------------------------------------------
#pragma mark - SLColorArt
// ----------------------------------------------------

@implementation SLColorArt
@synthesize textColors = _textColors;
@synthesize edgeColor = _edgeColor;

- (id)initWithImage:(NSImage *)image
               edge:(NSRectEdge)edge
 numberOfTextColors:(int)numberOfTextColors
{
    self = [super init];
    
    if (self)
    {
		[self analyzeImage:[image scaledImageWithSize:kAnalyzingSize]
                      edge:edge
        numberOfTextColors:numberOfTextColors];
    }
    
    return self;
}

- (void)analyzeImage:(NSImage *)image
                edge:(NSRectEdge)edge
  numberOfTextColors:(int)numberOfTextColors
{
    NSCountedSet *colors = nil;
    NSCountedSet *edgeColors = nil;
    NSArray *textColors;
    NSColor *edgeColor = nil;
    BOOL shouldFade;
    
	[self extractColors:&colors
             edgeColors:&edgeColors
                 ofEdge:edge
              fromImage:image];
    
    [self findEdgeColor:&edgeColor
             shouldFade:&shouldFade
               inColors:edgeColors];
    
    
	[self find:numberOfTextColors
    textColors:&textColors
withBackgroundColor:edgeColor
      inColors:colors];
    
    _edgeColor = edgeColor;
    _textColors = textColors;
    self.shouldFade = shouldFade;
}

- (void)extractColors:(NSCountedSet **)colors
           edgeColors:(NSCountedSet **)edgeColors
               ofEdge:(NSRectEdge)edge
            fromImage:(NSImage *)image
{
    NSBitmapImageRep *imageRep = [image bitmapImageRepresentation];
    
	if ( ![imageRep isKindOfClass:[NSBitmapImageRep class]] ) return;
    
	NSInteger pixelsWide = imageRep.pixelsWide;
	NSInteger pixelsHigh = imageRep.pixelsHigh;
    
	NSCountedSet *tempColors = [[NSCountedSet alloc] initWithCapacity:pixelsWide * pixelsHigh];
	NSCountedSet *tempEdgeColors = [[NSCountedSet alloc] initWithCapacity:pixelsHigh];
    
	for (NSUInteger x = 0; x < pixelsWide; x++)
	{
		for (NSUInteger y = 0; y < pixelsHigh; y++)
		{
			NSColor *color = [imageRep colorAtX:x y:y];
            CGFloat r, g, b, a;
            [color getRed:&r green:&g blue:&b alpha:&a];
            
            float roundBy = 0.1f;
            
            color = [NSColor colorWithCalibratedRed:round(r / roundBy) * roundBy
                                              green:round(g / roundBy) * roundBy
                                               blue:round(b / roundBy) * roundBy
                                              alpha:round(a / roundBy) * roundBy];
            
            BOOL flag = NO;
            
            switch (edge) {
                case NSMinXEdge:
                {
                    if (x < kEdgeMargin) flag = YES;
                }
                    break;
                    
                case NSMaxXEdge:
                {
                    if (x > (pixelsWide - kEdgeMargin)) flag = YES;
                }
                    break;
                    
                case NSMinYEdge:
                {
                    if (y < kEdgeMargin) flag = YES;
                }
                    break;
                    
                case NSMaxYEdge:
                {
                    if (y > (pixelsHigh - kEdgeMargin)) flag = YES;
                }
                    break;
            }
            
            if (flag) {
                [tempEdgeColors addObject:color];
            }
			
			[tempColors addObject:color];
		}
	}
    
	*colors = tempColors;
    *edgeColors = tempEdgeColors;
}

- (void)findEdgeColor:(NSColor **)edgeColor
           shouldFade:(BOOL *)shouldFade
             inColors:(NSCountedSet *)edgeColors
{
	NSEnumerator *enumerator = [edgeColors objectEnumerator];
	NSColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[edgeColors count]];
    
    NSUInteger numberOfEdgePixels = 0;
    for (PCCountedColor *edgeColor in edgeColors) numberOfEdgePixels += [edgeColors countForObject:edgeColor];
    
	while ( (curColor = [enumerator nextObject]) != nil )
	{
		NSUInteger colorCount = [edgeColors countForObject:curColor];
        
        NSInteger randomColorsThreshold = (NSInteger)(numberOfEdgePixels * kColorThresholdMinimumPercentage);
        
		if ( colorCount <= randomColorsThreshold ) // prevent using random colors, threshold based on input image height
			continue;
        
		PCCountedColor *container = [[PCCountedColor alloc] initWithColor:curColor count:colorCount];
        
		[sortedColors addObject:container];
	}
    
	[sortedColors sortUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"orderBy" ascending:NO]
    ]];
    
	PCCountedColor *proposedEdgeColor = sortedColors.firstObject;
    *edgeColor = (proposedEdgeColor.color.alphaComponent != 0.f) ? proposedEdgeColor.color : NSColor.whiteColor;
    
    // Check if the color needs to fade
    *shouldFade = (proposedEdgeColor.count / (double)numberOfEdgePixels <= kColorThresholdMaximumercentageForFading);
}

- (void)find:(int)numberOf
  textColors:(NSArray **)textColors
withBackgroundColor:(NSColor *)backgroundColor
    inColors:(NSCountedSet *)colors
{
    NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[colors count]];
    
    NSUInteger numberOfPixels = 0;
    for (PCCountedColor *color in colors) numberOfPixels += [colors countForObject:color];
    
    for (NSColor *currentColor in colors)
    {
            NSUInteger colorCount = [colors countForObject:currentColor];
			PCCountedColor *container = [[PCCountedColor alloc] initWithColor:currentColor count:colorCount];
			[sortedColors addObject:container];
    }
    
    [sortedColors sortUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"orderBy" ascending:NO]
    ]];
    
    NSMutableArray *tempTextColors = [NSMutableArray arrayWithCapacity:numberOf];
    NSUInteger currentNumberOfColors = 0;
    
    for (PCCountedColor *currentContainer in sortedColors)
	{
		NSColor *currentColor = currentContainer.color;
        
        if ([currentColor pc_isContrastingColor:backgroundColor]) {
            BOOL isDistinct = YES;
            
            for (int previousColorIndex = 0; previousColorIndex < currentNumberOfColors; previousColorIndex++)
            {
                CGFloat distinction = [currentColor pc_distinctionBetweenColor:tempTextColors[previousColorIndex]];
                
                if (distinction < 0.02f || distinction > 0.5f) isDistinct = NO;
            }
            
            if (!isDistinct) continue;
            
            tempTextColors[currentNumberOfColors++] = currentColor;
            
            if (currentNumberOfColors == numberOf) break;
        }
	}
    
    for (NSUInteger index = 0; index < numberOf; index++) {
        if (index >= tempTextColors.count) {
            if (index > 0) {
                NSColor *previousColor = tempTextColors[index - 1];
                tempTextColors[index] = [previousColor colorWithAlphaComponent:fmax(previousColor.alphaComponent - 0.25f, 0.4f)];
            } else {
                tempTextColors[index] = backgroundColor.pc_isDarkColor ? NSColor.whiteColor : NSColor.blackColor;
            }
        }
    }
    
    [tempTextColors sortUsingComparator:^NSComparisonResult(NSColor *obj1, NSColor *obj2) {
        CGFloat contrast1 = [obj1 pc_contrastOnBackgroundColor:backgroundColor];
        CGFloat contrast2 = [obj2 pc_contrastOnBackgroundColor:backgroundColor];
        
        if (contrast1 < contrast2)
            return NSOrderedDescending;
        else if (contrast1 == contrast2)
            return NSOrderedSame;
        
        return NSOrderedAscending;
    }];
    
    *textColors = tempTextColors;
}

@end
