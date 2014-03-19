//
//  NSString+UI.m
//  EventGenie
//
//  Created by Govi Ram on 06/04/2012.
//  Copyright (c) 2012 GenieMobile. All rights reserved.
//

#import "NSString+UI.h"

@implementation NSString (UI)

- (void) drawCenteredInRect:(CGRect)contextRect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment
{
    CGFloat fontHeight = font.pointSize;
    CGFloat yOffset = (contextRect.size.height - fontHeight) / 2.0;

    CGRect textRect = CGRectMake(contextRect.origin.x, contextRect.origin.y + yOffset, contextRect.size.width, fontHeight);

    [self drawInRect:textRect withFont:font lineBreakMode:lineBreakMode
           alignment:alignment];
}


@end
