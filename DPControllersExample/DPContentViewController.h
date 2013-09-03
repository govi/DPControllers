//
//  DPContentViewController.h
//  Slidey
//
//  Created by Govi on 16/07/2013.
//  Copyright (c) 2013 DP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPNiftyProgressBar;

@interface DPContentViewController : UIViewController {
    DPNiftyProgressBar *progress1;
    DPNiftyProgressBar *progress2;
    DPNiftyProgressBar *progress4;
    DPNiftyProgressBar *progress5;
}

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
