//
//  KBHealthWrapper.m
//  KBPermission
//
//  Created by administrator on 2018/12/14.
 
//

#import "KBHealthWrapper.h"

@implementation KBHealthWrapper

+ (KBHealthWrapper *)shareInstance{
    static KBHealthWrapper *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KBHealthWrapper alloc] init];
    });
    return shareInstance;
}

+ (BOOL)isHealthAuthorized:(HKObjectType *)HKObjectType{
    
    return  [self healthPermissionAuthorizationStatus:HKObjectType] == KBPermissionAuthorizationStatusAuthorized ? YES : NO;
}

+ (KBPermissionAuthorizationStatus)healthPermissionAuthorizationStatus:(HKObjectType *)HKObjectType{
    
    if (![HKHealthStore isHealthDataAvailable]) {
        
    }
    
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    
    HKAuthorizationStatus status = [healthStore authorizationStatusForType:HKObjectType];
    switch (status) {
        case HKAuthorizationStatusSharingAuthorized:
            return KBPermissionAuthorizationStatusAuthorized;
        case HKAuthorizationStatusNotDetermined:
            return KBPermissionAuthorizationStatusNotDetermined;
        case HKAuthorizationStatusSharingDenied:
            return KBPermissionAuthorizationStatusDenied;
    }
}
- (void)requestHealthPermissionToShareTypes:(nullable NSSet<HKSampleType *> *)typesToShare readTypes:(nullable NSSet<HKObjectType *> *)typesToRead requestPermMultiResult:(requestPermMultiResult)requestPermMultiResult{
    
    
    if (![HKHealthStore isHealthDataAvailable]) {
        return;
    }
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                               nil];
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];
    [healthStore requestAuthorizationToShareTypes:typesToShare?:shareObjectTypes
                                        readTypes:typesToRead?:readObjectTypes
                                       completion:^(BOOL success, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            requestPermMultiResult(success,error);
        });
    }];
}

@end
