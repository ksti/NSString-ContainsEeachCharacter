//
//  WorkReocrdModel.m
//  eForp
//
//  Created by GJS on 2017/7/14.
//
//

#import "WorkReocrdModel.h"

@implementation WorkReocrdModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        //
        self.workRecordImageOriginalUrls = dict[@"originalUrls"];
        self.workRecordImageThumbnailUrls = dict[@"thumbnailUrls"];
        self.workRecordTime = dict[@"workRecordTime"];
        self.workDescription = dict[@"workDescription"];
        self.workRecordLocation = dict[@"workRecordLocation"];
    }
    return self;
}

+ (NSArray *)testThumbnailImageUrls {
    // 1. 创建图片链接数组
    NSMutableArray *thumbnailImageUrls = [NSMutableArray array];
    // 添加图片(缩略图)链接
    [thumbnailImageUrls addObject:@"http://ww3.sinaimg.cn/thumbnail/006ka0Iygw1f6bqm7zukpj30g60kzdi2.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/61b69811gw1f6bqb1bfd2j20b4095dfy.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/54477ddfgw1f6bqkbanqoj20ku0rsn4d.jpg"];
    [thumbnailImageUrls addObject:@"http://ww4.sinaimg.cn/thumbnail/006ka0Iygw1f6b8gpwr2tj30bc0bqmyz.jpg"];
    [thumbnailImageUrls addObject:@"http://ww2.sinaimg.cn/thumbnail/9c2b5f31jw1f6bqtinmpyj20dw0ae76e.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/536e7093jw1f6bqdj3lpjj20va134ana.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/75b1a75fjw1f6bqn35ij6j20ck0g8jtf.jpg"];
    [thumbnailImageUrls addObject:@"http://ww4.sinaimg.cn/bmiddle/406ef017jw1ec40av2nscj20ip4p0b29.jpg"];
    [thumbnailImageUrls addObject:@"http://ww1.sinaimg.cn/thumbnail/86afb21egw1f6bq3lq0itj20gg0c2myt.jpg"];
    
    return [thumbnailImageUrls copy];
}

+ (NSArray *)testOriginalImageUrls {
    // 1.2 创建图片原图链接数组
    NSMutableArray *originalImageUrls = [NSMutableArray array];
    // 添加图片(原图)链接
    [originalImageUrls addObject:@"http://ww3.sinaimg.cn/large/006ka0Iygw1f6bqm7zukpj30g60kzdi2.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/61b69811gw1f6bqb1bfd2j20b4095dfy.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/54477ddfgw1f6bqkbanqoj20ku0rsn4d.jpg"];
    [originalImageUrls addObject:@"http://ww4.sinaimg.cn/large/006ka0Iygw1f6b8gpwr2tj30bc0bqmyz.jpg"];
    [originalImageUrls addObject:@"http://ww2.sinaimg.cn/large/9c2b5f31jw1f6bqtinmpyj20dw0ae76e.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/536e7093jw1f6bqdj3lpjj20va134ana.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/75b1a75fjw1f6bqn35ij6j20ck0g8jtf.jpg"];
    [originalImageUrls addObject:@"http://ww4.sinaimg.cn/bmiddle/406ef017jw1ec40av2nscj20ip4p0b29.jpg"];
    [originalImageUrls addObject:@"http://ww1.sinaimg.cn/large/86afb21egw1f6bq3lq0itj20gg0c2myt.jpg"];
    
    return [originalImageUrls copy];
}

@end
