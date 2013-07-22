//
//  DPNiftyProgressBar.m
//  Slidey
//
//  Created by Govi on 22/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import "DPNiftyProgressBar.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+GradientOffset.h"

@implementation DPNiftyProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        [self addSubview:progressView];
        
        rulerView = [[DPNiftyRulerView alloc] initWithFrame:self.bounds];
        [self addSubview:rulerView];
        
        float flt = (frame.size.width - 40.0)/2;
        float y = (frame.size.height - 20.0)/2;
        label = [[UILabel alloc] initWithFrame:CGRectMake(flt, y, 40.0, 20.0)];
        [self addSubview:label];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10.0];
        
        self.lineColor = [UIColor blackColor];
        self.progressColor = [UIColor blueColor];
        self.numberOfSections = 3;
        self.progressColorType = DPNiftyProgressColorTypeSolid;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 7.0;
    }
    return self;
}

-(void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    rulerView.lineColor = lineColor;
    self.layer.borderColor = [lineColor CGColor];
    self.layer.borderWidth = 1.0;
}

-(void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    progressView.backgroundColor = progressColor;
}

-(void)setNumberOfSections:(NSInteger)numberOfSections {
    _numberOfSections = numberOfSections;
    rulerView.numberOfSections = numberOfSections;
}

-(void)setFromProgressColor:(UIColor *)fromProgressColor {
    _fromProgressColor = fromProgressColor;
    [self setProgress:self.progress];
}

-(void)setToProgressColor:(UIColor *)toProgressColor {
    _toProgressColor = toProgressColor;
    [self setProgress:self.progress];
}

-(void)setProgress:(float)progress {
    _progress = progress;
    float resolution = 1.0 / self.numberOfSections;
    int count = (int)(progress / resolution);
    float offset = (progress - resolution * count)/resolution;
    label.text = [NSString stringWithFormat:@"%0.1f%%", progress*100.0];
    
    [UIView beginAnimations:@"progress animations" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelay:0.4];
    progressView.frame = CGRectMake(0, 0, self.frame.size.width * progress, self.frame.size.height);
    if(self.thresholdColors && [self.thresholdColors count] == (self.numberOfSections + 1)) {
        if(self.progressColorType == DPNiftyProgressColorTypeRGBGradient && count < self.numberOfSections)
            progressView.backgroundColor = [UIColor RGBColorBetween:[self.thresholdColors objectAtIndex:count] and:[self.thresholdColors objectAtIndex:count+1] withOffset:offset];
        else if(self.progressColorType == DPNiftyProgressColorTypeHSVGradient && count < self.numberOfSections)
            progressView.backgroundColor = [UIColor HSVColorBetween:[self.thresholdColors objectAtIndex:count] and:[self.thresholdColors objectAtIndex:count+1] withOffset:offset];
        else
            progressView.backgroundColor = [self.thresholdColors objectAtIndex:count];
    }
    else if(self.toProgressColor && self.fromProgressColor) {
        if(self.progressColorType == DPNiftyProgressColorTypeRGBGradient)
            progressView.backgroundColor = [UIColor RGBColorBetween:self.fromProgressColor and:self.toProgressColor withOffset:progress];
        else if(self.progressColorType == DPNiftyProgressColorTypeHSVGradient)
            progressView.backgroundColor = [UIColor HSVColorBetween:self.fromProgressColor and:self.toProgressColor withOffset:progress];
    }
    [UIView commitAnimations];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect
{
    
}*/

@end


@implementation DPNiftyRulerView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    [self.lineColor setStroke];
    float resolution = self.frame.size.width / self.numberOfSections;
    float x = resolution;
    for(int i=0;i<self.numberOfSections;i++) {
        CGContextStrokeRect(c, CGRectMake(x, 0, 1.0, self.frame.size.height));
        x += resolution;
    }
    CGContextRestoreGState(c);
}

@end
