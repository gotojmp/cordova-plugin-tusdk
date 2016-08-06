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
#import <TuSDK/TuSDKTSPHAssets+Extend.h>
#import <TUSDK/TuSDKTSALAssets+Extend.h>
#import "TextArea.h"

static int const MAX_THUMBNAIL_SIZE = 100;


#pragma mark - CustomizedEditTurnAndCutView

@interface CustomizedEditTurnAndCutView : TuSDKPFEditTurnAndCutView
/**
 *  向右旋转按钮
 */
@property (nonatomic, readonly) UIButton *trunRightButton;
@end

@implementation CustomizedEditTurnAndCutView
/**
 *  每个视图都会执行initView，自定义视图在这里开始
 */
-(void)initView;
{
    [super initView];
    
    // 修改底部工具栏背景
    self.bottomBar.backgroundColor = lsqRGB(255,123,44);
    // 隐藏镜像按钮
    self.bottomBar.filterButton.hidden = YES;
    self.bottomBar.mirrorButton.hidden = YES;
    CGRect frame1 = self.bottomBar.filterButton.frame;
    CGRect frame2 = self.bottomBar.trunButton.frame;
    CGRect frame3 = self.bottomBar.mirrorButton.frame;
    CGRect frame4 = self.bottomBar.completeButton.frame;
    // 创建向右旋转按钮
    _trunRightButton = [UIButton buttonWithFrame:frame2
                             imageLSQBundleNamed:@"style_default_edit_button_trun_right"];
    // 绑定动作
    [_trunRightButton addTouchUpInsideTarget:self action:@selector(onImageTurnRightAction)];
    // 添加到视图
    [self.bottomBar addSubview:_trunRightButton];
    // 修改frame
    [self.bottomBar.trunButton setFrame:frame1];
    frame3.size.width = frame3.size.width + frame4.size.width;
    [self.bottomBar.completeButton setFrame:frame3];
    [self.bottomBar.completeButton setTitle:@"下一步" forState:UIControlStateNormal];
}

/**
 *  向右旋转图片
 */
- (void)onImageTurnRightAction;
{
    [self.editImageView changeImage:lsqImageChangeTurnRight];
}
@end



#pragma mark CDVTusdk

@interface CDVTusdk()<TuSDKPFEditTurnAndCutDelegate>
{
    // 自定义系统相册组件
    TuSDKCPAlbumMultipleComponent* _albumComponent;
    // 图片编辑组件
    //TuSDKCPPhotoEditComponent* _photoEditComponent;
    // 照片美化编辑组件
    TuSDKCPPhotoEditMultipleComponent* _photoEditMultipleComponent;
    // 头像设置组件
    TuSDKCPAvatarComponent* _avatarComponent;
    // TextArea插件的navController
    TextAreaNavController* _textAreaNavController;
}
@end

@implementation CDVTusdk

- (void)pluginInitialize
{
    [TuSDK setLogLevel:lsqLogLevelWARN];
    [TuSDK initSdkWithAppKey:[[self.commandDelegate settings] objectForKey:@"tusdkappkey_ios"]];
}

- (void)openPhotoBoxNative:(TextAreaNavController *)controller withAppKey:(NSString *)appKey
{
    _textAreaNavController = controller;
    [TuSDK setLogLevel:lsqLogLevelWARN];
    [TuSDK initSdkWithAppKey:appKey];
    _albumComponent = [TuSDKGeeV1 albumMultipleCommponentWithController:_textAreaNavController
                                                          callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller) {
                                                              if (error) {
                                                                  return;
                                                              }
                                                              [self openEditMultipleWithControllerNative:controller result:result];
                                                          }];
    [_albumComponent showComponent];
}

- (void)openPhotoBox:(CDVInvokedUrlCommand*)command
{
    self.currentCallbackId = command.callbackId;
    __weak __typeof(&*self)me = self;
    
    _albumComponent = [TuSDKGeeV1 albumMultipleCommponentWithController:self.viewController
                                                          callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller) {
                                                              if (error) {
                                                                  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                                                                  [me.commandDelegate sendPluginResult:pluginResult callbackId:me.currentCallbackId];
                                                                  return;
                                                              }
                                                              //打开裁切窗口
                                                              [self openCustomizedEditAndCutWithController:controller result:result];
                                                          }];
    
    [_albumComponent showComponent];
}


- (void)openAvatarBox:(CDVInvokedUrlCommand*)command
{
    self.currentCallbackId = command.callbackId;
    __weak __typeof(&*self)me = self;
    
    _albumComponent = [TuSDKGeeV1 albumMultipleCommponentWithController:self.viewController
                                                          callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller) {
                                                              if (error) {
                                                                  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
                                                                  [me.commandDelegate sendPluginResult:pluginResult callbackId:me.currentCallbackId];
                                                                  return;
                                                              }
                                                              [self openEditAndCutWithController:controller result:result];
                                                          }];
    
    [_albumComponent showComponent];
}

