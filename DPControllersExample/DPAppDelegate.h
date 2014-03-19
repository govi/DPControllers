//
//  DPAppDelegate.h
//  Slidey
//
//  Created by Govi on 16/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPSwipeViewController;
@protocol DPSwipeViewControllerDelegate;

@interface DPAppDelegate : UIResponder <UIApplicationDelegate, DPSwipeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DPSwipeViewController *viewController;

@end
