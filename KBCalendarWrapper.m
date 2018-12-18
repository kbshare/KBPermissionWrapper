//
//  KBCalendarWrapper.m
//  KBPermission
//
//  Created by administrator on 2018/12/14.
//

#import "KBCalendarWrapper.h"
@import EventKit;

@implementation KBCalendarWrapper

+ (KBCalendarWrapper *)shareInstance{
    static KBCalendarWrapper *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KBCalendarWrapper alloc] init];
    });
    return shareInstance;
}

+ (BOOL)isCalendarAuthorized{
    
    return  [self calendaPermissionAuthorizationStatus] == KBPermissionAuthorizationStatusAuthorized ? YES : NO;
}

+ (KBPermissionAuthorizationStatus)calendaPermissionAuthorizationStatus{
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
        case EKAuthorizationStatusAuthorized:
            return KBPermissionAuthorizationStatusAuthorized;
        case EKAuthorizationStatusNotDetermined:
            return KBPermissionAuthorizationStatusNotDetermined;
        case EKAuthorizationStatusRestricted:
            return KBPermissionAuthorizationStatusRestricted;
        case EKAuthorizationStatusDenied:
            return KBPermissionAuthorizationStatusDenied;
    }
}

- (void)requestCalendarPermission:(requestPermMultiResult)requestPermMultiResult{
    
    EKEventStore *store = [[EKEventStore alloc]init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            requestPermMultiResult(granted,error);
        });
    }];
}

- (void)requestCalendarPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock{
    
    EKEventStore *store = [[EKEventStore alloc]init];
    
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted && authorizedBlock) {
                authorizedBlock();
            }else{
                deniedBlock();
            }
        });
    }];
}


-(NSInteger)getCurrentMonthForDays{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    NSUInteger numberOfDaysInMonth = range.length;
    return numberOfDaysInMonth;
}




@end