- (UIImage *)getUIImageThumb:(UIImage *)image
{
    if (image.size.width > MAX_THUMBNAIL_SIZE || image.size.height > MAX_THUMBNAIL_SIZE) {
        CGFloat width = 0;
        CGFloat height = 0;
        
        // calculate size
        if (image.size.width > image.size.height)
        {
            width = MAX_THUMBNAIL_SIZE;
            height = width * image.size.height / image.size.width;
        }
        else
        {
            height = MAX_THUMBNAIL_SIZE;
            width = height * image.size.width / image.size.height;
        }
        
        // scale it
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaled = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaled;
    }
    
    return image;
}

//TextArea专用美颜组件
- (void)openEditMultipleWithControllerNative:(UIViewController *)controller
                                result:(TuSDKResult *)result;
{
    if (!controller || !result) return;
    
    _photoEditMultipleComponent =
    [TuSDKGeeV1 photoEditMultipleWithController:controller
                                  callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller)
     {
         _albumComponent = nil;
         // 获取图片失败
         if (error) {
             [_textAreaNavController insertImage:@""];
         } else {
             [_textAreaNavController insertImage:result.imagePath];
         }
     }];
    
    //_photoEditMultipleComponent.options.editCuterOptions.ratioType = lsqRatio_1_1;
    _photoEditMultipleComponent.options.editCuterOptions.ratioTypeList = @[@(lsqRatio_1_1)];
    
    _photoEditMultipleComponent.options.editMultipleOptions.saveToAlbum = NO;
    _photoEditMultipleComponent.options.editMultipleOptions.saveToTemp = YES;
    //_photoEditMultipleComponent.options.editMultipleOptions.saveToAlbumName = @"";
    _photoEditMultipleComponent.options.editFilterOptions.filterGroup = @[@"Brilliant", @"Harmony", @"Gloss"];
    // 设置图片
    _photoEditMultipleComponent.inputImage = result.image;
    _photoEditMultipleComponent.inputTempFilePath = result.imagePath;
    _photoEditMultipleComponent.inputAsset = result.imageAsset;
    // 是否在组件执行完成后自动关闭组件 (默认:NO)
    _photoEditMultipleComponent.autoDismissWhenCompelted = YES;
    _photoEditMultipleComponent.autoPushViewController = YES;
    [_photoEditMultipleComponent showComponent];
}

