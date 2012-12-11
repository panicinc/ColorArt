//
//  AppDelegate.h
//  ColorArt
//
//  Created by Wade Cosgrove on 11/30/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSTextField *primaryField;
@property (assign) IBOutlet NSTextField *secondaryField;
@property (assign) IBOutlet NSTextField *secondary1Field;
@end