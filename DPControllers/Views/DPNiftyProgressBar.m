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
    return [self initWithFrame:frame andBarSize:5.0 andBarEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
}

- (id)initWithFrame:(CGRect)frame andBarSize:(float)barSize andBarEdgeInsets:(UIEdgeInsets)insets
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.barSize = barSize;
        self.showsLabel = YES;
        self.barInsets = insets;
        
        gutterView = [[RectFillerView alloc] initWithFrame:CGRectMake(insets.left, self.frame.size.height - self.barSize, self.frame.size.width - insets.left - insets.right, self.barSize)];
        gutterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        gutterView.color = [UIColor lightGrayColor];
        gutterView.layer.cornerRadius = self.barSize;
        gutterView.clipsToBounds = YES;
        gutterView.layer.shadowColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5].CGColor;
        gutterView.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        gutterView.layer.shadowRadius = 3.0;
        [self addSubview:gutterView];
        
        progressView = [[RectFillerView alloc] initWithFrame:CGRectMake(insets.left, self.frame.size.height - self.barSize, 0, self.barSize)];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        progressView.layer.cornerRadius = self.barSize;
        progressView.clipsToBounds = YES;
        [self addSubview:progressView];
        
        rulerView = [[DPNiftyRulerView alloc] initWithFrame:CGRectMake(insets.left, self.frame.size.height - self.barSize - 1, self.frame.size.width - insets.left - insets.right, self.barSize + 1)];
        rulerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        rulerView.sectionPoints = self.sectionPoints;
        [self addSubview:rulerView];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 90.0, 0, 80.0, self.frame.size.height - self.barSize - 2)];
        [self addSubview:label];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:10.0];
        label.highlightedTextColor = [UIColor blackColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
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
}

-(void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    progressView.color = progressColor;
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
    if(self.showsLabel)
    {
        if(progress > 0)
            label.text = [NSString stringWithFormat:@"%0.1f%% (%0.0f)", progress*100.0, self.points];
        else if(self.points > 0)
            label.text = [NSString stringWithFormat:@"%0.0f", self.points];
        else
            label.text = @" ➖ ";
    }
    else
    {
        label.text = nil;
    }
    int count = 0;
    float offset = 0;
    float lastP = 0;
    while (count < [self.sectionPoints count]){
        float val = [[self.sectionPoints objectAtIndex:count] intValue]/[[self.sectionPoints lastObject] floatValue];
        if (progress>=val) {
            count++;
        } else {
            offset = progress - lastP;
            break;
        }
        lastP = val;
    }
    
    if(self.thresholdColors && [self.thresholdColors count] == (self.numberOfSections + 1)) {
        if(self.progressColorType == DPNiftyProgressColorTypeRGBGradient && count < self.numberOfSections)
            progressView.color = [UIColor RGBColorBetween:[self.thresholdColors objectAtIndex:count] and:[self.thresholdColors objectAtIndex:count+1] withOffset:offset];
        else if(self.progressColorType == DPNiftyProgressColorTypeHSVGradient && count < self.numberOfSections)
            progressView.color = [UIColor HSVColorBetween:[self.thresholdColors objectAtIndex:count] and:[self.thresholdColors objectAtIndex:count+1] withOffset:offset];
        else
            progressView.color = [self.thresholdColors objectAtIndex:count];
    }
    else if(self.toProgressColor && self.fromProgressColor) {
        if(self.progressColorType == DPNiftyProgressColorTypeRGBGradient)
            progressView.color = [UIColor RGBColorBetween:self.fromProgressColor and:self.toProgressColor withOffset:progress];
        else if(self.progressColorType == DPNiftyProgressColorTypeHSVGradient)
            progressView.color = [UIColor HSVColorBetween:self.fromProgressColor and:self.toProgressColor withOffset:progress];
    }
    label.textColor = [UIColor darkGrayColor];
    
    [UIView beginAnimations:@"progress animations" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelay:0.4];
    progressView.frame = CGRectMake(self.barInsets.left, self.frame.size.height - self.barSize, (self.frame.size.width - self.barInsets.left - self.barInsets.right)* progress, self.barSize);
    [UIView commitAnimations];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self setProgress:self.progress];
}

-(UIColor *)color {
    if(progressView.color && progressView.color != (UIColor *)[NSNull null])
        return progressView.color;
    return [UIColor blackColor];
}

-(void)setSectionPoints:(NSArray *)sectionPoints {
    _sectionPoints = sectionPoints;
    rulerView.sectionPoints = sectionPoints;
}

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
    for(int i=0;i<self.numberOfSections-1;i++) {
        if(self.sectionPoints && [self.sectionPoints count] == self.numberOfSections) {
            x = ([[self.sectionPoints objectAtIndex:i] intValue]/[[self.sectionPoints lastObject] floatValue])*self.frame.size.width;
        }
        CGContextStrokeRect(c, CGRectMake(x, 0, 0.5, self.frame.size.height));
        x += resolution;
    }
    CGContextRestoreGState(c);
}

@end

@implementation RectFillerView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor blackColor];
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    if(!self.color || self.color == (id)[NSNull null])
        self.color = [UIColor blackColor];
    [self.color setFill];
    CGContextFillRect(c, self.bounds);
    CGContextRestoreGState(c);
}

@end
