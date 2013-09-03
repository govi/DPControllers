//
//  UIColor+GradientOffset.h
//  Slidey
//
//  Created by Govi on 22/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (GradientOffset)

+(UIColor *)RGBColorBetween:(UIColor *)from and:(UIColor *)to withOffset:(float)offset;
+(UIColor *)HSVColorBetween:(UIColor *)from and:(UIColor *)to withOffset:(float)offset;

@end
