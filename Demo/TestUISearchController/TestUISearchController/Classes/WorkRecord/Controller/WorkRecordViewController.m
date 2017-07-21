//
//  WorkRecordViewController.m
//  eForp
//
//  Created by GJS on 2017/7/12.
//
//

#import "WorkRecordViewController.h"
#import "PYPhotosView.h"
#import "PYPhoto.h"
#import "PYPhotosPreviewController.h"
//
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"
//
#import "ProjectItemsListViewController.h"

#define kWorkDes @"工作描述"

@interface WorkRecordViewController () <PYPhotosViewDelegate,TZImagePickerControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UITextViewDelegate> {
    
    NSMutableArray *_originalWorkRecordPhotos; // 记录原始图片数组(用于再编辑)
    NSArray *_originalWorkRecordPhotosCopy; // 拷贝一份原始图片数组
    
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    BOOL _isSelectOriginalPhoto;
    
    __weak IBOutlet NSLayoutConstraint *lcBottomContainerTopTo;
    __weak IBOutlet UIButton *btnSelectItem;
    __weak IBOutlet UIButton *btnSelectItemArrow;
    __weak IBOutlet UIView *viewSeperateLine;
    __weak IBOutlet UITextView *tvWorkDescription;
    __weak IBOutlet UILabel *lblRecordTime;
    __weak IBOutlet UILabel *lblRecordLocation;
    
    NSString *strWorkDescription;
}
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (strong, nonatomic) CLLocation *location;
// 6个设置开关
@property (assign, nonatomic) BOOL showTakePhotoBtn;  ///< 在内部显示拍照按钮
@property (assign, nonatomic) BOOL sortAscending;     ///< 照片排列按修改时间升序
@property (assign, nonatomic) BOOL allowPickingVideo; ///< 允许选择视频
@property (assign, nonatomic) BOOL allowPickingImage; ///< 允许选择图片
@property (assign, nonatomic) BOOL allowPickingGif;
@property (assign, nonatomic) BOOL allowPickingOriginalPhoto; ///< 允许选择原图
@property (assign, nonatomic) BOOL showSheet; ///< 显示一个sheet,把拍照按钮放在外面
@property (assign, nonatomic) BOOL allowCrop;
@property (assign, nonatomic) BOOL needCircleCrop;

/** 即将发布的图片存储的photosView */
@property (nonatomic, weak) PYPhotosView *publishPhotosView;

@end

@implementation WorkRecordViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self defaultInitSettings];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultInitSettings];
    }
    return self;
}

// 初始化设置
- (void)defaultInitSettings
{
    //
    self.allowPickingImage = YES; // 允许选择图片
    self.showTakePhotoBtn = YES; // 在内部显示拍照按钮
    self.imagePickerMaxCount = 9; // 默认做多可选9张
}

// lazy load
- (NSInteger)imagePickerColumnNumber {
    if (_imagePickerColumnNumber <= 0) {
        _imagePickerColumnNumber = 4;
    }
    return _imagePickerColumnNumber;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 初始化
    [self setup];
    // 加载设置
    [self loadDefaultSettings];
    // 加载数据
    [self loadDefaultData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 初始化
- (void)setup
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(send)];
    self.title = @"添加工作记录";
    self.navigationController.navigationBarHidden = NO;
    
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    
    // 创建一个photosView
    [self setUpPYPhotosView];
}

