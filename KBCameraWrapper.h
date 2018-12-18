//
//  KBCameraWrapper.h
//  KBPermission
//
//  Created by administrator on 2018/12/14.
//

#import <Foundation/Foundation.h>
#import "KBSettingPermissionTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KBCameraWrapper : NSObject

+ (KBCameraWrapper *)shareInstance;

+ (BOOL)isCameraAuthorized;

+ (KBPermissionAuthorizationStatus)cameraPermissionAuthorizationStatus;

- (void)requestCameraPermission:(requestPermResult)requestPermResult;

- (void)requestCameraPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock;


//相机是否可用(硬件)
- (BOOL)isCameraAvailable;

- (BOOL)isFrontCameraAvailable;

- (BOOL)isRearCameraAvailable;


+ (BOOL)isPhotosAuthorized;

+ (KBPermissionAuthorizationStatus)photosPermissionAuthorizationStatus;

- (void)requestPhotosPermission:(requestPermResult)requestPermResult;

- (void)requestPhotosPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock;


@end

NS_ASSUME_NONNULL_END
