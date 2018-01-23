//
//  ZGCycleScrollView.h
//  ZGCycleScrollView
//
//  Created by 徐宗根 on 2018/1/23.
//  Copyright © 2018年 徐宗根. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZGCycleScrollView;

@protocol ZGCycleScrollViewDelegate <NSObject>

// 必须 实现 required 方法
@required
- (NSInteger)zgCycleCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)zgCycleCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

// 可选实现
@optional
/** 点击cell 回调
 */
- (void)zgCycleCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/** 切换下一页的时候，回调
 */
- (void)zgCycleScrollView:(ZGCycleScrollView *)scrollView didScrollToIndex:(NSInteger)index;

@end



@interface ZGCycleScrollView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) id <ZGCycleScrollViewDelegate> delegate;

/** 滚动方向 默认水平滚动
 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/** 切换下一页 时间间隔 默认间隔5秒
 */
@property (nonatomic, assign) NSTimeInterval pageTimeInterval;

@end
