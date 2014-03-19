//
//  DPSwipeViewController.m
//  EventGenie
//
//  Created by Hugo Rumens on 14/01/2014.
//  Copyright (c) 2014 GenieMobile. All rights reserved.
//

#import "DPSwipeViewController.h"
#import "DPScrollableView.h"
#import "DPSwipeViewControllerView.h"


int DPsignum(int n) { return (n < 0) ? -1 : (n > 0) ? +1 : 0; }

NSInteger const DPScrollableViewTagIdentifier = 0xdeadf00d;

@interface DPSwipeViewController ()
@end


@implementation DPSwipeViewController


- (id)initWithDelegate:(id <DPSwipeViewControllerDelegate>)delegate tabs:(NSArray *)tabs startingTab:(NSString *)startTab
{
    assert(delegate != nil);
    assert([delegate conformsToProtocol:@protocol(DPSwipeViewControllerDelegate)]);
    assert([tabs containsObject:startTab]);
    
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        assert([self verifyTabsArray:tabs]);
        
        _tabs = tabs;
        _currentTab = startTab;
        _viewControllerCache = [NSMutableDictionary dictionaryWithCapacity:[_tabs count]];
        
        _scrollableView = [[DPScrollableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44) datasource:self];
        _scrollableView.tag = DPScrollableViewTagIdentifier;
        [self.view addSubview:_scrollableView];
    }
    
    return self;
}


- (id)init
{
    self = [self initWithDelegate:nil tabs:nil startingTab:nil];
    if (self)
    {
        
    }
    return self;
}


- (void)loadView
{
    CGRect frame = CGRectMake(0, 0, 320, 568);
    DPSwipeViewControllerView *view = [[DPSwipeViewControllerView alloc] initWithFrame:frame];
    view.delegate = self;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
}


- (void)childViewControllerViewTapped
{
    [self scrollTabIntoViewIfNeededForKey:self.currentTab];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([_tabs count] == 0)
    {
        return;
    }
    
    UIView *contentView = ((UIViewController *)[self viewControllerForKey:_currentTab]).view;
    contentView.frame = CGRectMake(0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:right];
    
    [self.scrollableView setSelectedIndex:[_tabs indexOfObject:_currentTab]];
    
    NSInteger tabsCount = [_tabs count];
    NSInteger index = [_tabs indexOfObject:_currentTab];
    
    if (tabsCount > 3 && index > 0)
    {
        [self.scrollableView scrollToIndex:index animated:NO];
    }
    
    if (tabsCount > 3)
    {
        if (index == 0)
        {
            [self.scrollableView flashRightScrollIndicator];
        }
        else if (index == tabsCount-3)
        {
            [self.scrollableView flashLeftScrollIndicator];
        }
        else
        {
            [self.scrollableView flashBothScrollIndicators];
        }
    }
}


- (void)setTabs:(NSArray *)tabs
{
    assert([self verifyTabsArray:tabs]);
    
    _tabs = [tabs copy];
    
    for (UIViewController *controller in self.childViewControllers)
    {
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    }
    
    _scrollableView.datasource = self;
    
    UIView *contentView = ((UIViewController *)[self firstViewController]).view;
    contentView.frame = CGRectMake(0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    
    _currentTab = [_tabs objectAtIndex:0];
}


- (BOOL)verifyTabsArray:(NSArray *)tabs
{
    NSMutableArray *test = [NSMutableArray arrayWithCapacity:[tabs count]];
    for (NSString *tab in tabs)
    {
        if (![tab isKindOfClass:[NSString class]])
        {
            return NO;
        }
        
        if ([test containsObject:tab])
        {
            return NO;
        }
        
        [test addObject:tab];
    }
    
    return YES;
}


- (void)swiping:(UISwipeGestureRecognizer *)gesture
{
    NSString *newKey;
    NSInteger index = [_tabs indexOfObject:_currentTab];
    NSInteger newIndex;
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (index == 0)
        {
            return;
        }
        newIndex = index-1;
    }
    else
    {
        if (index == [_tabs count]-1)
        {
            return;
        }
        newIndex = index+1;
    }
    newKey = [_tabs objectAtIndex:newIndex];
    
    [self transitionFromController:_currentTab toController:newKey animated:YES];
    [self scrollTabIntoViewIfNeededForKey:newKey];
    [self.scrollableView setSelectedIndex:newIndex];
    [self.scrollableView removeScrollIndicators];
}


