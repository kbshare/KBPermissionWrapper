//
//  KBSiriWrapper.h
//  KBPermission
//
//  Created by administrator on 2018/12/17.
 
//

#import <Foundation/Foundation.h>
#import "KBSettingPermissionTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KBSiriWrapper : NSObject

+ (KBSiriWrapper *)shareInstance;

+ (BOOL)isSiriAuthorized;

+ (KBPermissionAuthorizationStatus)siriPermissionAuthorizationStatus;

- (void)requestSiriPermission:(requestPermResult)requestPermResult;

- (void)requestSiriPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock;
@end

NS_ASSUME_NONNULL_END
