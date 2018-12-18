//
//  KBMicrophoneWrapper.m
//  KBPermission
//
//  Created by administrator on 2018/12/14.
 
//

#import "KBMicrophoneWrapper.h"
#import <AVFoundation/AVFoundation.h>

@implementation KBMicrophoneWrapper

+ (KBMicrophoneWrapper *)shareInstance{
    static KBMicrophoneWrapper *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KBMicrophoneWrapper alloc] init];
    });
    return shareInstance;
}

+ (BOOL)isMicrophoneAuthorized{
    
    return  [self microphonePermissionAuthorizationStatus] == KBPermissionAuthorizationStatusAuthorized ? YES : NO;
}

+ (KBPermissionAuthorizationStatus)microphonePermissionAuthorizationStatus{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];//麦克风权限
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return KBPermissionAuthorizationStatusAuthorized;
        case AVAuthorizationStatusDenied:
            return KBPermissionAuthorizationStatusDenied;
        case AVAuthorizationStatusNotDetermined:
            return KBPermissionAuthorizationStatusNotDetermined;
        case AVAuthorizationStatusRestricted:
            return KBPermissionAuthorizationStatusRestricted;
    }
}

- (void)requestMicrophonePermission:(requestPermResult)permResult{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            permResult(granted);
        });
    }];
}
- (void)requestMicrophonePermission:(handleBlock)authorizedBlock deniedBlock:(handleBlock)deniedBlock{

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        
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
