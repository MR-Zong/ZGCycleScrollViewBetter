//
//  ZGCycleScrollView.m
//  ZGCycleScrollView
//
//  Created by 徐宗根 on 2018/1/23.
//  Copyright © 2018年 徐宗根. All rights reserved.
//

#import "ZGCycleScrollView.h"

#define ZGDefaultPageTimeInterval 5.0

@interface ZGCycleScrollView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

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
        _pageTimeInterval = ZGDefaultPageTimeInterval;
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        [self setupViews];
        
        [self startTimer];

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
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(zg_cycleCollectionView:numberOfItemsInSection:)]) {
        self.numberOfDataItems = [self.delegate zg_cycleCollectionView:collectionView numberOfItemsInSection:section];
    }
    return self.numberOfCellItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(zg_cycleCollectionView:cellForItemAtIndexPath:)]) {
        cell =  [self.delegate zg_cycleCollectionView:collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self indexWithIndexPath:indexPath] inSection:indexPath.section]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zg_cycleCollectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate zg_cycleCollectionView:collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:[self indexWithIndexPath:indexPath] inSection:indexPath.section]];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.bounds.size;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat startEdge = 0;
    CGFloat endEdge = scrollView.bounds.size.width;
    CGFloat contentOffsetTarget = scrollView.contentOffset.x;
    if (self.scrollPosition == UICollectionViewScrollDirectionVertical) {
        startEdge = 0;
        endEdge = scrollView.bounds.size.height;
        contentOffsetTarget = scrollView.contentOffset.y;
    }
    
    if (contentOffsetTarget > startEdge  && contentOffsetTarget <= endEdge ) {
        ;
    }else {
        
        [self cycleScrollOperationWithScrollView:scrollView];
    }

}

- (void)cycleScrollOperationWithScrollView:(UIScrollView *)scrollView
{
    NSInteger curIndex = [self indexWithScrollView:scrollView];

    if (curIndex == 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.numberOfCellItems - 2 inSection:0] atScrollPosition:self.scrollPosition animated:NO];
        self.pageControl.currentPage = self.numberOfDataItems - 1;
    }else if(curIndex == self.numberOfCellItems - 1){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:self.scrollPosition animated:NO];
        self.pageControl.currentPage = 0;
    }else {
        self.pageControl.currentPage = curIndex - 1;
    }
    
    // 特别处理代理方法
    static NSInteger preIndex = -1;
    if (preIndex != self.pageControl.currentPage) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(zg_cycleScrollView:didScrollToIndex:)]) {
            [self.delegate zg_cycleScrollView:self didScrollToIndex:self.pageControl.currentPage];
        }
    }
    preIndex = self.pageControl.currentPage;
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
    NSInteger curIndex = [self indexWithScrollView:scrollView];
    NSInteger nextItem = curIndex + 1;
    if(curIndex == 0){
        nextItem = self.numberOfCellItems - 2;
    }else if (curIndex == self.numberOfCellItems - 1) {
        nextItem = 1;
    }
    NSIndexPath *nextIndexP = [NSIndexPath indexPathForItem:nextItem inSection:0];
    [self.collectionView scrollToItemAtIndexPath:nextIndexP atScrollPosition:self.scrollPosition animated:YES];
    
}

#pragma mark -setter
- (void)setPageTimeInterval:(NSTimeInterval)pageTimeInterval
{
    _pageTimeInterval = pageTimeInterval;
    if (_pageTimeInterval == 0) {
        _pageTimeInterval = ZGDefaultPageTimeInterval;
    }
    [self resetTimer];
}

@end
