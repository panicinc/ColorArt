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
#import "UIImage+Scale.h"
#define kAnalyzedBackgroundColor @"kAnalyzedBackgroundColor"
#define kAnalyzedPrimaryColor @"kAnalyzedPrimaryColor"
#define kAnalyzedSecondaryColor @"kAnalyzedSecondaryColor"
#define kAnalyzedDetailColor @"kAnalyzedDetailColor"



@interface UIColor (DarkAddition)

- (BOOL)pc_isDarkColor;
- (BOOL)pc_isDistinct:(UIColor*)compareColor;
- (UIColor*)pc_colorWithMinimumSaturation:(CGFloat)saturation;
- (BOOL)pc_isBlackOrWhite;
- (BOOL)pc_isContrastingColor:(UIColor*)color;

@end


@interface PCCountedColor : NSObject

@property (assign) NSUInteger count;
@property (strong) UIColor *color;

- (id)initWithColor:(UIColor*)color count:(NSUInteger)count;

@end

@interface SLColorArt ()
@property(nonatomic, copy) UIImage *image;
@property(nonatomic,readwrite,strong) UIColor *backgroundColor;
@property(nonatomic,readwrite,strong) UIColor *primaryColor;
@property(nonatomic,readwrite,strong) UIColor *secondaryColor;
@property(nonatomic,readwrite,strong) UIColor *detailColor;
@property(nonatomic,readwrite) NSInteger randomColorThreshold;
@end

@implementation SLColorArt

- (id)initWithImage:(UIImage*)image
{
    self = [self initWithImage:image threshold:2];
    if (self) {

    }
    return self;
}

- (id)initWithImage:(UIImage*)image threshold:(NSInteger)threshold;
{
    self = [super init];

    if (self)
    {
        self.randomColorThreshold = threshold;
        self.image = image;
        [self _processImage];
    }

    return self;
}


+ (void)processImage:(UIImage *)image
        scaledToSize:(CGSize)scaleSize
           threshold:(NSInteger)threshold
          onComplete:(void (^)(SLColorArt *colorArt))completeBlock;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *scaledImage = [image scaledToSize:scaleSize];
        SLColorArt *colorArt = [[SLColorArt alloc] initWithImage:scaledImage
                                                       threshold:threshold];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(colorArt);
        });
    });
    
}

- (void)_processImage
{
    //UIImage *finalImage = [self _scaleImage:self.image size:self.scaledSize];

    NSDictionary *colors = [self _analyzeImage:self.image];

    self.backgroundColor = [colors objectForKey:kAnalyzedBackgroundColor];
    self.primaryColor = [colors objectForKey:kAnalyzedPrimaryColor];
    self.secondaryColor = [colors objectForKey:kAnalyzedSecondaryColor];
    self.detailColor = [colors objectForKey:kAnalyzedDetailColor];

    //self.scaledImage = finalImage;
}

- (UIImage*)_scaleImage:(UIImage*)image size:(CGSize)scaledSize
{
    return [image scaledToSize:scaledSize];
//    CGSize imageSize = [image size];
//    UIImage *squareImage = [[UIImage alloc] initWithSize:CGSizeMake(imageSize.width, imageSize.width)];
//    UIImage *scaledImage = [[UIImage alloc] initWithSize:scaledSize];
//    CGRect drawRect;
//
//    // make the image square
//    if ( imageSize.height > imageSize.width )
//    {
//        drawRect = CGRectMake(0, imageSize.height - imageSize.width, imageSize.width, imageSize.width);
//    }
//    else
//    {
//        drawRect = CGRectMake(0, 0, imageSize.height, imageSize.height);
//    }
//
//  //  [squareImage lockFocus];
//    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.width)];
//  //  [squareImage unlockFocus];
//
//    // scale the image to the desired size
//
//  //  [scaledImage lockFocus];
//    [squareImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
//  //  [scaledImage unlockFocus];
//
//    // convert back to readable bitmap data
//
//    
//    UIImage *finalImage = [[UIImage alloc] initWithCGImage:scaledImage.CGImage];
//    return finalImage;
}

