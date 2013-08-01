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
        gutterView = [[UIView alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 3, self.frame.size.width - 10, 3)];
        gutterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        gutterView.backgroundColor = [UIColor lightGrayColor];
        gutterView.layer.cornerRadius = 2.0;
        [self addSubview:gutterView];
        
        progressView = [[UIView alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 3, 0, 3)];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        progressView.layer.cornerRadius = 2.0;
        [self addSubview:progressView];
        
        rulerView = [[DPNiftyRulerView alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 3, self.frame.size.width - 10, 3)];
        rulerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        rulerView.sectionPoints = self.sectionPoints;
        [self addSubview:rulerView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 40.0, 0, 40.0, self.frame.size.height - 3)];
        [self addSubview:label];
        label.textAlignment = UITextAlignmentRight;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:10.0];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.lineColor = [UIColor blackColor];
        self.progressColor = [UIColor blueColor];
        self.numberOfSections = 3;
        self.progressColorType = DPNiftyProgressColorTypeSolid;
    }
    return self;
}

-(void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    rulerView.lineColor = lineColor;
    label.textColor = lineColor;
    //self.layer.borderColor = [lineColor CGColor];
    //self.layer.borderWidth = 1.0;
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

-(void)setThresholdColors:(NSArray *)thresholdColors {
    if(thresholdColors) {
        if([thresholdColors count] == self.numberOfSections) {
            NSArray *item = @[[UIColor blackColor]];
            _thresholdColors = [item arrayByAddingObjectsFromArray:thresholdColors];
        } else if([thresholdColors count] == self.numberOfSections + 1) {
            _thresholdColors = thresholdColors;
        }
    }
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
    progressView.frame = CGRectMake(5, self.frame.size.height - 3, (self.frame.size.width - 10)* progress, 3.0);
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
    label.textColor = progressView.backgroundColor;
    [UIView commitAnimations];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setProgress:self.progress];
}

-(UIColor *)color {
    return progressView.backgroundColor;
}

-(void)setSectionPoints:(NSArray *)sectionPoints {
    _sectionPoints = sectionPoints;
    rulerView.sectionPoints = sectionPoints;
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
        if(self.sectionPoints && [self.sectionPoints count] == self.numberOfSections) {
            x = ([[self.sectionPoints objectAtIndex:i] intValue]/[[self.sectionPoints lastObject] floatValue])*self.frame.size.width;
        }
        CGContextStrokeRect(c, CGRectMake(x, 0, 0.5, self.frame.size.height));
        x += resolution;
    }
    CGContextRestoreGState(c);
}

@end
