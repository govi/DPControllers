//
//  DPScrollableView.m
//  EventGenie
//
//  Created by Hugo Rumens on 14/01/2014.
//  Copyright (c) 2014 GenieMobile. All rights reserved.
//

#import "DPScrollableView.h"


@interface DPScrollableView ()
@end


@implementation DPScrollableView


- (id)initWithFrame:(CGRect)frame datasource:(id <DPScrollableViewDatasource>)datasource
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.clipsToBounds = YES;
        _scrolledToIndex = 0;
        self.datasource = datasource;
    }
    return self;
}


- (void)setDatasource:(id <DPScrollableViewDatasource>)ds
{
    if (_scrollView)
    {
        [_scrollView removeFromSuperview];
    }
    _scrollView = nil;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_scrollView];
    _scrollView.scrollEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.clipsToBounds = YES;
    _scrollView.delegate = self;
    [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapped:)];
    [_scrollView addGestureRecognizer:longPressGesture];
    
    _datasource = ds;
    float x = 0;
    CGRect rect = CGRectZero;
    NSInteger cellCount = [_datasource numberOfCellsforScrollableView:self];
    BOOL hasView = [ds respondsToSelector:@selector(scrollableView:getViewForIndex:)];
    BOOL hasText = [ds respondsToSelector:@selector(scrollableView:getTitleForIndex:)];
    BOOL hasImage = [ds respondsToSelector:@selector(scrollableView:getImageForIndex:)];
    
    if(cellCount > 3)
        _cellWidth = (self.frame.size.width/3) - 10;
    else
        _cellWidth = self.frame.size.width/cellCount;
    
    for (int i = 0; i < cellCount; i++)
    {
        UIView *view = nil;
        if (hasView)
        {
            view = [ds scrollableView:self getViewForIndex:i];
        }
        
        if (!view)
        {
            DPScrollableViewCell *cell = [[DPScrollableViewCell alloc] initWithFrame:CGRectMake(x, 0, _cellWidth, _scrollView.frame.size.height)];
            [_scrollView addSubview:cell];
            if (hasText)
            {
                cell.title = [ds scrollableView:self getTitleForIndex:i];
            }
            
            if (hasImage)
            {
                cell.image = [ds scrollableView:self getImageForIndex:i];
            }
            
            cell.separatorColor = [UIColor darkGrayColor];
            view = cell;
            if ([ds respondsToSelector:@selector(scrollableView:didAddCell:)])
            {
                [ds scrollableView:self didAddCell:cell];
            }
        }
        else
        {
            if (!view.superview)
            {
                view.frame = CGRectMake(x, 0, _cellWidth, _scrollView.frame.size.height);
                [_scrollView addSubview:view];
            }
        }
        
        x += view.frame.size.width;
        rect = CGRectUnion(rect, view.frame);
        view.tag = i + 1;
        view.backgroundColor = [UIColor clearColor];
    }
    
    _scrollView.contentSize = rect.size;
    _selectedIndex = 0;
    _scrolledToIndex = 0;
    
    [self resetSelectedTab];
}


- (void)tapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_scrollView];
    NSInteger index = (int)floor(point.x / _cellWidth);
    
    if (index < 0)
    {
        index = 0;
    }
    
    _selectedIndex = index;
    
    if ([_datasource respondsToSelector:@selector(scrollableView:willSelectCellAtIndex:)])
    {
        [_datasource scrollableView:self willSelectCellAtIndex:_selectedIndex];
    }
    
    [self resetSelectedTab];
    
    if ([_datasource respondsToSelector:@selector(scrollableView:didSelectCellAtIndex:)])
    {
        [_datasource scrollableView:self didSelectCellAtIndex:_selectedIndex];
    }
    
    [self removeScrollIndicators];
}


- (void)longPressTapped:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if ([_datasource respondsToSelector:@selector(scrollableView:didLongPressCellAtIndex:)])
        {
            NSUInteger index;
            CGFloat width = self.frame.size.width;
            CGPoint point = [gesture locationInView:self];
            NSUInteger count = [_datasource numberOfCellsforScrollableView:self];
            
            if (count == 1)
            {
                index = 0;
            }
            else if (count == 2)
            {
                index = (point.x < width/2 ? 0 : 1);
            }
            else
            {
                NSUInteger tabWidth = (NSUInteger)width/3;
                index = floor(point.x / tabWidth);
                //NSLog(@"%d %d", index, _scrolledToIndex);
            }
            
            [_datasource scrollableView:self didLongPressCellAtIndex:index + _scrolledToIndex];
        }
    }
}


- (void)reloadTabAtIndex:(NSInteger)index
{
    if ([_datasource respondsToSelector:@selector(scrollableView:getViewForIndex:)])
    {
        UIView *view = [_datasource scrollableView:self getViewForIndex:index];
        CGFloat x = _cellWidth * index;
        view.frame = CGRectMake(x, 0, _cellWidth, _scrollView.frame.size.height);
        view.tag = index + 1;
        [[_scrollView.subviews objectAtIndex:index] removeFromSuperview];
        [_scrollView insertSubview:view atIndex:index];
        
        [self resetSelectedTab];
    }
}


