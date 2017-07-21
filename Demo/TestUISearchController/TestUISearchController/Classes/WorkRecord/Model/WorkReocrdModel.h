//
//  WorkReocrdModel.h
//  eForp
//
//  Created by GJS on 2017/7/14.
//
//

#import <Foundation/Foundation.h>

#import "ProjectItemModel.h"

@interface WorkReocrdModel : NSObject

@property (nonatomic, strong) ProjectItemModel *selectedItem; // 选择的项目
@property (nonatomic, copy) NSString *workDescription; // 工作描述
@property (nonatomic, copy) NSArray *workRecordImages; // 记录的图片
@property (nonatomic, copy) NSArray *workRecordImageThumbnailUrls
; // 记录的图片缩略图地址
@property (nonatomic, copy) NSArray *workRecordImageOriginalUrls; // 记录的图片原图地址
@property (nonatomic, copy) NSString *workRecordTime; // 签到时间
@property (nonatomic, copy) NSString *workRecordLocation; // 签到地点

+ (NSArray *)testThumbnailImageUrls;
+ (NSArray *)testOriginalImageUrls;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
