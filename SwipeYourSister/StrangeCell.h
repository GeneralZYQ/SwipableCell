//
//  StrangeCell.h
//  SwipeYourSister
//
//  Created by ZhangYuanqing on 14-10-20.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StrangeCell : UITableViewCell

@property (nonatomic, retain) NSString *ItemText;

@property (nonatomic, retain) UIView *myContentView;
@property (nonatomic, retain) UILabel *myTextLabel;

@property (nonatomic, retain) NSArray* buttonTitles;

@end
