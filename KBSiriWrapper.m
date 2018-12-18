//
//  KBSiriWrapper.m
//  KBPermission
//
//  Created by administrator on 2018/12/17.
 
//

#import "KBSiriWrapper.h"
#import <Intents/Intents.h>
@implementation KBSiriWrapper

+ (KBSiriWrapper *)shareInstance{
    static KBSiriWrapper *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KBSiriWrapper alloc] init];
    });
    return shareInstance;
}

+ (BOOL)isSiriAuthorized{
    
    return  [self siriPermissionAuthorizationStatus] == KBPermissionAuthorizationStatusAuthorized ? YES : NO;
}

+ (KBPermissionAuthorizationStatus)siriPermissionAuthorizationStatus{

    if (@available(iOS 10.0, *)) {
        
        INSiriAuthorizationStatus status = [INPreferences siriAuthorizationStatus];
        switch (status) {
            case INSiriAuthorizationStatusAuthorized:
                return KBPermissionAuthorizationStatusAuthorized;
            case INSiriAuthorizationStatusNotDetermined:
                return KBPermissionAuthorizationStatusNotDetermined;
            case INSiriAuthorizationStatusRestricted:
                return KBPermissionAuthorizationStatusRestricted;
            case INSiriAuthorizationStatusDenied:
                return KBPermissionAuthorizationStatusDenied;
        }
    }else{
        
        return KBPermissionAuthorizationStatusDenied;
    }
    
}

- (void)requestSiriPermission:(requestPermResult)requestPermResult{
    if (@available(iOS 10.0, *)) {
        [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
            if (status == INSiriAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    requestPermResult(YES);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    requestPermResult(NO);
                });
            }
        }];
    }
}

- (void)requestSiriPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock{
    
    if (@available(iOS 10.0, *)) {
        [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
            if (status == INSiriAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorizedBlock();
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    deniedBlock();
                });
            }
        }];
    }
    
}
@end
