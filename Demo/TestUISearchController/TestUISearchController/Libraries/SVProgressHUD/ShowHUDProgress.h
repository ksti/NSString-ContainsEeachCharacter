//
//  ShowHUDProgress.h
//  TianXingJian
//
//  Created by GJ on 15/7/13.
//  Copyright (c) 2015年 xidian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SVProgressHUD.h"

@interface ShowHUDProgress : UIView

/**
 *  显示正在加载动画
 */
+(void)showHUDProgress;

/**
 *  显示带说明的错误HUD
 */
+(void)showHUDWithErrorMessage:(NSString *)strError;

/**
 *  显示成功HUD
 */
+(void)showHUDWithSuccessMessage:(NSString *)strSuccess;

/**
 *  隐藏HUD
 */
+(void)hideHUDInView:(UIView *)aboveView;

@end
