//
//  DPSwipeViewController.h
//  EventGenie
//
//  Created by Hugo Rumens on 14/01/2014.
//  Copyright (c) 2014 GenieMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPScrollableView.h"

FOUNDATION_EXPORT NSInteger const DPScrollableViewTagIdentifier;

@class DPSwipeViewController;


@protocol DPSwipeViewControllerDelegate <NSObject>

@required;

- (UIViewController *)swipeController:(DPSwipeViewController *)swipe viewControllerForKey:(NSString *)key;

@optional

- (NSString *)swipeController:(DPSwipeViewController *)swipe tabTitleForKey:(NSString *)key;
- (void)swipeController:(DPSwipeViewController *)swipe willTransitionFromController:(UIViewController *)fromVC withKey:(NSString *)fromKey toController:(UIViewController *)toVC withKey:(NSString *)toKey;
- (void)swipeController:(DPSwipeViewController *)swipe didTransitionFromController:(UIViewController *)fromVC withKey:(NSString *)fromKey toController:(UIViewController *)toVC withKey:(NSString *)toKey;
- (UIView *)swipeController:(DPSwipeViewController *)swipe tabViewForKey:(NSString *)key;
- (void)swipeController:(DPSwipeViewController *)swipe didLongPressCellWithKey:(NSString *)key;

@end


@interface DPSwipeViewController : UIViewController <DPScrollableViewDatasource>
{
    BOOL swiping;
    int transitioningTo;
    NSArray *_tabs;
    NSMutableDictionary *_viewControllerCache;
}

@property (nonatomic, strong) NSString *currentTab;
@property (nonatomic, weak) id <DPSwipeViewControllerDelegate> delegate;
@property (nonatomic, strong) DPScrollableView *scrollableView;
@property (nonatomic) BOOL showPointer;

- (id)initWithDelegate:(id <DPSwipeViewControllerDelegate>)delegate tabs:(NSArray *)tabs startingTab:(NSString *)startTab;
- (void)setNewKey:(NSString *)newKey forControllerWithExistingKey:(NSString *)key;
- (void)resetViewControllerWithKey:(NSString *)key;
- (void)setSelectedKey:(NSString *)key;
- (void)reloadTabWithKey:(NSString *)key;
- (void)setTabs:(NSArray *)tabs;
- (void)scrollTabIntoViewIfNeededForKey:(NSString *)key;
- (void)childViewControllerViewTapped;

@end
