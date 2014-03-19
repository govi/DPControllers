//
//  DPSwipeViewControllerView.m
//  DPControllers
//
//  Created by Govi on 19/03/2014.
//  Copyright (c) 2014 DP. All rights reserved.
//

#import "DPSwipeViewControllerView.h"
#import "DPSwipeViewController.h"

@implementation DPSwipeViewControllerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *scrollableView = [self viewWithTag:DPScrollableViewTagIdentifier];
    if ([scrollableView pointInside:point withEvent:event])
    {
        return [super hitTest:point withEvent:event];
    }
    
    [_delegate childViewControllerViewTapped];
    return [super hitTest:point withEvent:event];
}

@end
