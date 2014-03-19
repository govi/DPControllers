//
//  DPScrollableView.h
//  EventGenie
//
//  Created by Hugo Rumens on 14/01/2014.
//  Copyright (c) 2014 GenieMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPScrollableViewCell.h"


@class DPScrollableView;


@protocol DPScrollableViewDatasource <NSObject>

@optional
- (UIView *)scrollableView:(DPScrollableView *)view getViewForIndex:(NSInteger)index;
- (UIImage *)scrollableView:(DPScrollableView *)view getImageForIndex:(NSInteger)index;
- (NSString *)scrollableView:(DPScrollableView *)view getTitleForIndex:(NSInteger)index;
- (void)scrollableView:(DPScrollableView *)view didAddCell:(DPScrollableViewCell *)cell;
- (void)scrollableView:(DPScrollableView *)view willSelectCellAtIndex:(NSInteger)index;
- (void)scrollableView:(DPScrollableView *)view didSelectCellAtIndex:(NSInteger)index;
- (void)scrollableView:(DPScrollableView *)view didLongPressCellAtIndex:(NSInteger)index;

@required
- (NSInteger)numberOfCellsforScrollableView:(DPScrollableView *)view;

@end


@interface DPScrollableView : UIView <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    CGPoint _contextOffsetAtStartOfDrag;
    BOOL _scrollViewDraggedBeyondContentBoundary;
    
    NSInteger _scrolledToIndex;
    CGFloat _cellWidth;
}


@property (nonatomic, weak) id <DPScrollableViewDatasource> datasource;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSInteger selectedIndex;

- (id)initWithFrame:(CGRect)frame datasource:(id <DPScrollableViewDatasource>)datasource;
- (DPScrollableViewCell *)cellAtIndex:(NSUInteger)index;
- (UIView *)viewAtIndex:(NSUInteger)index;
- (void)setHighlightOnAllRows:(BOOL)high;
- (void)reloadTabAtIndex:(NSInteger)index;
- (void)setSelectedIndex:(NSInteger)index;
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollTabIntoViewIfNeededWithIndex:(NSInteger)index;
- (void)flashLeftScrollIndicator;
- (void)flashRightScrollIndicator;
- (void)flashBothScrollIndicators;
- (void)removeScrollIndicators;

@end
