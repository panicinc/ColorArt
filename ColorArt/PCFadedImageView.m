//
//  PCFadedImageView.m
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


#import "PCFadedImageView.h"
#import "LBGradient.h"

@implementation PCFadedImageView

@synthesize image = _image;



- (void)drawRect:(CGRect)dirtyRect
{
	CGSize imageSize = [self.image size];
    CGRect bounds = self.bounds;
	CGRect imageRect = CGRectMake(bounds.size.width - imageSize.width, bounds.size.height - imageSize.height, imageSize.width, imageSize.height);

	[self.image drawInRect:imageRect blendMode: kCGBlendModeSourceAtop alpha:1.0];
	// lazy way to get fade color
	UIColor *backgroundColor = self.backgroundColor;
		
	LBGradient *gradient = [[LBGradient alloc] initWithColorsAndLocations:backgroundColor, 0.0, backgroundColor, .01, [backgroundColor colorWithAlphaComponent:0.05], 1.0, nil];
	[gradient drawInRect:imageRect angle:0.0];
}


@end