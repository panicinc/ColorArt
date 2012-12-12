//
//  LBGradient.m
//  LBGradient
//
//  Created by Laurin Brandner on 12.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LBGradient.h"

static NSString* const kColorsKey = @"colors";
static NSString* const kLocationsKey = @"locations";

static inline CGFloat* LBGradientLocationsForColors(NSArray* colors) {
    CGFloat* newLocations = malloc(colors.count*sizeof(CGFloat));
    NSUInteger count = colors.count;
    for (unsigned int i = 0; i < count; i++) {
        newLocations[i] = (i) ? (float)i/(float)(count-1) : 0.0f;
    }
    return newLocations;
}

static inline NSArray* LBGradientArrayFromLocations(CGFloat* locations, NSUInteger count) {
    NSMutableArray* locationArray = [NSMutableArray array];
    for (int i = count; i >= 0; i--) {
        [locationArray addObject:[NSNumber numberWithFloat:locations[i]]];
    }
    return locationArray;
}

static inline CGFloat* LBGradientLocationsFromArray(NSArray* locations) {
    CGFloat* newLocations = malloc(locations.count*sizeof(CGFloat));
    for (unsigned int i = 0; i < locations.count; i++) {
        newLocations[i] = [[locations objectAtIndex:i] floatValue];
    }
    return newLocations;
}

static inline CGFloat degreesToRadians (CGFloat i) {
    return (M_PI * (i) / 180.0);
}

@interface LBGradient () {
    CGFloat* locations;
}

@property (nonatomic, copy) NSArray* colors;
@property (nonatomic, assign) CGColorSpaceRef colorSpace;

@end
@implementation LBGradient

@synthesize colors, colorSpace;

#pragma mark Accessors

-(NSUInteger)numberOfColorStops {
    return self.colors.count;
}

-(void)getColor:(UIColor **)color location:(CGFloat *)location atIndex:(NSUInteger)index {
    if (index < self.colors.count) {
        *color = [self.colors objectAtIndex:index];
        *location = locations[index];
    }
}

#pragma mark -
#pragma mark Initialization 

-(id)initWithStartingColor:(UIColor *)startingColor endingColor:(UIColor *)endingColor {
    self = [super init];
    if (self) {
        self.colors = [NSArray arrayWithObjects:startingColor, endingColor, nil];
        self.colorSpace = CGColorSpaceCreateDeviceRGB();
        locations = LBGradientLocationsForColors(self.colors);
    }
    return self;
}

-(id)initWithColors:(NSArray *)colorArray {
    self = [super init];
    if (self) {        
        self.colors = colorArray;
        self.colorSpace = CGColorSpaceCreateDeviceRGB();
        locations = LBGradientLocationsForColors(self.colors);
    }
    return self;
}

-(id)initWithColors:(NSArray *)colorArray atLocations:(CGFloat *)locationValues colorSpace:(CGColorSpaceRef)colorSpaceValue {
    self = [super init];
    if (self) {
        self.colors = colorArray;
        locations = locationValues;
        self.colorSpace = colorSpaceValue;
    }
    return self;
}

-(id)initWithColorsAndLocations:(UIColor *)firstColor, ... {
    self = [super init];
    if (self) {
        NSMutableArray* newColors = [NSMutableArray array];
        va_list arguments;
        va_start(arguments, firstColor);
        locations = malloc(2*sizeof(CGFloat));
        for (UIColor* color = firstColor; color; color=va_arg(arguments, UIColor*)) {
            [newColors addObject:color];
            locations = realloc(locations, newColors.count*sizeof(CGFloat));
            locations[newColors.count-1] = va_arg(arguments, double);
        }
        va_end(arguments);
        
        self.colors = newColors;
        self.colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return self;
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone {
    LBGradient* copy = [[self.class allocWithZone:zone] init];
    copy->locations = self->locations;
    copy.colors = self.colors;
    copy.colorSpace = self.colorSpace;
    
    return copy;
}

#pragma mark -
#pragma mark NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.colors = [aDecoder decodeObjectForKey:kColorsKey];
        locations = LBGradientLocationsFromArray([aDecoder decodeObjectForKey:kLocationsKey]);
        self.colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.colors forKey:kColorsKey];
    [aCoder encodeObject:LBGradientArrayFromLocations(locations, colors.count) forKey:kLocationsKey];
}

#pragma mark -
#pragma mark Memory

-(void)dealloc {
    self.colors = nil;
    free(locations);
    CGColorSpaceRelease(colorSpace);    
}

#pragma mark -
#pragma mark Drawing

