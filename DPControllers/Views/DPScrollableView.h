//
//  ScrollableView.h
//  EventGenie
//
//  Created by Govi Ram on 27/03/2012.
//  Copyright (c) 2012 GenieMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPScrollableViewCell.h"

typedef enum {
    PointerTypeNone,
    PointerTypeCenter,
    PointerTypeMoving,
    PointerTypeAppear
} PointerType;

@class DPScrollableView;
@class DPScrollableViewCell;

typedef struct {
    float top;
    float right;
    float bottom;
    float left;
} DPMargin;

static inline DPMargin
DPMarginMake(top, right, bottom, left)
{
    DPMargin m;
    m.top = top;
    m.right = right;
    m.bottom = bottom;
    m.left = left;
    return m;
}


#define MarginMakeZero MarginMake(0, 0, 0, 0)

@protocol DPScrollableViewDatasource <NSObject>

@optional
- (UIView *) scrollableView:(DPScrollableView *)view getViewForIndex:(NSUInteger)i;
- (UIImage *) scrollableView:(DPScrollableView *)view getImageForIndex:(NSUInteger)i;
- (NSString *) scrollableView:(DPScrollableView *)view getTitleForIndex:(NSUInteger)i;
- (void) scrollableView:(DPScrollableView *)view didAddCell:(DPScrollableViewCell *)cell;
- (void) scrollableView:(DPScrollableView *)view willSelectCellAtIndex:(NSInteger)index;
- (void) scrollableView:(DPScrollableView *)view didSelectCellAtIndex:(NSInteger)index;
- (void) scrollableView:(DPScrollableView *)view didLongPressCellAtIndex:(NSInteger)index;

@required
- (int) numberOfCellsforScrollableView:(DPScrollableView *)view;

@end


@interface DPScrollableView : UIView <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
}

@property (nonatomic) PointerType pointerType;
@property (nonatomic, weak) id <DPScrollableViewDatasource> datasource;
@property (nonatomic, strong) UIView *leftPointer;
@property (nonatomic, strong) UIView *rightPointer;
@property (nonatomic, strong) UIView *centerPointer;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSInteger selectedIndex;

- (DPScrollableViewCell *)cellAtIndex:(NSUInteger)index;
- (UIView *)viewAtIndex:(NSUInteger)index;
- (void)setHighlightOnAllRows:(BOOL)high;
- (void)reloadTabTitles;
- (void)reloadTabAtIndex:(int)index;
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;

@end


@interface UIView (Extras)

- (UIView *) subviewAtPoint:(CGPoint)point;

@end