- (void)resetSelectedTab
{
    NSInteger i = 0;
    for (UIView *v in _scrollView.subviews)
    {
        if ([v isKindOfClass:[DPScrollableViewCell class]])
        {
            if (i == _selectedIndex)
            {
                ( (DPScrollableViewCell *)v ).selected = YES;
            }
            else
            {
                ( (DPScrollableViewCell *)v ).selected = NO;
            }
            
            [v setNeedsDisplay];
        }
        
        i++;
    }
    [self scrollToIndex:_selectedIndex animated:YES];
}


- (UIView *)viewAtIndex:(NSUInteger)index
{
    return [self viewWithTag:index + 1];
}


- (void)setHighlightOnAllRows:(BOOL)high
{
    NSInteger count = [_datasource numberOfCellsforScrollableView:self];
    for (int i = 0; i < count; i++)
    {
        UIView *v = [self viewAtIndex:i];
        if ([v isKindOfClass:[DPScrollableViewCell class]])
        {
            ( (DPScrollableViewCell *)v ).highlighted = high;
            [v setNeedsDisplay];
        }
    }
}


- (void)setSelectedIndex:(NSInteger)index
{
    [self setSelectedIndex:index animated:YES];
}


- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    _selectedIndex = index;
    
    [self resetSelectedTab];
}


- (DPScrollableViewCell *)cellAtIndex:(NSUInteger)index
{
    id val = [_scrollView.subviews objectAtIndex:index];
    if ([val isKindOfClass:[DPScrollableViewCell class]])
    {
        return val;
    }
    
    return nil;
}


#pragma mark - scroll methods


- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger cellCount = [_datasource numberOfCellsforScrollableView:self];
    //sanitising the index value
    if (cellCount <= 3)
    {
        return; //no need to do anything when the cell count is less than 3;
    }
    else if(index < 0)
    {
        index = 0;
    }
    else if(index > cellCount - 3)
    {
        index = cellCount - 3;
    }
    
    _scrolledToIndex = index;
    CGFloat newX = _scrolledToIndex * _cellWidth;
    CGFloat remainingLength = (cellCount - _scrolledToIndex) * _cellWidth;
    if (remainingLength < _scrollView.frame.size.width)
    {
        newX = _scrollView.contentSize.width - _scrollView.frame.size.width;
    }
    else if (newX >= _cellWidth)
    {
        newX -= 15.0;//so that if there is a cell before the current cell, it will be shown a little bit
    }
    [_scrollView setContentOffset:CGPointMake(newX, 0) animated:YES];
}


- (void)scrollTabIntoViewIfNeededWithIndex:(NSInteger)index
{
    // method can get called via GMSwipeViewController childViewControllerViewTapped so do nothing if scroll in progress.
    if (_scrollView.decelerating || _scrollView.tracking || _scrollView.dragging)
    {
        return;
    }
    
    NSInteger cellCount = [_datasource numberOfCellsforScrollableView:self];
    if (cellCount < 4)
    {
        return;
    }
    
    // tab already in view
    if (_scrolledToIndex <= index && index <= (_scrolledToIndex+2))
    {
        return;
    }
    
    NSInteger newIndex;
    if (index < _scrolledToIndex)
    {
        // tab hidden at left
        newIndex = index;
    }
    else
    {
        // tab hidden at right
        newIndex = index - 2;
    }
    
    [self scrollToIndex:newIndex animated:NO];
}


#pragma mark - Scroll Indicators

-(void)flashScrollIndicators
{
    NSInteger cellCount = [_datasource numberOfCellsforScrollableView:self];
    if (cellCount > 3)
    {
        NSInteger currentVisibleIndex = _scrolledToIndex;
        if (currentVisibleIndex <= 0)
        {
            [self flashRightScrollIndicator];
        }
        else if (currentVisibleIndex >= cellCount-3)
        {
            [self flashLeftScrollIndicator];
        }
        else
        {
            [self flashBothScrollIndicators];
        }
    }
}

- (void)flashLeftScrollIndicator
{
    UIImageView *leftImageView = [self leftScrollImageView];
    [self addSubview:leftImageView];
    
    [UIView animateWithDuration:0.4 delay:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^()
     {
         leftImageView.alpha = 1.0f;
         
     } completion:^(BOOL complete)
     {
         [UIView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationOptionCurveLinear animations:^()
          {
              leftImageView.alpha = 0.0f;
              
          } completion:^(BOOL completed)
          {
              [leftImageView removeFromSuperview];
          }];
     }];
}


- (void)flashRightScrollIndicator
{
    UIImageView *rightImageView = [self rightScrollImageView];
    [self addSubview:rightImageView];
    
    [UIView animateWithDuration:0.4 delay:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^()
     {
         rightImageView.alpha = 1.0f;
         
     } completion:^(BOOL complete)
     {
         [UIView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationOptionCurveLinear animations:^()
          {
              rightImageView.alpha = 0.0f;
              
          } completion:^(BOOL completed)
          {
              [rightImageView removeFromSuperview];
          }];
     }];
}