-(void)drawFromPoint:(CGPoint)startingPoint toPoint:(CGPoint)endingPoint options:(LBGradientDrawingOptions)options {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CFMutableArrayRef gradientColors = CFArrayCreateMutable(kCFAllocatorDefault, self.colors.count, &kCFTypeArrayCallBacks);
    for (UIColor* color in self.colors) {
        CFArrayAppendValue(gradientColors, color.CGColor);
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace, gradientColors, locations);
    CGContextDrawLinearGradient(context, gradient, startingPoint, endingPoint, options);
    CGGradientRelease(gradient);
    CFRelease(gradientColors);
}

-(void)drawFromCenter:(CGPoint)startCenter radius:(CGFloat)startRadius toCenter:(CGPoint)endCenter radius:(CGFloat)endRadius options:(LBGradientDrawingOptions)options {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CFMutableArrayRef gradientColors = CFArrayCreateMutable(kCFAllocatorDefault, self.colors.count, &kCFTypeArrayCallBacks);
    for (UIColor* color in self.colors) {
        CFArrayAppendValue(gradientColors, color.CGColor);
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace, gradientColors, locations);
    CGContextDrawRadialGradient(context, gradient, startCenter, startRadius, endCenter, endRadius, options);
    CGGradientRelease(gradient);
    CFRelease(gradientColors);
}

-(void)drawInRect:(CGRect)rect angle:(CGFloat)angle {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextRotateCTM(context, -degreesToRadians(angle));
    
    CFMutableArrayRef gradientColors = CFArrayCreateMutable(kCFAllocatorDefault, self.colors.count, &kCFTypeArrayCallBacks);
    for (UIColor* color in self.colors) {
        CFArrayAppendValue(gradientColors, color.CGColor);
    }

    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace, gradientColors, locations);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation|kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    CFRelease(gradientColors);
    CGContextRestoreGState(context);
}

-(void)drawInBezierPath:(UIBezierPath *)path angle:(CGFloat)angle {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [path addClip];
    CGContextClip(context);
    CGContextRotateCTM(context, -degreesToRadians(angle));
    
    CFMutableArrayRef gradientColors = CFArrayCreateMutable(kCFAllocatorDefault, self.colors.count, &kCFTypeArrayCallBacks);
    for (UIColor* color in self.colors) {
        CFArrayAppendValue(gradientColors, color.CGColor);
    }
    
    CGRect bounds = path.bounds;
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
    
    CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace, gradientColors, locations);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation|kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    CFRelease(gradientColors);
    CGContextRestoreGState(context);
}

-(void)drawInRect:(CGRect)rect relativeCenterPosition:(CGPoint)relativeCenterPosition {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    
    CFMutableArrayRef gradientColors = CFArrayCreateMutable(kCFAllocatorDefault, self.colors.count, &kCFTypeArrayCallBacks);
    for (UIColor* color in self.colors) {
        CFArrayAppendValue(gradientColors, color.CGColor);
    }
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat radius = sqrtf(powf(width/2, 2)+powf(height/2, 2));
    
    CGPoint startCenter = CGPointMake(width/2+(width*relativeCenterPosition.x)/2, height/2+(height*relativeCenterPosition.y)/2);
    CGPoint endCenter = CGPointMake(width/2, height/2);
    
    CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace, gradientColors, locations);
    CGContextDrawRadialGradient(context, gradient, startCenter, 0, endCenter, radius, 0);
    CGGradientRelease(gradient);
    CFRelease(gradientColors);
    CGContextRestoreGState(context);
}

-(void)drawInBezierPath:(UIBezierPath *)path relativeCenterPosition:(CGPoint)relativeCenterPosition {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [path addClip];
    CGContextClip(context);
    
    CFMutableArrayRef gradientColors = CFArrayCreateMutable(kCFAllocatorDefault, self.colors.count, &kCFTypeArrayCallBacks);
    for (UIColor* color in self.colors) {
        CFArrayAppendValue(gradientColors, color.CGColor);
    }
    
    CGRect bounds = path.bounds;
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    CGFloat radius = sqrtf(powf(width/2, 2)+powf(height/2, 2));
    
    CGPoint startCenter = CGPointMake(width/2+(width*relativeCenterPosition.x)/2, height/2+(height*relativeCenterPosition.y)/2);
    CGPoint endCenter = CGPointMake(width/2, height/2);
    
    CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace, gradientColors, locations);
    CGContextDrawRadialGradient(context, gradient, startCenter, 0, endCenter, radius, 0);
    CGGradientRelease(gradient);
    CFRelease(gradientColors);
    CGContextRestoreGState(context);
}

#pragma mark -

@end
