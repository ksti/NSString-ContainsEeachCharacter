//
//  ViewController.m
//  TestUISearchController
//
//  Created by GJS on 2017/7/21.
//  Copyright © 2017年 gjs. All rights reserved.
//

#import "ViewController.h"

//test
#import "WorkRecordViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testWorkRecordViewController {
    WorkRecordViewController *testWorkRecordVC = [[WorkRecordViewController alloc] initWithNibName:@"WorkRecordViewController" bundle:nil];
    WorkReocrdModel *model = [[WorkReocrdModel alloc] init];
    model.workRecordImageThumbnailUrls = [WorkReocrdModel testThumbnailImageUrls];
    model.workRecordImageOriginalUrls = [WorkReocrdModel testOriginalImageUrls];
    //    model.selectedItem = [[ProjectItemModel alloc] init];
    //    model.selectedItem.itemID = @"????";
    //    model.selectedItem.itemName = @"xxxx";
    model.workDescription = @"测试工作描述。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。xxx.........................................................ooo.........................................................";
    testWorkRecordVC.workRecordModel = model;
    [self.navigationController pushViewController:testWorkRecordVC animated:YES];
}

- (IBAction)onTestClicked:(id)sender {
    [self testWorkRecordViewController];
}

@end
