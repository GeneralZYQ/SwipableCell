//
//  StrangeCell.m
//  SwipeYourSister
//
//  Created by ZhangYuanqing on 14-10-20.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

//this class refrences to the article http://www.raywenderlich.com/62435/make-swipeable-table-view-cell-actions-without-going-nuts-scroll-views

#import "StrangeCell.h"

static CGFloat const kBounceValue = 20.0f;

#define kWidth [UIScreen mainScreen].bounds.size.width

@interface StrangeCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
//@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, assign) CGFloat startLeftPoint;

@property (nonatomic,assign) BOOL isOpened;

@property (nonatomic, retain) NSMutableArray *buttons;

@end

@implementation StrangeCell

- (void)awakeFromNib {
    // Initialization code
    self.myContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height)];
    self.myContentView.backgroundColor = [UIColor greenColor];
    
    [self.contentView addSubview:self.myContentView];
    
    self.myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 180, 24)];
    [self.myContentView addSubview:self.myTextLabel];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.myContentView addGestureRecognizer:self.panRecognizer];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    self.tapRecognizer.delegate = self;
    [self.myContentView addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.enabled = NO;
    
    self.buttons = [NSMutableArray arrayWithCapacity:0];
    
}

- (void)setButtonTitles:(NSArray *)buttonTitles {
    
    _buttonTitles = buttonTitles;
    
    for (UIButton *button in self.buttons) {
        [button removeFromSuperview];
    }
    
    [self.buttons removeAllObjects];
    
    for (NSString *title in buttonTitles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.frame.size.width - 50 * (buttonTitles.count - [buttonTitles indexOfObject:title]), 0, 50, self.frame.size.height);
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        [self.contentView sendSubviewToBack:button];
        [self.buttons addObject:button];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.myContentView];
            self.startLeftPoint = self.myContentView.frame.origin.x;
            NSLog(@"Pan Began at %@", NSStringFromCGPoint(self.panStartPoint));
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.myContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {  //1
                panningLeft = YES;
            }
            
            if (self.startLeftPoint == 0) {
                
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0);
                    
                    if (constant == 0) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        
                        CGRect rect = self.myContentView.frame;
                        rect.origin.x = -constant;
                        self.myContentView .frame = rect;
                    }
                    
                } else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
                    
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        CGRect rect = self.myContentView.frame;
                        rect.origin.x = -constant;
                        self.myContentView.frame = rect;
                        
                    }
                }
            } else {
                
                CGFloat adjustment = self.startLeftPoint + deltaX;
                
                if (!panningLeft) {
                    
                    CGFloat constant = MIN(adjustment, 0);
                    
                    if (constant == 0) {
                        
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                        
                    } else {
                        
                        CGRect rect = self.myContentView.frame;
                        rect.origin.x = adjustment;
                        self.myContentView.frame = rect;
                    }
                    
                } else {
                    
                    CGFloat constant = MIN(-adjustment, [self buttonTotalWidth]);
                    
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        
                        CGRect rect = self.myContentView.frame;
                        rect.origin.x = adjustment;
                        self.myContentView.frame = rect;
                    }
                }
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
//            NSLog(@"Pan Ended");
            
            if (self.startLeftPoint == 0) { //1
                //Cell was opening
                CGFloat halfOfButtonOne = 50 / 2; //2
                if (-self.myContentView.frame.origin.x >= halfOfButtonOne) { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                //Cell was closing
                CGFloat buttonOnePlusHalfOfButton2 = 50 + (50 / 2); //4
                if (-self.myContentView.frame.origin.x >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
//            NSLog(@"Pan Cancelled");
            if (self.startLeftPoint == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}

- (void)tapped:(id)sender {
    
    NSLog(@"this is tapped");
    
    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.5;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}

- (CGFloat)buttonTotalWidth {
//    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.button2.frame);
//    return 100;
    return self.buttonTitles.count * 50;
}

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    //TODO: Notify delegate.
    
    if (self.startLeftPoint == 0 &&
        self.myContentView.frame.origin.x == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    [UIView animateWithDuration:0.1 animations:^(void) {
        
        CGRect rect = self.myContentView.frame;
        rect.origin.x = 0;
        self.myContentView.frame = rect;
        
    }completion:^(BOOL finished) {
        self.startLeftPoint = self.myContentView.frame.origin.x;
    }];
    
    self.isOpened = NO;
    self.tapRecognizer.enabled = NO;
    
}

- (void)buttonPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSString *title = [button titleForState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(strangeCellDidPressButtonWithTitle: cell:)]) {
        [self.delegate strangeCellDidPressButtonWithTitle:title cell:self];
    }
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
     //TODO: Notify delegate.
    if (self.startLeftPoint == -[self buttonTotalWidth] &&
        self.myContentView.frame.origin.x == -[self buttonTotalWidth]) {
        return;
    }
    
    //    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    CGRect rect = self.myContentView.frame;
    rect.origin.x = - [self buttonTotalWidth] - kBounceValue;
    self.myContentView.frame = rect;
    
    [UIView animateWithDuration:0.1 animations:^(void) {
        
        CGRect rect = self.myContentView.frame;
        rect.origin.x = - [self buttonTotalWidth];
        self.myContentView.frame = rect;
        
    }completion:^(BOOL finished) {
        self.startLeftPoint = self.myContentView.frame.origin.x;
    }];
    
    self.isOpened = YES;
    self.tapRecognizer.enabled = YES;
}

- (void)setItemText:(NSString *)ItemText {
    
    _ItemText = ItemText;
    
    self.myTextLabel.text = ItemText;
    
    CGRect rect = self.myContentView.frame;
    rect.size.width =  self.frame.size.width;
    rect.size.height = self.frame.size.height;
    self.myContentView.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
