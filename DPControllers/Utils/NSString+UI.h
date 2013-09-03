//
//  NSString+UI.h
//  EventGenie
//
//  Created by Govi Ram on 06/04/2012.
//  Copyright (c) 2012 GenieMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UI)

- (void) drawCenteredInRect:(CGRect)contextRect withFont:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment;

@end