//美颜组件
- (void)openEditMultipleWithController:(UIViewController *)controller
                                result:(TuSDKResult *)result;
{
    if (!controller || !result) return;
    
    __weak __typeof(&*self)me = self;

    _photoEditMultipleComponent =
    [TuSDKGeeV1 photoEditMultipleWithController:controller
                                  callbackBlock:^(TuSDKResult *result, NSError *error, UIViewController *controller)
     {
         _albumComponent = nil;
         // 获取图片失败
         if (error) {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
             [me.commandDelegate sendPluginResult:pluginResult callbackId:me.currentCallbackId];
             return;
         }
         UIImage* thumbImage = [self getUIImageThumb:[result loadResultImage]];
         NSString* thumb = [UIImageJPEGRepresentation(thumbImage, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
         
         //NSLog(@"%@", result.imageAsset.localIdentifier);
         //NSArray *idArr = [result.imageAsset.localIdentifier componentsSeparatedByString:@"/"];
         NSDictionary* msg = @{
                               @"platform": @"ios",
                               //@"image": [idArr objectAtIndex:0],
                               @"image": result.imagePath,
                               @"thumb": thumb,
                               };
         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:msg];
         [me.commandDelegate sendPluginResult:pluginResult callbackId:me.currentCallbackId];
     }];
    
    //_photoEditMultipleComponent.options.editCuterOptions.ratioType = lsqRatio_1_1;
    _photoEditMultipleComponent.options.editCuterOptions.ratioTypeList = @[@(lsqRatio_1_1)];
    
    _photoEditMultipleComponent.options.editMultipleOptions.saveToAlbum = NO;
    _photoEditMultipleComponent.options.editMultipleOptions.saveToTemp = YES;
    //_photoEditMultipleComponent.options.editMultipleOptions.saveToAlbumName = @"";
    _photoEditMultipleComponent.options.editFilterOptions.filterGroup = @[@"Brilliant", @"Harmony", @"Gloss"];
    // 设置图片
    _photoEditMultipleComponent.inputImage = result.image;
    _photoEditMultipleComponent.inputTempFilePath = result.imagePath;
    _photoEditMultipleComponent.inputAsset = result.imageAsset;
    // 是否在组件执行完成后自动关闭组件 (默认:NO)
    _photoEditMultipleComponent.autoDismissWhenCompelted = YES;
    _photoEditMultipleComponent.autoPushViewController = YES;
    [_photoEditMultipleComponent showComponent];
}

//美颜组件前置的裁切组件
- (void)openCustomizedEditAndCutWithController:(UIViewController *)controller
                              result:(TuSDKResult *)result;
{
    if (!controller || !result) return;
    
    // 组件选项配置
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditTurnAndCutOptions.html
    TuSDKPFEditTurnAndCutOptions *opt = [TuSDKPFEditTurnAndCutOptions build];
    
    opt.viewClazz = [CustomizedEditTurnAndCutView class];
    
    // 需要裁剪的长宽
    opt.cutSize = CGSizeMake(960, 960);
    
    // 是否显示处理结果预览图 (默认：关闭，调试时可以开启)
    opt.showResultPreview = NO;
    
    // 保存到系统相册 (默认不保存, 当设置为YES时, TuSDKResult.asset)
    opt.saveToAlbum = NO;
    
    opt.saveToTemp = YES;
    
    // 保存到系统相册的相册名称
    //opt.saveToAlbumName = @"";
    
    TuSDKPFEditTurnAndCutViewController *tcController = opt.viewController;
    // 添加委托
    tcController.delegate = self;
    
    // 处理图片对象 (处理优先级: inputImage > inputTempFilePath > inputAsset)
    tcController.inputImage = result.image;
    tcController.inputTempFilePath = result.imagePath;
    tcController.inputAsset = result.imageAsset;
    
    [controller.navigationController pushViewController:tcController animated:YES];
    self.cutReturnType = 1;
}

//普通裁切组件、头像类组件
- (void)openEditAndCutWithController:(UIViewController *)controller
                              result:(TuSDKResult *)result;
{
    if (!controller || !result) return;
    
    // 组件选项配置
    // @see-http://tusdk.com/docs/ios/api/Classes/TuSDKPFEditTurnAndCutOptions.html
    TuSDKPFEditTurnAndCutOptions *opt = [TuSDKPFEditTurnAndCutOptions build];
    
    // 需要裁剪的长宽
    opt.cutSize = CGSizeMake(640, 640);
    
    // 是否显示处理结果预览图 (默认：关闭，调试时可以开启)
    opt.showResultPreview = NO;
    
    // 保存到系统相册 (默认不保存, 当设置为YES时, TuSDKResult.asset)
    opt.saveToAlbum = NO;
    
    opt.saveToTemp = YES;
    
    // 保存到系统相册的相册名称
    //opt.saveToAlbumName = @"";
    
    TuSDKPFEditTurnAndCutViewController *tcController = opt.viewController;
    // 添加委托
    tcController.delegate = self;
    
    // 处理图片对象 (处理优先级: inputImage > inputTempFilePath > inputAsset)
    tcController.inputImage = result.image;
    tcController.inputTempFilePath = result.imagePath;
    tcController.inputAsset = result.imageAsset;
    
    [controller.navigationController pushViewController:tcController animated:YES];
    self.cutReturnType = 0;
}

/**
 *  图片编辑完成
 *
 *  @param controller 旋转和裁剪视图控制器
 *  @param result 旋转和裁剪视图控制器处理结果
 */
- (void)onTuSDKPFEditTurnAndCut:(TuSDKPFEditTurnAndCutViewController *)controller result:(TuSDKResult *)result;
{
    if (self.cutReturnType == 1) {
        [self openEditMultipleWithController:controller result:result];
    } else {
        _albumComponent = nil;
        //NSLog(@"%@", result.imagePath);
        UIImage* thumbImage = [self getUIImageThumb:[result loadResultImage]];
        NSString* thumb = [UIImageJPEGRepresentation(thumbImage, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSDictionary* msg = @{
                              @"platform": @"ios",
                              @"image": result.imagePath,
                              @"thumb": thumb,
                              };
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:msg];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
        // 清除所有控件
        [controller dismissModalViewControllerAnimated];
    }
}

/**
 *  获取组件返回错误信息
 *
 *  @param controller 控制器
 *  @param result     返回结果
 *  @param error      异常信息
 */
- (void)onComponent:(TuSDKCPViewController *)controller result:(TuSDKResult *)result error:(NSError *)error;
{
    lsqLDebug(@"onComponent: controller - %@, result - %@, error - %@", controller, result, error);
}

@end
