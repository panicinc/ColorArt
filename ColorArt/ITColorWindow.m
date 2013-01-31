//
//  ITColorWindow.m
//  ColorArt
//
//  Created by Ilija Tovilo on 12/28/12.
//  Copyright (c) 2012 Wade Cosgrove. All rights reserved.
//

#import "ITColorWindow.h"

@implementation ITColorWindow

- (IBAction)chooseImage:(id)sender
{    
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setPrompt:@"Select"];
	[openPanel setAllowedFileTypes:[NSImage imageTypes]];
	
	[openPanel beginSheetModalForWindow:self completionHandler:^(NSInteger result)
     {
         if ( result == NSFileHandlingPanelOKButton )
         {
             NSURL *url = [openPanel URL];
             
             NSImage *image = [[NSImage alloc] initByReferencingURL:url];
             if ( image != nil )
             {
                 SLColorArt *colorArt = [[SLColorArt alloc] initWithImage:image scaledSize:NSMakeSize(320., 320.) edge:self.colorEdge];
                 
                 self.imageView.image = colorArt.scaledImage;
                 self.backgroundColor = colorArt.backgroundColor;
                 self.primaryField.textColor = colorArt.primaryColor;
                 self.secondaryField.textColor = colorArt.secondaryColor;
                 self.detailField.textColor = colorArt.detailColor;
                 self.imageView.fade = colorArt.shouldFade;
             }
         }
     }];
    
    [self.imageView setFadingEdge:self.colorEdge];
}

@end
