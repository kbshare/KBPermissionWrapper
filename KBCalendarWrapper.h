//
//  KBCalendarWrapper.h
//  KBPermission
//
//  Created by administrator on 2018/12/14.
//

#import <Foundation/Foundation.h>
#import "KBSettingPermissionTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KBCalendarWrapper : NSObject

+ (KBCalendarWrapper *)shareInstance;

+ (BOOL)isCalendarAuthorized;

+ (KBPermissionAuthorizationStatus)calendaPermissionAuthorizationStatus;

- (void)requestCalendarPermission:(requestPermMultiResult)permResult;

- (void)requestCalendarPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock;


-(NSInteger)getCurrentMonthForDays;

@end

NS_ASSUME_NONNULL_END
