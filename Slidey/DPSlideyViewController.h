//
//  DPViewController.h
//  Slidey
//
//  Created by Govi on 16/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPSlideyViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) int numberOfPages;
@property (nonatomic) float startOffset;
@property (nonatomic) int currentPage;

@end
