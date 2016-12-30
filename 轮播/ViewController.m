//
//  ViewController.m
//  轮播
//
//  Created by Mike on 2016/12/29.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "ViewController.h"
#import "LKCollectionViewCell.h"
#import "LKModel.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define LKIDCell @"cell"
#define LKMaxSections 100
#define Count 3

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,strong) NSTimer *time;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"无限轮播";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadData];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageControl];
    
    [self addTime];
}
#pragma mark -
- (void)loadData
{
    for (NSInteger i = 1; i<=Count; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%02ld.jpg",i];
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        LKModel *model = [[LKModel alloc] init];
        model.url = url;
        [self.dataSource addObject:model];
    }
   
    //初始显示中间的
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:LKMaxSections/2] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
//    [self.collectionView reloadData];
}

- (void)start
{
     // 获取当前显示的cell的下标
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    //获取当前显示的cell的section
    NSIndexPath *currentIndexPathSet = [NSIndexPath indexPathForRow:currentIndexPath.row inSection:LKMaxSections/2];
    
    [self.collectionView scrollToItemAtIndexPath:currentIndexPathSet atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    //下一个cell
    NSInteger nextItem = currentIndexPath.item +1;
    //下一个section
    NSInteger nextSection = currentIndexPathSet.section;
    if (nextItem == self.dataSource.count) {
        nextItem = 0;
        nextSection++;
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:nextItem inSection:nextSection];
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}
#pragma mark -delegate&&datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return LKMaxSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //这里为了防止滚动到最后一页来回跳动导致的卡顿,多写点组数让一直到不了最后一组,因为cell重用,所以不影响内存.
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LKIDCell forIndexPath:indexPath];
    if (!cell) {
        cell = [[LKCollectionViewCell alloc] init];
    }
    cell.model = self.dataSource[indexPath.item];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 1. 获取当前停止的页面
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    //如果是第0组的第0个  跳转到 第1组的第0个
    if (index == 0) {
        index = self.dataSource.count;
    }
    //如果是第后一组的第最后一个  跳转到 第1组的最后一个
    if (index == [self.collectionView numberOfItemsInSection:0] - 1) {
        index = self.dataSource.count - 1;
    }
    scrollView.contentOffset = CGPointMake(index * scrollView.frame.size.width, 0);
   
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 1. 获取当前停止的页面
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width + 0.5;
    self.pageControl.currentPage = index % self.dataSource.count;
}
#pragma mark -layzLoad
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, 200);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 200) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[LKCollectionViewCell class] forCellWithReuseIdentifier:LKIDCell];
    }
    return _collectionView;
}
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}
- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 240, SCREEN_WIDTH, 10)];
        _pageControl.numberOfPages = self.dataSource.count;
        _pageControl.pageIndicatorTintColor = [UIColor orangeColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    }
    return _pageControl;
}
- (void)addTime
{
   self.time = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(start) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];//NSRunLoopCommonModes模式下
    [[NSRunLoop currentRunLoop] addTimer:self.time forMode:NSDefaultRunLoopMode];
}
- (void)dealloc
{
    [self.time invalidate];
    self.time = nil;
}
@end
