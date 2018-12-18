//
//  KBMicrophoneWrapper.h
//  KBPermission
//
//  Created by administrator on 2018/12/14.
 
//

#import <Foundation/Foundation.h>
#import "KBSettingPermissionTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KBMicrophoneWrapper : NSObject

+ (KBMicrophoneWrapper *)shareInstance;

+ (BOOL)isMicrophoneAuthorized;

+ (KBPermissionAuthorizationStatus)microphonePermissionAuthorizationStatus;

- (void)requestMicrophonePermission:(requestPermResult)requestPermResult;

- (void)requestMicrophonePermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock;
@end

NS_ASSUME_NONNULL_END
