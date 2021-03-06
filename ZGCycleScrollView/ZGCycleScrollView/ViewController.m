//
//  ViewController.m
//  ZGCycleScrollView
//
//  Created by 徐宗根 on 2018/1/23.
//  Copyright © 2018年 徐宗根. All rights reserved.
//

#import "ViewController.h"
#import "ZGCycleScrollView.h"
#import "ZGCycleCell.h"

@interface ViewController () <ZGCycleScrollViewDelegate>

@property (nonatomic, strong) ZGCycleScrollView *cycleSV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    /** ZGCycleScrollView 使用样例 **/
    
    _cycleSV = [[ZGCycleScrollView alloc] init];
    _cycleSV.delegate = self;
    _cycleSV.pageTimeInterval = 1000;
    _cycleSV.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [_cycleSV.collectionView registerClass:[ZGCycleCell class] forCellWithReuseIdentifier:@"ZGCycleCellReusedId"];
    [self.view addSubview:_cycleSV];
    
    _cycleSV.frame = CGRectMake(50, 100, 200, 100);
}


#pragma mark - ZGCycleScrollViewDelegate
- (NSInteger)zg_cycleCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}


- (UICollectionViewCell *)zg_cycleCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZGCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZGCycleCellReusedId" forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%zd",indexPath.item];
//    int R = (arc4random() % 256) ;
//    int G = (arc4random() % 256) ;
//    int B = (arc4random() % 256) ;
//    cell.backgroundColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
    return cell;
}

- (void)zg_cycleCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%zd",indexPath.row);
}

- (void)zg_cycleScrollView:(ZGCycleScrollView *)scrollView didScrollToIndex:(NSInteger)index
{
    NSLog(@"scrollTo %zd",index);
}

@end
