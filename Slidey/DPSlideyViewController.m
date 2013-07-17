//
//  DPViewController.m
//  Slidey
//
//  Created by Govi on 16/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import "DPSlideyViewController.h"
#import "DPContentViewController.h"

@interface DPSlideyViewController ()

@end

@implementation DPSlideyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.numberOfPages = 4;
	// Do any additional setup after loading the view, typically from a nib.
    
    UIView* contentView = ((UIViewController *)[self viewControllerForPage:0]).view;
    contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:right];
    
    self.currentPage = 0;
}

-(void)swiping:(UISwipeGestureRecognizer *)gesture {
    int from = self.currentPage;
    int to = self.currentPage + 1;
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        to = self.currentPage - 1;
    }
    
    if(from != to && to < self.numberOfPages && to >= 0) {
        UIViewController *fromvc = [self viewControllerForPage:from];
        UIViewController *tovc = [self viewControllerForPage:to];
        tovc.view.frame = fromvc.view.frame;
        tovc.view.center = CGPointMake(3*fromvc.view.center.x*(to-from), fromvc.view.center.y);
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(slideyController:willTransitionFrom:viewController:to:viewController:)])
            [self.delegate slideyController:self willTransitionFrom:(NSInteger)from viewController:fromvc to:(NSInteger)to viewController:tovc];
        
        [self transitionFromViewController:fromvc toViewController:tovc duration:0.4 options:UIViewAnimationOptionTransitionNone animations:^{
            float tmp = fromvc.view.center.x;
            fromvc.view.center = CGPointMake(3*fromvc.view.center.x*(from-to), fromvc.view.center.y);
            tovc.view.center = CGPointMake(tmp, fromvc.view.center.y);
        } completion:^(BOOL finished) {
            self.currentPage = to;
            if(self.delegate && [self.delegate respondsToSelector:@selector(slideyController:didTransitionFrom:viewController:to:viewController:)])
                [self.delegate slideyController:self didTransitionFrom:from viewController:fromvc to:to viewController:tovc];
        }];
    }
}

-(void)setNumberOfPages:(int)numberOfPages {
    _numberOfPages = numberOfPages;
    [self resetChildViewControllers];
}

-(void) resetChildViewControllers {
    for (UIViewController *controller in self.childViewControllers) {
        [controller removeFromParentViewController];
    }
}

-(UIViewController *)viewControllerForPage:(NSInteger)page {
    if(page < [self.childViewControllers count]) {
        return self.childViewControllers[page];
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(slideyController:viewControllerForPage:)]) {
            return [_delegate slideyController:self viewControllerForPage:page];
        }
        return nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)slideyController:(DPSlideyViewController *)slidey willTransitionFrom:(NSInteger)from viewController:(UIViewController *)fromvc to:(NSInteger)to viewController:(UIViewController *)tovc {
    ((DPContentViewController *)fromvc).label.text = [NSString stringWithFormat:@"%d", from];
    ((DPContentViewController *)tovc).label.text = [NSString stringWithFormat:@"%d", to];
}

-(UIViewController *)slideyController:(DPSlideyViewController *)slidey viewControllerForPage:(NSInteger)page {
    DPContentViewController *vc = [[DPContentViewController alloc] init];
    [self addChildViewController:vc];
    return vc;
}

@end