- (NSDictionary*)_analyzeImage:(UIImage*)anImage
{
    NSCountedSet *imageColors = nil;
	UIColor *backgroundColor = [self _findEdgeColor:anImage imageColors:&imageColors];
	UIColor *primaryColor = nil;
	UIColor *secondaryColor = nil;
	UIColor *detailColor = nil;
    
    // If the random color threshold is too high and the image size too small,
    // we could miss detecting the background color and crash.
    if ( backgroundColor == nil )
    {
        backgroundColor = [UIColor whiteColor];
    }
    
	BOOL darkBackground = [backgroundColor pc_isDarkColor];

	[self _findTextColors:imageColors primaryColor:&primaryColor secondaryColor:&secondaryColor detailColor:&detailColor backgroundColor:backgroundColor];

	if ( primaryColor == nil )
	{
		NSLog(@"missed primary");
		if ( darkBackground )
			primaryColor = [UIColor whiteColor];
		else
			primaryColor = [UIColor blackColor];
	}

	if ( secondaryColor == nil )
	{
		NSLog(@"missed secondary");
		if ( darkBackground )
			secondaryColor = [UIColor whiteColor];
		else
			secondaryColor = [UIColor blackColor];
	}

	if ( detailColor == nil )
	{
		NSLog(@"missed detail");
		if ( darkBackground )
			detailColor = [UIColor whiteColor];
		else
			detailColor = [UIColor blackColor];
	}

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [dict setObject:backgroundColor forKey:kAnalyzedBackgroundColor];
    [dict setObject:primaryColor forKey:kAnalyzedPrimaryColor];
    [dict setObject:secondaryColor forKey:kAnalyzedSecondaryColor];
    [dict setObject:detailColor forKey:kAnalyzedDetailColor];


    return [NSDictionary dictionaryWithDictionary:dict];
}

typedef struct RGBAPixel
{
    Byte red;
    Byte green;
    Byte blue;
    Byte alpha;
    
} RGBAPixel;

