//
//  SLColorArt.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SLColorArt : NSObject
@property(strong, nonatomic, readonly) UIColor *backgroundColor;
@property(strong, nonatomic, readonly) UIColor *primaryColor;
@property(strong, nonatomic, readonly) UIColor *secondaryColor;
@property(strong, nonatomic, readonly) UIColor *detailColor;
@property(nonatomic, readonly) NSInteger randomColorThreshold; // Default to 2

- (id)initWithImage:(UIImage*)image;
- (id)initWithImage:(UIImage*)image threshold:(NSInteger)threshold;

+ (void)processImage:(UIImage *)image
        scaledToSize:(CGSize)scaleSize
           threshold:(NSInteger)threshold
          onComplete:(void (^)(SLColorArt *colorArt))completeBlock;

@end
