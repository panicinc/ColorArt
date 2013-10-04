//
//  AppDelegate.m
//  ColorArt
//
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


#import "AppDelegate.h"
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
                dispatch_queue_t async = dispatch_queue_create("com.colorart", DISPATCH_QUEUE_SERIAL);
                dispatch_async(async, ^{
                    SLColorArt *colorArt = [[SLColorArt alloc] initWithImage:image scaledSize:NSMakeSize(320., 320.)];
                    self.imageView.image = colorArt.scaledImage;
                    self.window.backgroundColor = colorArt.backgroundColor;
                    self.primaryField.textColor = colorArt.primaryColor;
                    self.secondaryField.textColor = colorArt.secondaryColor;
                    self.detailField.textColor = colorArt.detailColor;
                });
			}
		}
	}];
}

@end

