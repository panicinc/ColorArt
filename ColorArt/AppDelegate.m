//
//  AppDelegate.m
//  ColorArt
//
//  Created by Wade Cosgrove on 11/30/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import "AppDelegate.h"
#import <tgmath.h>
#import "SLColorArt.h"
@implementation AppDelegate

- (IBAction)chooseImage:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setPrompt:@"Select"];
	[openPanel setAllowedFileTypes:[NSImage imageTypes]];
	
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	{
		if ( result == NSFileHandlingPanelOKButton )
		{
			NSURL *url = [openPanel URL];
			
			NSImage *image = [[NSImage alloc] initByReferencingURL:url];
			if ( image != nil )
			{
                SLColorArt *colorArt = [[SLColorArt alloc] initWithImage:image];

                self.imageView.image = colorArt.scaledImage;
                self.window.backgroundColor = colorArt.backgroundColor;
                self.primaryField.textColor = colorArt.primaryColor;
                self.secondaryField.textColor = colorArt.secondaryColor;
                self.secondary1Field.textColor = colorArt.detailColor;
			}
		}
	}];
}

@end