- (UIColor*)_findEdgeColor:(UIImage*)image imageColors:(NSCountedSet**)colors
{
	CGImageRef imageRep = image.CGImage;

//	if ( ![imageRep isKindOfClass:[NSBitmapImageRep class]] ) // sanity check
//		return nil;
    NSInteger width = CGImageGetWidth(imageRep);// [imageRep pixelsWide];
	NSInteger height = CGImageGetHeight(imageRep); //[imageRep pixelsHigh];

    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, cs, kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image.CGImage);
    CGColorSpaceRelease(cs);
    NSCountedSet* imageColors = [[NSCountedSet alloc] initWithCapacity:width * height];
    NSCountedSet* edgeColors = [[NSCountedSet alloc] initWithCapacity:height];
    const RGBAPixel* pixels = (const RGBAPixel*)CGBitmapContextGetData(bmContext);
    for (NSUInteger y = 0; y < height; y++)
    {
        for (NSUInteger x = 0; x < width; x++)
        {
            const NSUInteger index = x + y * width;
            RGBAPixel pixel = pixels[index];
            UIColor* color = [[UIColor alloc] initWithRed:((CGFloat)pixel.red / 255.0f) green:((CGFloat)pixel.green / 255.0f) blue:((CGFloat)pixel.blue / 255.0f) alpha:1.0f];
            if (0 == x)
                [edgeColors addObject:color];
            [imageColors addObject:color];
        }
    }
    CGContextRelease(bmContext);


	*colors = imageColors;


	NSEnumerator *enumerator = [edgeColors objectEnumerator];
	UIColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[edgeColors count]];

	while ( (curColor = [enumerator nextObject]) != nil )
	{
		NSUInteger colorCount = [edgeColors countForObject:curColor];

		if ( colorCount <= self.randomColorThreshold ) // prevent using random colors, threshold should be based on input image size
			continue;

		PCCountedColor *container = [[PCCountedColor alloc] initWithColor:curColor count:colorCount];

		[sortedColors addObject:container];
	}

	[sortedColors sortUsingSelector:@selector(compare:)];


	PCCountedColor *proposedEdgeColor = nil;

	if ( [sortedColors count] > 0 )
	{
		proposedEdgeColor = [sortedColors objectAtIndex:0];

		if ( [proposedEdgeColor.color pc_isBlackOrWhite] ) // want to choose color over black/white so we keep looking
		{
			for ( NSInteger i = 1; i < [sortedColors count]; i++ )
			{
				PCCountedColor *nextProposedColor = [sortedColors objectAtIndex:i];

				if (((double)nextProposedColor.count / (double)proposedEdgeColor.count) > .4 ) // make sure the second choice color is 40% as common as the first choice
				{
					if ( ![nextProposedColor.color pc_isBlackOrWhite] )
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


- (void)_findTextColors:(NSCountedSet*)colors primaryColor:(UIColor**)primaryColor secondaryColor:(UIColor**)secondaryColor detailColor:(UIColor**)detailColor backgroundColor:(UIColor*)backgroundColor
{
	NSEnumerator *enumerator = [colors objectEnumerator];
	UIColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[colors count]];
	BOOL findDarkTextColor = ![backgroundColor pc_isDarkColor];

	while ( (curColor = [enumerator nextObject]) != nil )
	{
		curColor = [curColor pc_colorWithMinimumSaturation:.15];

		if ( [curColor pc_isDarkColor] == findDarkTextColor )
		{
			NSUInteger colorCount = [colors countForObject:curColor];

			//if ( colorCount <= 2 ) // prevent using random colors, threshold should be based on input image size
			//	continue;

			PCCountedColor *container = [[PCCountedColor alloc] initWithColor:curColor count:colorCount];

			[sortedColors addObject:container];
		}
	}

	[sortedColors sortUsingSelector:@selector(compare:)];

	for ( PCCountedColor *curContainer in sortedColors )
	{
		curColor = curContainer.color;

		if ( *primaryColor == nil )
		{
			if ( [curColor pc_isContrastingColor:backgroundColor] )
				*primaryColor = curColor;
		}
		else if ( *secondaryColor == nil )
		{
			if ( ![*primaryColor pc_isDistinct:curColor] || ![curColor pc_isContrastingColor:backgroundColor] )
				continue;

			*secondaryColor = curColor;
		}
		else if ( *detailColor == nil )
		{
			if ( ![*secondaryColor pc_isDistinct:curColor] || ![*primaryColor pc_isDistinct:curColor] || ![curColor pc_isContrastingColor:backgroundColor] )
				continue;
            
			*detailColor = curColor;
			break;
		}
	}
}

@end

@implementation UIColor (DarkAddition)

- (BOOL)pc_isDarkColor
{
	UIColor *convertedColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
	CGFloat r, g, b, a;

	[convertedColor getRed:&r green:&g blue:&b alpha:&a];

	CGFloat lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;

	if ( lum < .5 )
	{
		return YES;
	}

	return NO;
}


- (BOOL)pc_isDistinct:(UIColor*)compareColor
{
	UIColor *convertedColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	UIColor *convertedCompareColor = compareColor;//[compareColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
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


- (UIColor*)pc_colorWithMinimumSaturation:(CGFloat)minSaturation
{
	UIColor *tempColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	if ( tempColor != nil )
	{
		CGFloat hue = 0.0;
		CGFloat saturation = 0.0;
		CGFloat brightness = 0.0;
		CGFloat alpha = 0.0;

		[tempColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

		if ( saturation < minSaturation )
		{
			return [UIColor colorWithHue:hue saturation:minSaturation brightness:brightness alpha:alpha];
		}
	}

	return self;
}


- (BOOL)pc_isBlackOrWhite
{
	UIColor *tempColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

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


- (BOOL)pc_isContrastingColor:(UIColor*)color
{
	UIColor *backgroundColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	UIColor *foregroundColor = color;//[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

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

		//return contrast > 3.0; //3-4.5
		return contrast > 1.6;
	}

	return YES;
}


@end


@implementation PCCountedColor

- (id)initWithColor:(UIColor*)color count:(NSUInteger)count
{
	self = [super init];

	if ( self )
	{
		self.color = color;
		self.count = count;
	}

	return self;
}

- (NSComparisonResult)compare:(PCCountedColor*)object
{
	if ( [object isKindOfClass:[PCCountedColor class]] )
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
