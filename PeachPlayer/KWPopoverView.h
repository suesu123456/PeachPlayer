//
//  KWPopoverView.h
//  PeachPlayer
//
//  Created by yxk on 16/3/10.
//  Copyright © 2016年 yxk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWPopoverView : UIView

+ (void)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view withContentView:(UIView *)cView;

@end
