//
//  ProjectItemsListViewController.m
//  eForp
//
//  Created by GJS on 2017/7/19.
//
//

#import "ProjectItemsListViewController.h"
#import "NSString+ContainsEeachCharacter.h"

NS_ASSUME_NONNULL_BEGIN
@interface ProjectItemsListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating>

//存放搜索列表中显示数据的数组
@property (nonatomic, strong) NSMutableArray *arrOfSeachResults;/**< 搜索结果 */
@property (nonatomic, strong) UISearchController *searchController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//存放tableView中显示的原始数据的数组
@property (strong,nonatomic) NSMutableArray *dataList;

@end
NS_ASSUME_NONNULL_END

@implementation ProjectItemsListViewController

- (NSMutableArray *)dataList {
    if (!_dataList) {
        //初始化数组并赋值
        self.dataList = [NSMutableArray arrayWithCapacity:100];
        for (NSInteger i=0; i<100; i++) {
            [self.dataList addObject:@{
                                       @"nick": [NSString stringWithFormat:@"%ld-FlyElephant中文汉字",(long)i],
                                       }];
        }
    }
    return _dataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 初始化
    [self setUp];
    // 加载设置
    [self loadDefaultSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUp {
    // nil表示在当前页面显示搜索结果
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    //searchBar的frame
    //self.searchController.searchBar.frame = CGRectMake(0, 44, 0, 44);
    //设置搜索框的frame
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    //将搜索框设置为tableView的组头
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
}

- (void)loadDefaultSetting {
    //设置代理对象
    self.searchController.searchResultsUpdater = self;/**< 显示搜索结果的VC */
    //设置搜索时，背景变暗色
    //self.searchController.dimsBackgroundDuringPresentation = NO;
    //设置搜索时，背景变模糊
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    //隐藏导航栏
    //self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.showsCancelButton = YES;/**< 取消按钮 */
    //设置 searchBar 代理对象
    self.searchController.searchBar.delegate = self;
}

- (void)loadDefaultData {
    //
}

#pragma mark - UISearchBarDelegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //获取搜索框中用户输入的字符串
    NSString *searchString = [self.searchController.searchBar text];
    //指定过滤条件，SELF表示要查询集合中对象，contain[c]表示包含字符串，%@是字符串内容
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[NSString class]]) {
            //return [(NSString *)evaluatedObject containsString:searchString];
            return [(NSString *)evaluatedObject containsEachCharacter:searchString];
        } else if ([evaluatedObject isKindOfClass:[NSDictionary class]]) {
            //return [evaluatedObject[@"nick"] containsString:searchString];
            return [evaluatedObject[@"nick"] containsEachCharacter:searchString];
        }
        return [evaluatedObject containsObject:searchString];
    }];
    //如果搜索数组中存在对象，即上次搜索的结果，则清除这些对象
    if (self.arrOfSeachResults != nil) {
        [self.arrOfSeachResults removeAllObjects];
    }
    //通过过滤条件过滤数据
    self.arrOfSeachResults = [[self.dataList filteredArrayUsingPredicate:predicate] mutableCopy];
    //刷新表格
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //如果searchController被激活就返回搜索数组的行数，否则返回数据数组的行数
    if (self.searchController.active) {
        //以搜索结果的个数返回行数
        return self.arrOfSeachResults.count;
    }else{
        //没有搜索时显示所有数据
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    // 显示搜索结果时
    if (self.searchController.active) {
        NSDictionary *searchResult = self.arrOfSeachResults[indexPath.row];
        // 原始搜索结果字符串.
        NSString *originResult = searchResult[@"nick"];
        
        /*
        // 获取关键字的位置
        NSRange range = [originResult rangeOfString:self.searchController.searchBar.text];
        // 转换成可以操作的字符串类型.
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:originResult];
        
        // 添加属性(粗体)
        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:range];
        // 关键字高亮
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        */
        
        // 转换成可以操作的字符串类型.
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:originResult];
        for (NSValue *rangeValue in [originResult rangeArrayOfEachCharacter:self.searchController.searchBar.text]) {
            // 获取关键字的位置
            NSRange range;
            [rangeValue getValue:&range];
            
            // 添加属性(粗体)
            [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:range];
            // 关键字高亮
            [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        }
        
        // 将带属性的字符串添加到cell.textLabel上.
        [cell.textLabel setAttributedText:attribute];
        cell.textLabel.text = originResult;
    } else {
        NSDictionary *data = self.dataList[indexPath.row];
        cell.textLabel.text = data[@"nick"];
    }
    
    return cell;
 }

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     /*
     // Navigation logic may go here, for example:
     // Create the next view controller.
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
     
     // Pass the selected object to the new view controller.
     
     // Push the view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
     
     // 显示搜索结果时
     if (self.searchController.active) {
         NSDictionary *searchResult = self.arrOfSeachResults[indexPath.row];
         NSLog(@"selected:%@", searchResult[@"nick"]);
     } else {
         NSDictionary *data = self.dataList[indexPath.row];
         NSLog(@"selected:%@", data[@"nick"]);
     }
 }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
