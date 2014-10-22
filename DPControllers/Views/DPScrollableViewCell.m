//
//  ScrollableViewCell.m
//  EventGenie
//
//  Created by Govi Ram on 27/03/2012.
//  Copyright (c) 2012 GenieMobile. All rights reserved.
//

#import "DPScrollableViewCell.h"
#import "NSString+UI.h"

@implementation DPScrollableViewCell
@synthesize image, title, style, textColor, selected, normalFont, highlightedFont;
@synthesize selectedTextColor, selectedFont, highlighted, highlightedTextColor, highlightedBackgroundColor;

+(void)initialize {
    if(self == [DPScrollableViewCell self]) {
        DPScrollableViewCell *proxy = [DPScrollableViewCell appearance];
        proxy.normalFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        proxy.highlightedFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        proxy.selectedFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        proxy.textColor = [UIColor lightGrayColor];
        proxy.highlightedTextColor = [UIColor orangeColor];
        proxy.selectedTextColor = [UIColor whiteColor];
    }
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    float lineHt = [UIFont systemFontSize];
    BOOL hasText = title && [title length] > 0;
    if (image)
    {
        if (hasText)
        {
            if ( frame.size.height > (3 * lineHt) )
            {
                style = DPScrollableViewStyleImageWithCaption;
            }
            else
            {
                style = DPScrollableViewStyleTrailingText;
            }
        }
        else
        {
            style = DPScrollableViewStyleImageOnly;
        }
    }
    else
    {
        style = DPScrollableViewStyleTextOnly;
    }
    
    switch (style)
    {
        case DPScrollableViewStyleTextOnly:
            textRect = CGRectMake(3, 0, self.frame.size.width - 6, self.frame.size.height);
            break;
        case DPScrollableViewStyleImageOnly:
            imageRect = self.bounds;
            break;
        case DPScrollableViewStyleTrailingText:
            imageRect = CGRectMake(3, self.frame.size.height - 18, 15, 15);
            textRect = CGRectMake(21, 0, self.frame.size.width - 21, self.frame.size.height);
            break;
        case DPScrollableViewStyleImageWithCaption:
            imageRect = CGRectMake(3, 3, self.frame.size.width - 6, self.frame.size.height - 21);
            textRect = CGRectMake(0, self.frame.size.height - 18, self.frame.size.width, 18);
            break;
        default:
            break;
    } /* switch */
}


- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIFont *font = normalFont;
    UIColor *color = textColor;
    if (highlighted)
    {
        font = highlightedFont;
        if (highlightedTextColor)
        {
            color = highlightedTextColor;
        }
        
        if (highlightedBackgroundColor)
        {
            [highlightedBackgroundColor setFill];
            CGContextFillRect(context, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
        }
    }
    
    if (selected)
    {
        font = selectedFont;
        if (selectedTextColor)
        {
            color = selectedTextColor;
        }
    }
    
    if (color)
    {
        [color setFill];
    }
    
    switch (style)
    {
        case DPScrollableViewStyleImageWithCaption:
            [image drawInRect:imageRect];
            [title drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
            break;
        case DPScrollableViewStyleTrailingText:
            [image drawInRect:imageRect];
            [title drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping];
            break;
        case DPScrollableViewStyleTextOnly:
            [title drawCenteredInRect:textRect withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
            break;
        case DPScrollableViewStyleImageOnly:
            [image drawInRect:imageRect];
            break;
        default:
        break;
    } /* switch */
    
    if(self.separatorColor)
    {
        CGContextSaveGState(context);
        [self.separatorColor setFill];
        CGContextFillRect(context, CGRectMake(self.bounds.size.width-0.5, 0, 0.5, self.bounds.size.height));
        CGContextFillRect(context, CGRectMake(0, 0, 0.5, self.bounds.size.height));
        CGContextRestoreGState(context);
    }
}




@end
