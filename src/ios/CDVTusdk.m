/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVTusdk.h"
#import <TuSDKGeeV1/TuSDKGeeV1.h>

#pragma mark CDVTusdk

@interface CDVTusdk()
{
    // 自定义系统相册组件
    TuSDKCPAlbumMultipleComponent *_albumComponent;
    // 图片编辑组件
    TuSDKCPPhotoEditComponent *_photoEditComponent;
    // 照片美化编辑组件
    TuSDKCPPhotoEditMultipleComponent *_photoEditMultipleComponent;
}
@end

@implementation CDVTusdk

- (void)pluginInitialize
{
    [TuSDK setLogLevel:lsqLogLevelDEBUG];
    [TuSDK initSdkWithAppKey:[[self.commandDelegate settings] objectForKey:@"tusdkappkey_ios"]];
}

- (void)openEditMultipleWithController:(UIViewController *)controller
                                result:(TuSDKResult *)result;
{
    if (!controller || !result) return;
    
    // 组件选项配置
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKCPPhotoEditMultipleComponent.html
    _photoEditMultipleComponent =
    [TuSDKGeeV1 photoEditMultipleWithController:controller
                                  callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller)
     {
         _albumComponent = nil;
         
         // 如果以 pushViewController 方式打开编辑器, autoDismissWhenCompelted参数将无效, 请使用以下方法关闭
         //if (_photoEditMultipleComponent.autoDismissWhenCompelted && controller) {
         //    [controller popViewControllerAnimated:YES];
         //}
         
         // 获取图片失败
         if (error) {
             lsqLError(@"editMultiple error: %@", error.userInfo);
             return;
         }
         [result logInfo];
         
         // 可在此添加自定义方法，将result结果传出，例如 ：  [self openEditorWithImage:result.image];
         // 并在外部使用方法接收result结果，例如 ： -(void)openEditorWithImage:(UIImage *)image;
     }];
    
    _photoEditMultipleComponent.options.editFilterOptions.filterGroup = @[@"Brilliant", @"Harmony", @"Gloss"];
    
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKCPPhotoEditMultipleOptions.html
    // _photoEditMultipleComponent.options
    
    //    // 图片编辑入口控制器配置选项
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditMultipleOptions.html
    // _photoEditMultipleComponent.options.editMultipleOptions
    //    // 禁用功能模块 默认：加载全部模块
    //    [_photoEditMultipleComponent.options.editMultipleOptions disableModule:lsqTuSDKCPEditActionCuter];
    //    // 最大输出图片按照设备屏幕 (默认:true, 如果设置了LimitSideSize, 将忽略LimitForScreen)
    //    _photoEditMultipleComponent.options.editMultipleOptions.limitForScreen = YES;
    //    // 保存到系统相册
    //    _photoEditMultipleComponent.options.editMultipleOptions.saveToAlbum = YES;
    //    // 控制器关闭后是否自动删除临时文件
    //    _photoEditMultipleComponent.options.editMultipleOptions.isAutoRemoveTemp = YES;
    //
    //    // 图片编辑滤镜控制器配置选项
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditFilterOptions.html
    // _photoEditMultipleComponent.options.editFilterOptions
    //    // 默认: true, 开启滤镜配置选项
    //    _photoEditMultipleComponent.options.editFilterOptions.enableFilterConfig = YES;
    //    // 保存到临时文件
    //    _photoEditMultipleComponent.options.editFilterOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editFilterOptions.outputCompress = 0.95f;
    //    // 滤镜列表行视图宽度
    //    _photoEditMultipleComponent.options.editFilterOptions.filterBarCellWidth = 75;
    //    // 滤镜列表选择栏高度
    //    _photoEditMultipleComponent.options.editFilterOptions.filterBarHeight = 100;
    //    // 滤镜分组列表行视图类 (默认:TuSDKCPGroupFilterGroupCell, 需要继承 TuSDKCPGroupFilterGroupCell)
    //    _photoEditMultipleComponent.options.editFilterOptions.filterBarGroupCellClazz = [TuSDKCPGroupFilterGroupCell class];
    //    // 滤镜列表行视图类 (默认:TuSDKCPGroupFilterItem, 需要继承 TuSDKCPGroupFilterItem)
    //    _photoEditMultipleComponent.options.editFilterOptions.filterBarTableCellClazz = [TuSDKCPGroupFilterItem class];
    //    // 开启用户滤镜历史记录
    //    _photoEditMultipleComponent.options.editFilterOptions.enableFilterHistory = YES;
    //    // 显示滤镜标题视图
    //    _photoEditMultipleComponent.options.editFilterOptions.displayFilterSubtitles = YES;
    //    // 是否渲染滤镜封面 (使用设置的滤镜直接渲染，需要拥有滤镜列表封面设置权限，请访问TuSDK.com控制台)
    //    _photoEditMultipleComponent.options.editFilterOptions.isRenderFilterThumb = YES;
    //
    //    // 图片编辑裁切旋转控制器配置选项
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditCuterOptions.html
    // _photoEditMultipleComponent.options.editCuterOptions
    //    // 是否开启图片旋转(默认: false)
    //    _photoEditMultipleComponent.options.editCuterOptions.enableTrun = YES;
    //    // 是否开启图片镜像(默认: false)
    //    _photoEditMultipleComponent.options.editCuterOptions.enableMirror = YES;
    //    // 裁剪比例 (默认:lsqRatioAll)
    //    _photoEditMultipleComponent.options.editCuterOptions.ratioType = lsqRatioAll;
    //    // 裁剪比例排序 (例如：@[@(lsqRatioOrgin), @(lsqRatio_1_1), @(lsqRatio_2_3), @(lsqRatio_3_4)])
    //    _photoEditMultipleComponent.options.editCuterOptions.ratioTypeList = @[@(lsqRatioOrgin), @(lsqRatio_1_1), @(lsqRatio_2_3)];
    //    // 保存到临时文件
    //    _photoEditMultipleComponent.options.editCuterOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editCuterOptions.outputCompress = 0.95f;
    //
    //    // 美颜控制器视图配置选项
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditSkinOptions.html
    // _photoEditMultipleComponent.options.editSkinOptions
    //    // 保存到临时文件
    //    _photoEditMultipleComponent.options.editSkinOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editSkinOptions.outputCompress = 0.95f;
    //
    //    // 图片编辑贴纸选择控制器配置选项
    // _photoEditMultipleComponent.options.editStickerOptions
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditStickerOptions.html
    //    // 单元格间距 (单位：DP)
    //    _photoEditMultipleComponent.options.editStickerOptions.gridPadding = 2;
    //    // 保存到临时文
    //    _photoEditMultipleComponent.options.editStickerOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editStickerOptions.outputCompress = 0.95f;
    //
    //    // 颜色调整控制器配置选项
    // _photoEditMultipleComponent.options.editAdjustOptions
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditAdjustOptions.html
    //    // 保存到临时文
    //    _photoEditMultipleComponent.options.editAdjustOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editAdjustOptions.outputCompress = 0.95f;
    //
    //    // 锐化功能控制器配置选项
    // _photoEditMultipleComponent.options.editSharpnessOptions
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditSharpnessOptions.html
    //    // 保存到临时文
    //    _photoEditMultipleComponent.options.editSharpnessOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editSharpnessOptions.outputCompress = 0.95f;
    //
    //    // 大光圈控制器配置选项
    // _photoEditMultipleComponent.options.editApertureOptions
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditApertureOptions.html
    //    // 保存到临时文
    //    _photoEditMultipleComponent.options.editApertureOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editApertureOptions.outputCompress = 0.95f;
    //
    //    // 暗角控制器功能控制器配置选项
    // _photoEditMultipleComponent.options.editVignetteOptions
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditVignetteOptions.html
    //    // 保存到临时文
    //    _photoEditMultipleComponent.options.editVignetteOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editVignetteOptions.outputCompress = 0.95f;
    //
    //    // 图片编辑涂抹控制器配置选项
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditSmudgeOptions.html
    // _photoEditMultipleComponent.options.editSmudgeOptions
    //    // 默认的笔刷大小 (默认: lsqBrushMedium，中等粗细)
    //    _photoEditMultipleComponent.options.editSmudgeOptions.defaultBrushSize = lsqMediumBrush;
    //    // 是否保存上一次使用的笔刷 (默认: YES)
    //    _photoEditMultipleComponent.options.editSmudgeOptions.saveLastBrush = YES;
    //    // 默认撤销的最大次数 (默认: 5)
    //    _photoEditMultipleComponent.options.editSmudgeOptions.maxUndoCount = 5;
    //    // 保存到临时文件
    //    _photoEditMultipleComponent.options.editSmudgeOptions.saveToTemp = YES;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editSmudgeOptions.outputCompress = 0.95f;
    //
    //    // 图片编辑模糊控制器配置选项
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditWipeAndFilterOptions.html
    // _photoEditMultipleComponent.options.editWipeAndFilterOptions
    //    // 默认的笔刷大小 (默认: lsqBrushMedium，中等粗细)
    //    _photoEditMultipleComponent.options.editWipeAndFilterOptions.defaultBrushSize = lsqMediumBrush;
    //    // 默认撤销的最大次数 (默认: 5)
    //    _photoEditMultipleComponent.options.editWipeAndFilterOptions.maxUndoCount = 5;
    //    // 保存到临时文件
    //    _photoEditMultipleComponent.options.editWipeAndFilterOptions.saveToTemp = YES;
    //    // 显示放大镜 (默认: true)
    //    _photoEditMultipleComponent.options.editWipeAndFilterOptions.displayMagnifier = YES;
    //    // 笔刷效果强度 (默认: 0.2, 范围为0 ~ 1，值为1时强度最高)
    //    _photoEditMultipleComponent.options.editWipeAndFilterOptions.brushStrength = 0.2f;
    //    // 照片输出压缩率 0-100 如果设置为0 将保存为PNG格式
    //    _photoEditMultipleComponent.options.editWipeAndFilterOptions.outputCompress = 0.95f;
    //
    
    //_photoEditMultipleComponent.options.editApertureOptions.componentClazz = [CustomApertureViewController class];
    
    // 设置图片
    _photoEditMultipleComponent.inputImage = result.image;
    _photoEditMultipleComponent.inputTempFilePath = result.imagePath;
    _photoEditMultipleComponent.inputAsset = result.imageAsset;
    // 是否在组件执行完成后自动关闭组件 (默认:NO)
    _photoEditMultipleComponent.autoDismissWhenCompelted = YES;
    // 当上一个页面是NavigationController时,是否通过 pushViewController 方式打开编辑器视图 (默认：NO，默认以 presentViewController 方式打开）
    // SDK 内部组件采用了一致的界面设计，会通过 push 方式打开视图。如果用户开启了该选项，在调用时可能会遇到布局不兼容问题，请谨慎处理。
    _photoEditMultipleComponent.autoPushViewController = YES;
    [_photoEditMultipleComponent showComponent];
}

- (void)openPhotoBox:(CDVInvokedUrlCommand*)command
{
    _albumComponent = [TuSDKGeeV1 albumMultipleCommponentWithController:self.viewController
                                                          callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller)
                       {
                           // 获取图片错误
                           if (error) {
                               lsqLError(@"album reader error: %@", error.userInfo);
                               return;
                           }
                           [self openEditMultipleWithController:controller result:result];
                       }];
    
    [_albumComponent showComponent];
}

@end
