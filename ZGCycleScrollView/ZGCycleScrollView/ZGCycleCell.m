//
//  ZGCycleCell.m
//  ZGCycleScrollView
//
//  Created by 徐宗根 on 2018/1/23.
//  Copyright © 2018年 徐宗根. All rights reserved.
//

#import "ZGCycleCell.h"

@implementation ZGCycleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor orangeColor];
        
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:25];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

@end
