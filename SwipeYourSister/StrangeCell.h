//
//  StrangeCell.h
//  SwipeYourSister
//
//  Created by ZhangYuanqing on 14-10-20.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StrangeCellDelegate;

@interface StrangeCell : UITableViewCell

@property (nonatomic, assign) id<StrangeCellDelegate> delegate;

@property (nonatomic, retain) NSString *ItemText;

@property (nonatomic, retain) UIView *myContentView;
@property (nonatomic, retain) UILabel *myTextLabel;

@property (nonatomic, retain) NSArray* buttonTitles;

@end

@protocol StrangeCellDelegate <NSObject>

- (void)strangeCellDidPressButtonWithTitle:(NSString *)title cell:(StrangeCell *)cell;

@end