- (void)setUpPYPhotosView {
    // 1. 创建一个发布图片时的photosView
    PYPhotosView *publishPhotosView = [PYPhotosView photosView];
    // 1.1 一些设置
    publishPhotosView.photosMaxCol = 4;
    publishPhotosView.hideDeleteView = YES;
    publishPhotosView.autoSetPhotoState = NO;
    if (self.workRecordState == WorkRecordStateEditable) {
        publishPhotosView.photosState = PYPhotosViewStateWillCompose;
    } else {
        publishPhotosView.photosState = PYPhotosViewStateDidCompose;
    }
    // 2. 添加本地图片
    NSMutableArray *imagesM = [NSMutableArray array];
    
    // 2.1 设置视图位置
    //publishPhotosView.py_x = PYMargin * 5;
    //publishPhotosView.py_y = PYMargin * 2 + 64;
    publishPhotosView.py_x = 8;
    publishPhotosView.py_y = 64 + 120; // 其上还有个 120 高度的视图
    // 2.2 设置本地图片
    /*
    if (self.workRecordState == WorkRecordStateEditable) {
        publishPhotosView.images = imagesM; // 会设置publishPhotosView为发布模式
    } else {
        publishPhotosView.photos = imagesM; // 会设置publishPhotosView为已发布模式
    }
     */
    /* 测试数据
    publishPhotosView.thumbnailUrls = [WorkReocrdModel testThumbnailImageUrls];
    publishPhotosView.originalUrls = [WorkReocrdModel testOriginalImageUrls]; // 会设置publishPhotosView为已发布模式
    */
    if (self.workRecordModel) {
        publishPhotosView.thumbnailUrls = self.workRecordModel.workRecordImageThumbnailUrls;
        publishPhotosView.originalUrls = self.workRecordModel.workRecordImageOriginalUrls; // 会设置publishPhotosView为已发布模式
    }
    // 3. 设置代理
    publishPhotosView.delegate = self;
    
    // 4. 添加photosView
    [self.view addSubview:publishPhotosView];
    self.publishPhotosView = publishPhotosView;
    
    //
    _originalWorkRecordPhotos = [self.publishPhotosView.images mutableCopy];
    _originalWorkRecordPhotosCopy = [_originalWorkRecordPhotos copy];
    // 同步可选最大张数
    [self refreshImagePickerMaxCount];
    // 同步更新其下视图的位置
    [self refreshLayout];
}

- (void)loadDefaultSettings {
    if (self.workRecordState == WorkRecordStateEditable) {
        //
        tvWorkDescription.editable = YES;
        tvWorkDescription.scrollEnabled = YES;
        btnSelectItem.enabled = YES;
        btnSelectItemArrow.hidden = NO;
    } else {
        //
        tvWorkDescription.scrollEnabled = YES;
        tvWorkDescription.editable = NO;
        btnSelectItem.enabled = NO;
        btnSelectItemArrow.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)loadDefaultData {
    // load data
    // 加载工作项目
    NSString *itemName = self.workRecordModel.selectedItem.itemName;
    if (self.workRecordState == WorkRecordStateEditable) {
        [btnSelectItem setTitle:itemName ?: @"请选择项目" forState:UIControlStateNormal];
    } else {
        [btnSelectItem setTitle:itemName ?: @"未选择项目" forState:UIControlStateNormal];
    }
    // 加载工作描述
    strWorkDescription = self.workRecordModel.workDescription;
    if (strWorkDescription.length > 0) {
        tvWorkDescription.text = strWorkDescription;
        tvWorkDescription.textColor = [UIColor blackColor];
    }
}

// 同步可选最大张数
- (void)refreshImagePickerMaxCount {
    self.imagePickerMaxCount = MAX(0, self.publishPhotosView.imagesMaxCountWhenWillCompose - self.publishPhotosView.images.count);
}

// 点击发送
- (void)send
{
    NSLog(@"发送 --- 共有%zd张图片", self.publishPhotosView.images.count);
}

// 点击返回
- (void)back
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadPhotosView {
    // 刷新
    NSMutableArray *mArrayImages = [_originalWorkRecordPhotos mutableCopy];
    [mArrayImages addObjectsFromArray:_selectedPhotos];
    [self.publishPhotosView reloadDataWithImages:mArrayImages];
    NSLog(@"添加图片 --- 添加后有%zd张图片", self.publishPhotosView.images.count);
    // 同步可选最大张数
    [self refreshImagePickerMaxCount];
    // 同步更新其下视图的位置
    [self refreshLayout];
}
- (void)refreshLayout {
    // 同步更新其他视图布局
    lcBottomContainerTopTo.constant = self.publishPhotosView.py_height;
}

#pragma mark - actions
- (IBAction)onSelectItem:(id)sender {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    ProjectItemsListViewController *itemsListViewController = [[ProjectItemsListViewController alloc] initWithNibName:@"ProjectItemsListViewController" bundle:nil];
    
    // Pass some object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:itemsListViewController animated:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (strWorkDescription.length <= 0) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = kWorkDes;
        textView.selectedRange = NSMakeRange(0, 0);
        
//        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1/*延迟执行时间*/ * NSEC_PER_SEC));
//        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//            textView.selectedRange = NSMakeRange(0, 0);
//        });
    }
    return YES;
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"-------textView.selectedRange.location:%zd", textView.selectedRange.location);
    if (textView.selectedRange.location == 0) {
        return;
    }
    if (strWorkDescription.length <= 0 && [textView.text isEqualToString:kWorkDes]) {
        textView.selectedRange = NSMakeRange(0, 0); // 光标定于初始位置
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"-------text:%@", text);
    if (strWorkDescription.length <= 0 && text.length > 0) {
        textView.text = @"";
    }
    if (text.length <= 0) { // 删除(替换为空)
        if ((textView.text.length == 1/*删除最后一个字符*/) || (textView.text.length == 0)) {
            strWorkDescription = @"";
            textView.textColor = [UIColor lightGrayColor];
            textView.text = kWorkDes;
        }
    } else {
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView {
    strWorkDescription = textView.text;
    NSLog(@"-------strWorkDescription:%@", strWorkDescription);
}

#pragma mark - PYPhotosViewDelegate
- (void)photosView:(PYPhotosView *)photosView didAddImageClickedWithImages:(NSMutableArray *)images
{
    NSLog(@"点击了添加图片按钮 --- 添加前有%zd张图片", images.count);
    // 在这里做当点击添加图片按钮时，你想做的事。
    // 这里默认最多导入9张，超过时取前九张
    BOOL showSheet = self.showSheet;
    if (showSheet) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"去相册选择", nil];
        [sheet showInView:self.view];
    } else {
        [self pushTZImagePickerController];
    }
}

