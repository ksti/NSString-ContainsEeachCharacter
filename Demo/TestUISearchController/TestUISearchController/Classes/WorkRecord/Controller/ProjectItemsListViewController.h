//
//  ProjectItemsListViewController.h
//  eForp
//
//  Created by GJS on 2017/7/19.
//
//

#import <UIKit/UIKit.h>

@class ProjectItemModel;

//block重命名
typedef void(^SelectedItemHandler)(ProjectItemModel * itemModel, NSIndexPath * indexPath);

@interface ProjectItemsListViewController : UIViewController

@property (nonatomic, copy) SelectedItemHandler selectedItemHandler;

@end
