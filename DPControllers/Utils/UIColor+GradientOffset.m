//
//  UIColor+GradientOffset.m
//  Slidey
//
//  Created by Govi on 22/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import "UIColor+GradientOffset.h"

@implementation UIColor (GradientOffset)

+(UIColor *)RGBColorBetween:(UIColor *)from and:(UIColor *)to withOffset:(float)offset {
    CGFloat red1, green1, blue1, alpha1;
    CGFloat red2, green2, blue2, alpha2;
    [from getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [to getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    return [UIColor colorWithRed:red1 + (red2 - red1)*offset
                           green:green1 + (green2 - green1)*offset
                            blue:blue1 + (blue2 - blue1)*offset
                           alpha:alpha1 + (alpha2 - alpha1)*offset];
}

+(UIColor *)HSVColorBetween:(UIColor *)from and:(UIColor *)to withOffset:(float)offset {
    CGFloat hue1, sat1, bri1, alpha1;
    CGFloat hue2, sat2, bri2, alpha2;
    [from getHue:&hue1 saturation:&sat1 brightness:&bri1 alpha:&alpha1];
    [to getHue:&hue2 saturation:&sat2 brightness:&bri2 alpha:&alpha2];
    return [UIColor colorWithHue:hue1 + (hue2 - hue1)*offset
               saturation:sat1 + (sat2 - sat1)*offset
               brightness:bri1 + (bri2 - bri1)*offset
                    alpha:alpha1 + (alpha2 - alpha1)*offset];
}

@end
