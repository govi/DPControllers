//
//  ScrollableView.m
//  EventGenie
//
//  Created by Govi Ram on 27/03/2012.
//  Copyright (c) 2012 GenieMobile. All rights reserved.
//

#import "DPScrollableView.h"

@interface DPScrollableView ()

//-(UIView *)subviewAtPoint:(CGPoint)point;

@end

@implementation DPScrollableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.pointerType = PointerTypeAppear;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.clipsToBounds = YES;
    }
    return self;
}


- (void)setPointerType:(PointerType)pType
{
    _pointerType = pType;
    CGRect frame = self.frame;
    
    if (!_leftPointer)
    {
        self.leftPointer = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 3.0, frame.size.height - 2.5, frame.size.width / 6.0, 2)];
        _leftPointer.backgroundColor = [UIColor blueColor];
        [self addSubview:_leftPointer];
        
        self.rightPointer = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2.0, frame.size.height - 2.5, frame.size.width / 6.0, 2)];
        _rightPointer.backgroundColor = [UIColor blueColor];
        [self addSubview:_rightPointer];
        
        self.centerPointer = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 3.0, frame.size.height - 2.5, frame.size.width / 3.0, 2)];
        _centerPointer.backgroundColor = [UIColor blueColor];
        [self addSubview:_centerPointer];
    }
    else
    {
        _leftPointer.frame = CGRectMake(frame.size.width / 3.0, frame.size.height - 2.5, frame.size.width / 6.0, 2);
        _rightPointer.frame = CGRectMake(frame.size.width / 2.0, frame.size.height - 2.5, frame.size.width / 6.0, 2);
        _centerPointer.frame = CGRectMake(frame.size.width / 3.0, frame.size.height - 2.5, frame.size.width / 3.0, 2);
    }
    
    _leftPointer.hidden = NO;
    _rightPointer.hidden = NO;
    
    if (_pointerType == PointerTypeAppear)
    {
        _leftPointer.center = CGPointMake(self.frame.size.width / 12.0, _leftPointer.center.y);
        _rightPointer.center = CGPointMake(11 * self.frame.size.width / 12.0, _rightPointer.center.y);
        _centerPointer.hidden = NO;
    }
    else if (_pointerType == PointerTypeMoving)
    {
        _centerPointer.hidden = YES;
        _leftPointer.center = CGPointMake(5 * self.frame.size.width / 12.0, _leftPointer.center.y);
        _rightPointer.center = CGPointMake(7 * self.frame.size.width / 12.0, _rightPointer.center.y);
    }
    else if (_pointerType == PointerTypeNone)
    {
        _centerPointer.hidden = YES;
        _leftPointer.hidden = YES;
        _rightPointer.hidden = YES;
    }
    else if (_pointerType == PointerTypeCenter)
    {
        _centerPointer.hidden = NO;
        _leftPointer.hidden = YES;
        _rightPointer.hidden = YES;
    }
    [self resetPointers];
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event])
    {
        return scrollView;
    }
    return nil;
}


- (void)tapped:(UITapGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:scrollView];
    int point = ( (int)(p.x / scrollView.frame.size.width) ) * scrollView.frame.size.width + 2;
    [self reset:CGPointMake(point, p.y) animated:YES];
}


