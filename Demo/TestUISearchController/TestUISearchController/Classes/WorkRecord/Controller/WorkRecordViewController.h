//
//  WorkRecordViewController.h
//  eForp
//
//  Created by GJS on 2017/7/12.
//
//

#import <UIKit/UIKit.h>
#import "WorkReocrdModel.h"

typedef NS_ENUM(NSInteger, WorkRecordState) { // 工作记录状态
    WorkRecordStateEditable = 0,   // 可编辑
    WorkRecordStateNotEditable = 1     // 不可编辑
};

@interface WorkRecordViewController : UIViewController

@property (nonatomic, assign) NSInteger imagePickerMaxCount; // 照片最大可选张数
@property (nonatomic, assign) NSInteger imagePickerColumnNumber; // 每行展示照片张数
@property (nonatomic, assign) WorkRecordState workRecordState; // 页面模式状态(0:可编辑，1:不可编辑)
@property (nonatomic, strong) WorkReocrdModel *workRecordModel;

@end
