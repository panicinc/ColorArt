//
//  ITColorWindow.h
//  ColorArt
//
//  Created by Ilija Tovilo on 12/28/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SLColorArt.h"
#import "PCFadedImageView.h"

@interface ITColorWindow : NSWindow

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet PCFadedImageView *imageView;
@property (weak) IBOutlet NSTextField *primaryField;
@property (weak) IBOutlet NSTextField *secondaryField;
@property (weak) IBOutlet NSTextField *detailField;

@property (strong) NSImage *image;
@property NSRectEdge colorEdge;

@end
