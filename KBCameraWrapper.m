//
//  KBCameraWrapper.m
//  KBPermission
//
//  Created by administrator on 2018/12/14.
 
//

#import "KBCameraWrapper.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
@implementation KBCameraWrapper

+ (KBCameraWrapper *)shareInstance{
    static KBCameraWrapper *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KBCameraWrapper alloc] init];
    });
    return shareInstance;
}

+ (BOOL)isCameraAuthorized{
    
    return  [self cameraPermissionAuthorizationStatus] == KBPermissionAuthorizationStatusAuthorized ? YES : NO;
}

+ (KBPermissionAuthorizationStatus)cameraPermissionAuthorizationStatus{
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return KBPermissionAuthorizationStatusAuthorized;
        case AVAuthorizationStatusNotDetermined:
            return KBPermissionAuthorizationStatusNotDetermined;
        case AVAuthorizationStatusRestricted:
            return KBPermissionAuthorizationStatusRestricted;
        case AVAuthorizationStatusDenied:
            return KBPermissionAuthorizationStatusDenied;
    }
}
- (void)requestCameraPermission:(requestPermResult)requestPermResult{
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            requestPermResult(granted);
        });
    }];
}

- (void)requestCameraPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock{

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted && authorizedBlock) {
                authorizedBlock();
            }else{
                deniedBlock();
            }
        });
    }];
}

//相机是否可用(硬件)
- (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL)isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}




+ (BOOL)isPhotosAuthorized{
    
    return  [self photosPermissionAuthorizationStatus] == KBPermissionAuthorizationStatusAuthorized ? YES : NO;
}

+ (KBPermissionAuthorizationStatus)photosPermissionAuthorizationStatus{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            return KBPermissionAuthorizationStatusAuthorized;
        case PHAuthorizationStatusNotDetermined:
            return KBPermissionAuthorizationStatusNotDetermined;
        case PHAuthorizationStatusRestricted:
            return KBPermissionAuthorizationStatusRestricted;
        case PHAuthorizationStatusDenied:
            return KBPermissionAuthorizationStatusDenied;
    }
    return PHAuthorizationStatusAuthorized;
}

- (void)requestPhotosPermission:(requestPermResult)requestPermResult{
    
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            requestPermResult(granted);
        });
    }];
}

- (void)requestPhotosPermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock{
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted && authorizedBlock) {
                authorizedBlock();
            }else{
                deniedBlock();
            }
        });
    }];
}


@end
