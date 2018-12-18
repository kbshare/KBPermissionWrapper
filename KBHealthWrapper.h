//
//  KBHealthWrapper.h
//  KBPermission
//
//  Created by administrator on 2018/12/14.
 
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "KBSettingPermissionTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KBHealthWrapper : NSObject
+ (KBHealthWrapper *)shareInstance;

+ (BOOL)isHealthAuthorized:(HKObjectType *)HKObjectType;

+ (KBPermissionAuthorizationStatus)healthPermissionAuthorizationStatus:(HKObjectType *)HKObjectType;


- (void)requestHealthPermissionToShareTypes:(nullable NSSet<HKSampleType *> *)typesToShare
                                  readTypes:(nullable NSSet<HKObjectType *> *)typesToRead
                     requestPermMultiResult:(requestPermMultiResult)requestPermMultiResult;
@end

NS_ASSUME_NONNULL_END
