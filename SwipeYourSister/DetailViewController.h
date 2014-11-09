//
//  DetailViewController.h
//  SwipeYourSister
//
//  Created by ZhangYuanqing on 14-10-20.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

