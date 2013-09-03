//
//  DPViewController.h
//  Slidey
//
//  Created by Govi on 16/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPScrollableView.h"

@class DPSlideyViewController;

@protocol DPSlideyViewControllerDelegate <NSObject>

@optional
-(void) slideyController:(DPSlideyViewController *)slidey willTransitionFrom:(NSInteger)from viewController:(UIViewController *)fromvc to:(NSInteger)to viewController:(UIViewController *)tovc;
-(void) slideyController:(DPSlideyViewController *)slidey didTransitionFrom:(NSInteger)from viewController:(UIViewController *)fromvc to:(NSInteger)to viewController:(UIViewController *)tovc;
-(UIViewController *) slideyController:(DPSlideyViewController *)slidey viewControllerForPage:(NSInteger)page;
-(NSInteger) numberOfCellsForSlideyViewController:(DPSlideyViewController *)vc;

@end

@interface DPSlideyViewController : UIViewController <UIScrollViewDelegate, DPSlideyViewControllerDelegate, DPScrollableViewDatasource> {
    BOOL swiping;
    int transitioningTo;
}

@property (nonatomic) int numberOfPages;
@property (nonatomic) float startOffset;
@property (nonatomic) int currentPage;
@property (nonatomic, weak) id<DPSlideyViewControllerDelegate> delegate;
@property (nonatomic, strong) DPScrollableView *scrollableView;

-(id)initWithDelegate:(id<DPSlideyViewControllerDelegate>)delegate;

@end
