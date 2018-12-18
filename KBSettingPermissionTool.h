//
//  KBSettingPermissionTool.h
//  ayh
//
//  Created by administrator on 2018/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kb_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

typedef NS_ENUM(NSInteger,KBPermissionType){
    
    KBPermissionTypeLocation,
    KBPermissionTypeAddressBook,
    KBPermissionTypeCalendar,
    KBPermissionTypePhoto,
    KBPermissionTypeCamera,
    KBPermissionTypeSport,
    KBPermissionTypeSiri,
    KBPermissionTypeNotification
    
};

typedef NS_ENUM(NSInteger, KBPermissionAuthorizationStatus) {
    KBPermissionAuthorizationStatusNotDetermined,
    KBPermissionAuthorizationStatusDenied,
    KBPermissionAuthorizationStatusAuthorized,
    KBPermissionAuthorizationStatusRestricted
};

typedef void(^requestPermLoadContactBlock)(id contact, NSError * _Nullable error);
typedef void(^requestPermMultiResult)(BOOL isAuthorized, NSError * _Nullable error);
typedef void(^requestPermResult)(BOOL isAuthorized);
typedef void (^handleBlock)(void);

@interface KBSettingPermissionTool : NSObject

+ (KBSettingPermissionTool *)shareInstance;


/**
 提示设置权限弹窗

 @param permissionType 权限类型
 @param isForce 是否强制授权
 */
+ (void)settingPermissonType:(KBPermissionType)permissionType forced:(BOOL)isForce;


/**
 弹窗

 @param title 标题
 @param message 描述
 @param sure "确定"标题
 */
+ (void)alterWithTitle:(NSString *)title
               message:(NSString *)message
                  sure:(NSString *)sure;

/**
 弹窗

 @param title 标题
 @param message 描述
 @param cancel "取消"标题
 @param sure "确定"标题
 */
+ (void)alterWithTitle:(NSString *)title
                  message:(NSString *)message
                   cancel:( NSString * _Nullable )cancel
                     sure:(NSString *)sure;


@end

NS_ASSUME_NONNULL_END