- (void)longPressTapped:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gesture locationInView:scrollView];
        int point = ( (int)(p.x / scrollView.frame.size.width) ) * scrollView.frame.size.width + 2;
        CGPoint point2 = CGPointMake(point, p.y);
        
        int index = (int)roundf(point2.x / scrollView.frame.size.width);
        int count = [_datasource numberOfCellsforScrollableView:self];
        if (index >= count)
        {
            index = count - 1;
        }
        
        if ([_datasource respondsToSelector:@selector(scrollableView:didLongPressCellAtIndex:)])
        {
            [_datasource scrollableView:self didLongPressCellAtIndex:index];
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    [self adjustPointers];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    [self reset:sView.contentOffset animated:YES];
    [self resetPointers];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate
{
    [self reset:sView.contentOffset animated:YES];
    if (!decelerate)
    {
        [self resetPointers];
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sVew
{
    if (!scrollView.isDecelerating && !scrollView.isDragging)
    {
        [self resetPointers];
    }
}


- (void)reset:(CGPoint)p animated:(BOOL)animated
{
    int point = (int)roundf(p.x / scrollView.frame.size.width);
    int count = [_datasource numberOfCellsforScrollableView:self];
    if (point >= count)
    {
        point = count - 1;
    }
    
    CGFloat width = scrollView.frame.size.width;
    float offset = point * width;
    if ( offset < (scrollView.contentSize.width - scrollView.frame.size.width + 10) )
    {
        if (animated)
        {
            [UIView animateWithDuration:0.15 animations:^() {
                scrollView.contentOffset = CGPointMake(offset, 0);
            } completion:^(BOOL finished) {
                [self scrollViewDidEndScrollingAnimation:nil];
            }];
        }
        else
        {
            scrollView.contentOffset = CGPointMake(offset, 0);
            [self setSelectedTab];
        }
        
    }
}


- (void)setSelectedTab
{
    if ([_datasource respondsToSelector:@selector(scrollableView:willSelectCellAtIndex:)])
    {
        [_datasource scrollableView:self willSelectCellAtIndex:_selectedIndex];
    }
    
    CGPoint point = CGPointMake(scrollView.contentOffset.x + scrollView.bounds.size.width / 2, 5);
    self.selectedIndex = [scrollView subviewAtPoint:point].tag - 1;
    int i = 0;
    for (UIView *v in scrollView.subviews)
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
    // deliberately not calling @selector(scrollableView:didSelectCellAtIndex:) here..

}


- (void)resetPointers
{
    if ([_datasource respondsToSelector:@selector(scrollableView:willSelectCellAtIndex:)])
    {
        [_datasource scrollableView:self willSelectCellAtIndex:_selectedIndex];
    }
    
    [UIView beginAnimations:@"pointeranims2" context:nil];
    [UIView setAnimationDelay:1.0];
    
    if (_pointerType == PointerTypeMoving)
    {
        _leftPointer.center = CGPointMake(5 * self.frame.size.width / 12.0, _leftPointer.center.y);
        _rightPointer.center = CGPointMake(7 * self.frame.size.width / 12.0, _rightPointer.center.y);
    }
    else if (_pointerType == PointerTypeAppear)
    {
        _leftPointer.alpha = 0.0;
        _rightPointer.alpha = 0.0;
    }
    
    [UIView commitAnimations];
    
    CGPoint point = CGPointMake(scrollView.contentOffset.x + scrollView.bounds.size.width / 2, 5);
    _selectedIndex = [scrollView subviewAtPoint:point].tag - 1;
    int i = 0;
    for (UIView *v in scrollView.subviews)
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
    
    if ([_datasource respondsToSelector:@selector(scrollableView:didSelectCellAtIndex:)])
    {
        [_datasource scrollableView:self didSelectCellAtIndex:_selectedIndex];
    }
}


- (void)adjustPointers
{
    if (_pointerType == PointerTypeMoving)
    {
        if (scrollView.contentOffset.x >= scrollView.frame.size.width * 1.5)
        {
            _leftPointer.center = CGPointMake(self.frame.size.width / 12.0, _leftPointer.center.y);
        }
        else
        {
            _leftPointer.center = CGPointMake(5 * self.frame.size.width / 12.0, _leftPointer.center.y);
        }
        
        if (scrollView.contentSize.width - scrollView.contentOffset.x > scrollView.frame.size.width * 2.5)
        {
            _rightPointer.center = CGPointMake(11 * self.frame.size.width / 12.0, _rightPointer.center.y);
        }
        else
        {
            _rightPointer.center = CGPointMake(7 * self.frame.size.width / 12.0, _rightPointer.center.y);
        }
    }
    else if (_pointerType == PointerTypeAppear)
    {
        [UIView beginAnimations:@"pointeranims" context:nil];
        if (scrollView.contentOffset.x >= scrollView.frame.size.width * 1.5)
        {
            _leftPointer.alpha = 1.0;
        }
        else
        {
            _leftPointer.alpha = 0.0;
        }
        
        if (scrollView.contentSize.width - scrollView.contentOffset.x > scrollView.frame.size.width * 2.5)
        {
            _rightPointer.alpha = 1.0;
        }
        else
        {
            _rightPointer.alpha = 0.0;
        }
        
        [UIView commitAnimations];
    }
}


- (void)setDatasource:(id<DPScrollableViewDatasource>)ds
{
    if (scrollView)
    {
        [scrollView removeFromSuperview];
    }
    scrollView = nil;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3.0, 0, self.frame.size.width / 3.0, self.frame.size.height)];
    [self addSubview:scrollView];
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.clipsToBounds = NO;
    scrollView.delegate = self;
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapped:)];
    [scrollView addGestureRecognizer:longPressGesture];
    
    _datasource = ds;
    float x = 0;
    CGRect rect = CGRectZero;
    int count = [_datasource numberOfCellsforScrollableView:self];
    BOOL hasView = [ds respondsToSelector:@selector(scrollableView:getViewForIndex:)];
    BOOL hasText = [ds respondsToSelector:@selector(scrollableView:getTitleForIndex:)];
    BOOL hasImage = [ds respondsToSelector:@selector(scrollableView:getImageForIndex:)];
    for (int i = 0; i < count; i++)
    {
        UIView *label = nil;
        if (hasView)
        {
            label = [ds scrollableView:self getViewForIndex:i];
        }
        
        if (!label)
        {
            DPScrollableViewCell *cell = [[DPScrollableViewCell alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width / 3, scrollView.frame.size.height)];
            [scrollView addSubview:cell];
            if (hasText)
            {
                cell.title = [ds scrollableView:self getTitleForIndex:i];
            }
            
            if (hasImage)
            {
                cell.image = [ds scrollableView:self getImageForIndex:i];
            }
            
            cell.separatorColor = [UIColor darkGrayColor];
            label = cell;
            if ([ds respondsToSelector:@selector(scrollableView:didAddCell:)])
            {
                [ds scrollableView:self didAddCell:cell];
            }
        }
        else
        {
            if (!label.superview)
            {
                label.frame = CGRectMake(x, 0, self.frame.size.width / 3, scrollView.frame.size.height);
                [scrollView addSubview:label];
            }
        }
        
        x += label.frame.size.width;
        rect = CGRectUnion(rect, label.frame);
        label.tag = i + 1;
        label.backgroundColor = [UIColor clearColor];
    }
    
    scrollView.contentSize = rect.size;
}

