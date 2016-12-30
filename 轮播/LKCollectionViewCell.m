//
//  LKCollectionViewCell.m
//  轮播
//
//  Created by Mike on 2016/12/29.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "LKCollectionViewCell.h"
#import "LKModel.h"

@interface LKCollectionViewCell ()

@property (nonatomic,strong) UIImageView *imageView;

@end
@implementation LKCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubviews];
    }
    return self;
}
- (void)addSubviews
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:self.imageView];
}
- (void)setModel:(LKModel *)model
{
    _model = model;
    
    NSData *data = [NSData dataWithContentsOfURL:model.url];
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = [self WithImage:image RightSize:self.imageView.bounds.size];
//    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

//绘制图片
- (UIImage *)WithImage:(UIImage *)image RightSize:(CGSize)size
{
    //创建一个基于位图的上下文（context）,并将其设置为当前上下文(context)。
    //第二个参数透明开关，如果图形完全不用透明，设置为YES以优化位图的存储
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    //重绘
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前上下文获取新的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
