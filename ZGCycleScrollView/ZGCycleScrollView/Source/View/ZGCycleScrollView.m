//
//  ZGCycleScrollView.m
//  ZGCycleScrollView
//
//  Created by 徐宗根 on 2018/1/23.
//  Copyright © 2018年 徐宗根. All rights reserved.
//

#import "ZGCycleScrollView.h"

@interface ZGCycleScrollView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) CGFloat pageControlHeight;
@property (nonatomic, assign) NSInteger numberOfCellItems;
@property (nonatomic, assign) NSInteger numberOfDataItems;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) UICollectionViewScrollPosition scrollPosition;


@end

@implementation ZGCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _pageControlHeight = 40;
        _pageTimeInterval = 5.0;
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];
    
    // pageControl
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.hidesForSinglePage = YES;
    [self addSubview:_pageControl];
    
    [self startTimer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = self.bounds.size;

    // collectionView
    self.collectionView.frame = self.bounds;
    
    // pageControl
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height - self.pageControlHeight, self.bounds.size.width, self.pageControlHeight);
    
    // scrollView
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:self.scrollPosition animated:NO];

}


#pragma mark - setter
- (void)setNumberOfDataItems:(NSInteger)numberOfDataItems
{
    _numberOfDataItems = numberOfDataItems;
    
    self.numberOfCellItems = numberOfDataItems + 2;
    
    self.collectionView.scrollEnabled = (numberOfDataItems != 1);
    
    // pageControl
    self.pageControl.numberOfPages = numberOfDataItems;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        self.pageControl.hidden = NO;
    }else {
        self.pageControl.hidden = YES;
    }

    
    
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = scrollDirection;
    
    if (scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        self.scrollPosition = UICollectionViewScrollPositionLeft;
    }else {
        self.scrollPosition = UICollectionViewScrollPositionTop;
    }
    
}

#pragma mark -
- (NSInteger)indexWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item;
    if (indexPath.item == 0) {
        index = self.numberOfDataItems-1;
    }else if (indexPath.item == self.numberOfCellItems - 1) {
        index = 0;
    }else {
        index--;
    }
    return index;
}

- (NSInteger)indexWithScrollView:(UIScrollView *)scrollView
{
    NSInteger index;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        
        index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    }else {
        index = scrollView.contentOffset.y / scrollView.bounds.size.height;
    }
    return index;
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zgCycleCollectionView:numberOfItemsInSection:)]) {
        self.numberOfDataItems = [self.delegate zgCycleCollectionView:collectionView numberOfItemsInSection:section];
    }
    return self.numberOfCellItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(zgCycleCollectionView:cellForItemAtIndexPath:)]) {
        cell =  [self.delegate zgCycleCollectionView:collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self indexWithIndexPath:indexPath] inSection:indexPath.section]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zgCycleCollectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate zgCycleCollectionView:collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:[self indexWithIndexPath:indexPath] inSection:indexPath.section]];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startTimer];
    [self cycleScrollOperationWithScrollView:scrollView];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self cycleScrollOperationWithScrollView:scrollView];
}

- (void)cycleScrollOperationWithScrollView:(UIScrollView *)scrollView
{
    NSInteger index = [self indexWithScrollView:scrollView];
//    NSLog(@"index %zd",index);
    
    if (index == 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.numberOfCellItems - 2 inSection:0] atScrollPosition:self.scrollPosition animated:NO];
        self.pageControl.currentPage = self.numberOfDataItems - 1;
    }else if(index == self.numberOfCellItems - 1){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:self.scrollPosition animated:NO];
        self.pageControl.currentPage = 0;
    }else {
        self.pageControl.currentPage = index - 1;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(zgCycleScrollView:didScrollToIndex:)]) {
        [self.delegate zgCycleScrollView:self didScrollToIndex:self.pageControl.currentPage];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

#pragma mark - Tiemr
- (void)resetTimer
{
    [self stopTimer];
    [self startTimer];
}

- (void)startTimer
{
    self.timer = [NSTimer timerWithTimeInterval:self.pageTimeInterval target:self selector:@selector(doTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)doTimer
{
    [self scrollToNextPageWithScrollView:self.collectionView];
}

#pragma mark -
- (void)scrollToNextPageWithScrollView:(UIScrollView *)scrollView
{
    NSInteger index = [self indexWithScrollView:scrollView];
    NSInteger nextItem = index + 1;
    if (nextItem > self.numberOfCellItems - 1) {
        nextItem = self.numberOfCellItems - 1;
    }
    NSIndexPath *nextIndexP = [NSIndexPath indexPathForItem:nextItem inSection:0];
    [self.collectionView scrollToItemAtIndexPath:nextIndexP atScrollPosition:self.scrollPosition animated:YES];
    
}

@end