- (void)transitionFromController:(NSString *)fromKey toController:(NSString *)toKey animated:(BOOL)animated
{
    if (fromKey != toKey)
    {
        UIViewController *fromVC = [self viewControllerForKey:fromKey];
        UIViewController *toVC = [self viewControllerForKey:toKey];
        
        BOOL movingRight = ([_tabs indexOfObject:toKey] > [_tabs indexOfObject:fromKey] ? YES : NO);
        
        toVC.view.frame = fromVC.view.frame;
        toVC.view.center = CGPointMake(3 * self.view.center.x * (movingRight ? 1 : -1), fromVC.view.center.y);
        
        __weak id <DPSwipeViewControllerDelegate> weakDelegate = self.delegate;
        __weak DPSwipeViewController *weakSelf = self;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(swipeController:willTransitionFromController:withKey:toController:withKey:)])
        {
            [self.delegate swipeController:self willTransitionFromController:fromVC withKey:fromKey toController:toVC withKey:toKey];
        }
        
        CGFloat duration = (animated ? 0.2 : 0);
        
        [self transitionFromViewController:fromVC toViewController:toVC duration:duration options:UIViewAnimationOptionTransitionNone animations:^{
            
            toVC.view.center = fromVC.view.center;
            
        } completion:^(BOOL finished) {
            
            weakSelf.currentTab = toKey;
            
            if (weakDelegate && [weakDelegate respondsToSelector:@selector(swipeController:didTransitionFromController:withKey:toController:withKey:)])
            {
                [self.delegate swipeController:self didTransitionFromController:fromVC withKey:fromKey toController:toVC withKey:toKey];
            }
        }];
    }
}

- (void)setSelectedKey:(NSString *)key
{
    NSInteger index = [_tabs indexOfObject:key];
    [self.scrollableView setSelectedIndex:index];
    [self transitionFromController:_currentTab toController:key animated:NO];
}


- (void)resetViewControllerWithKey:(NSString *)key
{
    UIViewController *controller = [_viewControllerCache objectForKey:key];
    
    if (controller == nil)
    {
        //GMLogError(GM_LOG_AREA_APPLICATION, @"Error. Can't reset VC with unknown key: %@", key);
        return;
    }
    
    if ([controller.view superview])
    {
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
        [_viewControllerCache removeObjectForKey:key];
        UIViewController *newController = [self viewControllerForKey:key];
        
        UIView *contentView = newController.view;
        contentView.frame = CGRectMake(0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0);
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:contentView];
    }
    else
    {
        [_viewControllerCache removeObjectForKey:key];
    }
}


- (UIViewController *)firstViewController
{
    NSString *key = [_tabs objectAtIndex:0];
    return [self viewControllerForKey:key];
}


- (UIViewController *)viewControllerForKey:(NSString *)key
{
    UIViewController *vc = [_viewControllerCache objectForKey:key];
    if (vc)
    {
        if (vc.parentViewController == nil)
        {
            [self addChildViewController:vc];
        }
        return vc;
    }
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(swipeController:viewControllerForKey:)])
    {
        UIViewController *vc = [_delegate swipeController:self viewControllerForKey:key];
        
        assert(vc != nil);
        
        [self addChildViewController:vc];
        [_viewControllerCache setObject:vc forKey:key];
        
        return vc;
    }
    
    return nil;
}


- (void)reloadTabWithKey:(NSString *)key
{
    NSUInteger index = [_tabs indexOfObject:key];
    if (index == NSNotFound)
    {
        //GMLogError(GM_LOG_AREA_APPLICATION, @"Error. Can't reload tab with unknown key: %@", key);
        return;
    }
    [self.scrollableView reloadTabAtIndex:index];
}


- (void)setNewKey:(NSString *)newKey forControllerWithExistingKey:(NSString *)key
{
    NSUInteger index = [_tabs indexOfObject:key];
    assert(index != NSNotFound);
    
    NSMutableArray *mutTabs = [_tabs mutableCopy];
    [mutTabs replaceObjectAtIndex:index withObject:newKey];
    _tabs = [mutTabs copy];
    
    UIViewController *controller = [_viewControllerCache objectForKey:key];
    if (controller)
    {
        [_viewControllerCache setObject:controller forKey:newKey];
        [_viewControllerCache removeObjectForKey:key];
    }
    
    if ([_currentTab isEqualToString:key])
    {
        _currentTab = newKey;
    }
}


- (void)scrollTabIntoViewIfNeededForKey:(NSString *)key
{
    if ([_tabs count] < 4)
    {
        return;
    }
    
    NSInteger index = [_tabs indexOfObject:key];
    assert(index != NSNotFound);
    
    [self.scrollableView scrollTabIntoViewIfNeededWithIndex:index];
}


#pragma mark - DPScrollableViewDataSource methods


- (NSInteger)numberOfCellsforScrollableView:(DPScrollableView *)view
{
    return [_tabs count];
}


- (NSString *)scrollableView:(DPScrollableView *)view getTitleForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(swipeController:tabTitleForKey:)])
    {
        return [self.delegate swipeController:self tabTitleForKey:[_tabs objectAtIndex:index]];
    }
    return nil;
}


- (UIView *)scrollableView:(DPScrollableView *)view getViewForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(swipeController:tabViewForKey:)])
    {
        return [self.delegate swipeController:self tabViewForKey:[_tabs objectAtIndex:index]];
    }
    return nil;
}


- (void)scrollableView:(DPScrollableView *)view didSelectCellAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(transitionFromController:toController:animated:)])
    {
        [self transitionFromController:_currentTab toController:[_tabs objectAtIndex:index] animated:YES];
    }
}


- (void)scrollableView:(DPScrollableView *)view didLongPressCellAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(swipeController:didLongPressCellWithKey:)])
    {
        NSString *key = [_tabs objectAtIndex:index];
        [self.delegate swipeController:self didLongPressCellWithKey:key];
    }
}

@end