- (void)reloadTabTitles
{
    if ([_datasource respondsToSelector:@selector(scrollableView:getTitleForIndex:)])
    {
        NSUInteger i = 0;
        for (DPScrollableViewCell *cell in scrollView.subviews)
        {
            cell.title = [_datasource scrollableView:self getTitleForIndex:i];
            [cell setNeedsDisplay];
            i++;
        }
    }
    
}

- (void)reloadTabAtIndex:(int)index
{
    if ([_datasource respondsToSelector:@selector(scrollableView:getViewForIndex:)])
    {
        UIView *view = [_datasource scrollableView:self getViewForIndex:index];
        CGFloat x = (self.frame.size.width / 3) * index;
        view.frame = CGRectMake(x, 0, self.frame.size.width / 3, scrollView.frame.size.height);
        view.tag = index + 1;
        [[scrollView.subviews objectAtIndex:index] removeFromSuperview];
        [scrollView insertSubview:view atIndex:index];
        [self resetPointers];
    }
}

- (UIView *)viewAtIndex:(NSUInteger)index
{
    return [self viewWithTag:index + 1];
}


- (void)setHighlightOnAllRows:(BOOL)high
{
    int count = [_datasource numberOfCellsforScrollableView:self];
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
    [self reset:CGPointMake( (scrollView.frame.size.width ) * index, 0 ) animated:animated];
}


- (DPScrollableViewCell *)cellAtIndex:(NSUInteger)index
{
    id val = [scrollView.subviews objectAtIndex:index];
    if ([val isKindOfClass:[DPScrollableViewCell class]])
    {
        return val;
    }
    
    return nil;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.datasource = _datasource;
    self.pointerType = _pointerType;
}

@end


@implementation UIView (Extras)

- (UIView *) subviewAtPoint:(CGPoint)point
{
    for (UIView *view in self.subviews)
    {
        if ( CGRectContainsPoint(view.frame, point) )
        {
            return view;
        }
    }
    
    return self;
}

@end
