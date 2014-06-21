//
//  DSMultilineLabelNode.m
//  DSMultilineLabelNode
//
//  Created by Chris Allwein on 2/12/14.
//  Copyright (c) 2014 Downright Simple. All rights reserved.
//
//  This software is licensed under an MIT-style license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "DSMultilineLabelNode.h"

@implementation DSMultilineLabelNode

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        
        self.fontColor = [SKColor whiteColor];
        self.fontName = @"ComicNeue-Regular";
        self.fontSize = 32.0;
        
        self.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
        
        [self retexture];
    }
    
    return self;

}

- (instancetype)initWithFontNamed:(NSString *)fontName
{
    self = [self init];
    
    if (self) {
        self.fontName = fontName;
    }
    
    return self;
}

+ (instancetype)labelNodeWithFontNamed:(NSString *)fontName
{
    DSMultilineLabelNode *node = [[DSMultilineLabelNode alloc] initWithFontNamed:fontName];
    
    return node;
}

#pragma mark setters for SKLabelNode properties

-(void) setFontColor:(SKColor *)fontColor
{
    _fontColor = fontColor;
    [self retexture];
}

-(void) setFontName:(NSString *)fontName
{
    _fontName = fontName;
    [self retexture];
}

-(void) setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self retexture];
}

-(void) setHorizontalAlignmentMode:(SKLabelHorizontalAlignmentMode)horizontalAlignmentMode
{
    _horizontalAlignmentMode = horizontalAlignmentMode;
    [self retexture];
}

-(void) setText:(NSString *)text
{
    _text = text;
    [self retexture];
}

-(void) setVerticalAlignmentMode:(SKLabelVerticalAlignmentMode)verticalAlignmentMode
{
    _verticalAlignmentMode = verticalAlignmentMode;
    [self retexture];
}

-(void)setParagraphWidth:(CGFloat)paragraphWidth {
	
	_paragraphWidth = paragraphWidth;
	[self retexture];
	
}

-(void) retexture
{
    UIImage *newTextImage = [self imageFromText:self.text];
    SKTexture *newTexture =[SKTexture textureWithImage:newTextImage];
    
    SKSpriteNode *selfNode = (SKSpriteNode*) self;
    selfNode.texture = newTexture;
    
    selfNode.anchorPoint = CGPointMake(0.5, 0.5);

}

-(UIImage *)imageFromText:(NSString *)text
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping; //To get multi-line
    paragraphStyle.alignment = [self mapSkLabelHorizontalAlignmentToNSTextAlignment:self.horizontalAlignmentMode];
    paragraphStyle.lineSpacing = 1;
    
    UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];
	
	if (!font) {
		font = [UIFont fontWithName:@"Helvetica" size:self.fontSize];
		NSLog(@"The font you specified was unavailable. Defaulted to Helvetica.");
	}
    
    NSMutableDictionary *textAttributes = [NSMutableDictionary dictionary];
    
    [textAttributes setObject:font forKey:NSFontAttributeName];
    
    [textAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];

    [textAttributes setObject:self.fontColor forKey:NSForegroundColorAttributeName];
    
    
	if (_paragraphWidth == 0) {
		_paragraphWidth = self.scene.size.width;
	}
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(_paragraphWidth, self.scene.size.height)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                                      attributes:textAttributes
                                         context:nil];
    textRect.size.height = ceil(textRect.size.height);
    textRect.size.width = ceil(textRect.size.width);
	
	if (textRect.size.width == 0 || textRect.size.height == 0) {
		return Nil;
	}
    
    SKSpriteNode *selfNode = (SKSpriteNode*) self;
    selfNode.size = textRect.size;
    
    UIGraphicsBeginImageContextWithOptions(textRect.size,NO,0.0);
    
    [text drawInRect:textRect withAttributes:textAttributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    
    return image;
}


- (NSTextAlignment) mapSkLabelHorizontalAlignmentToNSTextAlignment:(SKLabelHorizontalAlignmentMode)alignment
{
    switch (alignment) {
        case SKLabelHorizontalAlignmentModeLeft:
            return NSTextAlignmentLeft;
            break;
            
        case SKLabelHorizontalAlignmentModeCenter:
            return NSTextAlignmentCenter;
            break;
            
        case SKLabelHorizontalAlignmentModeRight:
            return NSTextAlignmentRight;
            break;
            
        default:
            break;
    }
    
    return NSTextAlignmentLeft;
}

@end
