//
//  AppDelegate.h
//  ColorArt
//
//  Created by Wade Cosgrove on 11/30/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kAnalyzedBackgroundColor @"kAnalyzedBackgroundColor"
#define kAnalyzedPrimaryColor @"kAnalyzedPrimaryColor"
#define kAnalyzedSecondaryColor @"kAnalyzedSecondaryColor"
#define kAnalyzedDetailColor @"kAnalyzedDetailColor"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSTextField *primaryField;
@property (assign) IBOutlet NSTextField *secondaryField;
@property (assign) IBOutlet NSTextField *secondary1Field;

- (NSDictionary*)analyzeImage:(NSImage*)anImage;

@end


@interface NSColor (DarkAddition)

- (BOOL)pc_isDarkColor;
- (BOOL)pc_isDistinct:(NSColor*)compareColor;
- (NSColor*)pc_colorWithMinimumSaturation:(CGFloat)saturation;
- (BOOL)pc_isBlackOrWhite;
- (BOOL)pc_isContrastingColor:(NSColor*)color;

@end


@interface PCCountedColor : NSObject

@property (assign) NSUInteger count;
@property (retain) NSColor *color;

- (id)initWithColor:(NSColor*)color count:(NSUInteger)count;

@end