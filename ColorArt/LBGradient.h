//
//  LBGradient.h
//  LBGradient
//
//  Created by Laurin Brandner on 12.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _LBGradientDrawingOptions {
    LBGradientDrawsBeforeStartingLocation =   (1 << 0),
    LBGradientDrawsAfterEndingLocation =    (1 << 1),
} LBGradientDrawingOptions;


@interface LBGradient : NSObject <NSCopying, NSCoding> {
    @private
    NSArray* colors;
    CGColorSpaceRef colorSpace;
}

@property (nonatomic, readonly) CGColorSpaceRef colorSpace;
@property (nonatomic, readonly) NSUInteger numberOfColorStops;

// Initialization

-(id)initWithStartingColor:(UIColor *)startingColor endingColor:(UIColor *)endingColor;
-(id)initWithColors:(NSArray *)colorArray;
-(id)initWithColorsAndLocations:(UIColor *)firstColor, ... NS_REQUIRES_NIL_TERMINATION;
-(id)initWithColors:(NSArray *)colorArray atLocations:(CGFloat *)locations colorSpace:(CGColorSpaceRef)colorSpace;

// Drawing
-(void)drawFromPoint:(CGPoint)startingPoint toPoint:(CGPoint)endingPoint options:(LBGradientDrawingOptions)options;
-(void)drawFromCenter:(CGPoint)startCenter radius:(CGFloat)startRadius toCenter:(CGPoint)endCenter radius:(CGFloat)endRadius options:(LBGradientDrawingOptions)options;
-(void)drawInRect:(CGRect)rect angle:(CGFloat)angle;
-(void)drawInBezierPath:(UIBezierPath *)path angle:(CGFloat)angle;
-(void)drawInRect:(CGRect)rect relativeCenterPosition:(CGPoint)relativeCenterPosition;
-(void)drawInBezierPath:(UIBezierPath *)path relativeCenterPosition:(CGPoint)relativeCenterPosition;

// Designated Accessors
-(void)getColor:(UIColor **)color location:(CGFloat *)location atIndex:(NSUInteger)index;
//-(UIColor *)interpolatedColorAtLocation:(CGFloat)location; TODO

@end