// 进入预览图片时调用, 可以在此获得预览控制器，实现对导航栏的自定义
- (void)photosView:(PYPhotosView *)photosView didPreviewImagesWithPreviewControlelr:(PYPhotosPreviewController *)previewControlelr
{
    NSLog(@"进入预览图片");
}

// 删除图片时调用
- (void)photosView:(PYPhotosView *)photosView didDeleteImageIndex:(NSInteger)imageIndex {
    [self deleteAssetIndex:imageIndex];
}

#pragma mark 照片选择器 TZImagePickerController

#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    if (self.imagePickerMaxCount <= 0) {
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.imagePickerMaxCount columnNumber:self.imagePickerColumnNumber delegate:self pushPhotoPickerVc:YES];
    
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    if (self.imagePickerMaxCount > 1) {
        // 1.设置目前已经选中的图片数组
        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = self.showTakePhotoBtn; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = self.allowPickingVideo;
    imagePickerVc.allowPickingImage = self.allowPickingImage;
    imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
    imagePickerVc.allowPickingGif = self.allowPickingGif;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = self.sortAscending;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = self.allowCrop;
    imagePickerVc.needCircleCrop = self.needCircleCrop;
    imagePickerVc.circleCropRadius = 100;
    imagePickerVc.isStatusBarDefault = NO;
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
        _location = location;
    } failureBlock:^(NSError *error) {
        _location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = self.sortAscending;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        if (self.allowCrop) { // 允许裁剪,去裁剪
                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = self.needCircleCrop;
                            imagePicker.circleCropRadius = 100;
                            [self presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    
    // TODO: todo-->reload data
    [self reloadPhotosView];
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self pushTZImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl;
            if (alertView.tag == 1) {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            } else {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    
    // TODO: todo-->reload data
    [self reloadPhotosView];
    
    // 1.打印图片名字
    [self printAssetsName:assets];
    // 2.图片位置信息
    if (iOS8Later) {
        for (PHAsset *phAsset in assets) {
            NSLog(@"location:%@",phAsset.location);
        }
    }
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    // [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
    // NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
    // Export completed, send video here, send by outputPath or NSData
    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    
    // }];
    
    // TODO: todo-->reload data
    [self reloadPhotosView];
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // TODO: todo-->reload data
    [self reloadPhotosView];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
     return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
     return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}

#pragma mark - Click Event

- (void)deleteAssetIndex:(NSInteger)index {
    // _selectedPhotos 已经由 PYPhotosView 删除处理过了，这里只需要同步 _selectedAssets
    // 同步 _originalWorkRecordPhotos (mutableCopy 这里自行处理)
    if (index < _originalWorkRecordPhotos.count) {
        [_originalWorkRecordPhotos removeObjectAtIndex:index];
    } else {
        NSInteger toDeleteIndex = index - _originalWorkRecordPhotos.count;
        if (toDeleteIndex >= 0 && toDeleteIndex < _selectedAssets.count) {
            [_selectedAssets removeObjectAtIndex:toDeleteIndex];
        }
    }
    // 同步可选最大张数
    [self refreshImagePickerMaxCount];
}

#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        //NSLog(@"图片名字:%@",fileName);
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma clang diagnostic pop

@end
