//
//  KBSettingPermissionTool.m
//  ayh
//
//  Created by administrator on 2018/11/9.
//

#import "KBSettingPermissionTool.h"
#import "KBPrivate.h"
@implementation KBSettingPermissionTool

+ (KBSettingPermissionTool *)shareInstance{
    static KBSettingPermissionTool *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KBSettingPermissionTool alloc] init];
    });
    return shareInstance;
}

+ (void)settingPermissonType:(KBPermissionType)permissionType forced:(BOOL)isForce{
    NSString *permissionNeed = nil;
    BOOL isChinese = [KBPrivate isChinese];
    switch (permissionType) {
            
        case KBPermissionTypeLocation:
            permissionNeed = isChinese ? @"位置":@"Location";
            break;
        case KBPermissionTypeAddressBook:
            permissionNeed =isChinese ? @"通讯录":@"AddressBook";
            break;
        case KBPermissionTypeCalendar:
            permissionNeed = isChinese ? @"日历":@"Calendar";
            break;
        case KBPermissionTypePhoto:
            permissionNeed = isChinese ? @"照片":@"Photos";
            break;
        case KBPermissionTypeCamera:
            permissionNeed = isChinese ? @"相机":@"Camera";
            break;
        case KBPermissionTypeSport:
            permissionNeed = isChinese ? @"运动健身":@"Sport";
            break;
        case KBPermissionTypeSiri:
            permissionNeed = isChinese ? @"Siri与搜索":@"Siri & Search";
            break;
        case KBPermissionTypeNotification:
            permissionNeed = isChinese ? @"通知":@"Notification";
            break;
            
        default:
            break;
    }
    
    NSString *tip = [NSString stringWithFormat:@"您的%@没授权哦~\n去\"设置>隐私>%@\"开启一下吧",permissionNeed,permissionNeed];
    [self alterWithTitle:@"提示" message:tip cancel:isForce ? nil : @"暂不授权"  sure:@"确认"];
}



+ (void)alterWithTitle:(NSString *)title message:(NSString *)message sure:(NSString *)sure{
    
    [self alterWithTitle:title message:message cancel:nil sure:sure];
}


+ (void)alterWithTitle:(NSString *)title message:(NSString *)message cancel:( NSString * _Nullable )cancel sure:(NSString *)sure{
    
    [KBPrivate creatAlertView:title message:message cancel:cancel sure:sure handler:^(NSString *type) {
        
        if ([type isEqualToString:sure]){

            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];

            if([[UIApplication sharedApplication] canOpenURL:url]) {

                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];

                
                    [[UIApplication sharedApplication] openURL:url];
            }
        }
        
    } delegate:[UIViewController appVisibleViewController] otherButtonTitles:nil, nil];
    
}
@end