- (void)flashBothScrollIndicators
{
    UIImageView *leftImageView = [self leftScrollImageView];
    UIImageView *rightImageView = [self rightScrollImageView];
    
    [self addSubview:leftImageView];
    [self addSubview:rightImageView];
    
    [UIView animateWithDuration:0.4 delay:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^()
     {
         leftImageView.alpha = 1.0f;
         rightImageView.alpha = 1.0f;
         
     } completion:^(BOOL complete)
     {
         [UIView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationOptionCurveLinear animations:^()
          {
              leftImageView.alpha = 0.0f;
              rightImageView.alpha = 0.0f;
              
          } completion:^(BOOL completed)
          {
              [leftImageView removeFromSuperview];
              [rightImageView removeFromSuperview];
          }];
     }];
}


- (UIImageView *)leftScrollImageView
{
    //UIColor *color = [UIColor colorWithHexString:@"AAAAAA"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self arrowImageRotatedby:-M_PI/2]];
    CGFloat yOffset = (self.frame.size.height - 16)/2;
    imageView.frame = CGRectMake(5, yOffset, 16, 16);
    imageView.alpha = 0.0f;
    imageView.tag = 0xdecea5ed;
    
    return imageView;
}


- (UIImageView *)rightScrollImageView
{
    //UIColor *color = [UIColor colorWithHexString:@"AAAAAA"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self arrowImageRotatedby:M_PI/2]];
    CGFloat yOffset = (self.frame.size.height - 16)/2;
    imageView.frame = CGRectMake(self.frame.size.width - 21, yOffset, 16, 16);
    imageView.alpha = 0.0f;
    imageView.tag = 0xbaddad;
    
    return imageView;
}

-(UIImage *)arrowImageRotatedby:(CGFloat)radians {
    UIGraphicsBeginImageContext(CGSizeMake(16, 16));
    //NSString *arrow = radians < 0 ?@"⬖":@"⬗";
    NSString *arrow = radians < 0 ?@"❰":@"❱";
    [self.textColor setFill];
    [arrow drawInRect:CGRectMake(0, -3, 16, 22) withFont:[UIFont systemFontOfSize:16]];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (void)removeScrollIndicators
{
    UIView *leftFlashIndicator = [self viewWithTag:0xdecea5ed];
    UIView *rightFlashIndicator = [self viewWithTag:0xbaddad];
    
    if (leftFlashIndicator)
    {
        [leftFlashIndicator.layer removeAllAnimations];
        [leftFlashIndicator removeFromSuperview];
    }
    if (rightFlashIndicator)
    {
        [rightFlashIndicator.layer removeAllAnimations];
        [rightFlashIndicator removeFromSuperview];
    }
}


#pragma mark - UIScrollView Methods


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _contextOffsetAtStartOfDrag = scrollView.contentOffset;
    
    [self removeScrollIndicators];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollViewDraggedBeyondContentBoundary)
    {
        _scrollViewDraggedBeyondContentBoundary = NO;
        [self flashScrollIndicators]; // when the scrollview goed beyond bounds
        return;
    }
    
    [self scrollingEnded];
    [self flashScrollIndicators];//present after scrolling ended, to use the _scrolledToIndex
}


- (void)scrollViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate
{
    CGFloat x = _scrollView.contentOffset.x;
    NSInteger count = [_datasource numberOfCellsforScrollableView:self];
    
    if (x < 0)
    {
        _scrollViewDraggedBeyondContentBoundary = YES;
        _scrolledToIndex = 0;
    }
    else if (x > _scrollView.contentSize.width - 320)
    {
        _scrollViewDraggedBeyondContentBoundary = YES;
        _scrolledToIndex = count-3;
    }
    else
    {
        [self scrollingEnded];
        if(!decelerate)
            [self flashScrollIndicators];//flash the indicators only when not decelerating, as its handled elsewhere. Also, present after scrollingended as we need the _scrolledToIndex.
    }
}


- (void)scrollingEnded
{
    CGFloat width = _cellWidth;
    CGFloat x = _scrollView.contentOffset.x;
    NSInteger index = (int)floor(x / (width));
    
    if (index < 0)
    {
        index = 0;
    }
    
    if (x > _contextOffsetAtStartOfDrag.x)
    {
        index++;
    }
    
    NSInteger count = [_datasource numberOfCellsforScrollableView:self];
    if (index == count - 2)
    {
        // disallowed index; just in case
        return;
    }
    
    _scrolledToIndex = index;
    CGFloat newX = index * width;
    CGFloat remainingLength = (count - index) * _cellWidth;
    if (remainingLength < _scrollView.frame.size.width)
    {
        newX = _scrollView.contentSize.width - _scrollView.frame.size.width;
    }
    else if (newX >= _cellWidth)
    {
        newX -= 15.0;//so that if there is a cell before the current cell, it will be shown a little bit
    }
    [_scrollView setContentOffset:CGPointMake(newX, 0) animated:YES];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}


@end
