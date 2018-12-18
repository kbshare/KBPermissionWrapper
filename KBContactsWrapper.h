//
//  KBContactsWrapper.h
//  ayh
//
//  Created by administrator on 2018/6/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KBSettingPermissionTool.h"
typedef NS_ENUM(NSInteger, selectType){
    
    SelectTypeEmail,
    SelectTypeContact,
    
};
typedef void (^contact)(id contact);

@interface KBContactsWrapper : NSObject 
@property (nonatomic, assign) selectType selectType;
@property (nonatomic, copy) contact  contact;

@property (nonatomic, copy) requestPermLoadContactBlock  requestPermLoadContactBlock;
@property (nonatomic, strong) UIColor *pickerTintColor; //通讯录控制器导航颜色


+ (KBContactsWrapper *)shareInstance;

+ (BOOL)isContactAuthorized;

+ (KBPermissionAuthorizationStatus)contactPermissionAuthorizationStatus;


/**
 获取所有联系人 (需要通讯录权限)
 */
- (NSArray *)loadContacts;

/**
 获取联系人
 不会请求通讯录权限
 @param contact 联系人
 */
- (void)loadContact:(contact)contact;

/**
 获取联系人
 首次获取会请求通讯录权限

 @param reqPermLoadContactBlock contact 联系人 error
 */
- (void)loadContactAndPermission:(requestPermLoadContactBlock )reqPermLoadContactBlock;

/**
 获取通讯录权限

 @param resultBlock 回调 结果
 */
- (void)requestContactPermission:(requestPermResult)resultBlock;

/**
 ->设置->通讯录权限弹窗 (也可用KBPrivate 自定义弹窗)
 */
- (void)settingContactPermission;

@end
