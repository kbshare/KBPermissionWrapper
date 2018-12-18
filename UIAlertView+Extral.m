//  ayh
//
//  Created by administrator on 2018/6/15.
//

#import "UIAlertView+Extral.h"
#import <objc/runtime.h>

@implementation UIAlertView (Extral)

static void  *__alertViewAssociatedObjctKey = &__alertViewAssociatedObjctKey;

- (void)showWithButtonClickedCompletion:(void (^)(NSInteger buttonIndex))completion{
    if(!completion){
        return;
    }
    
    objc_setAssociatedObject(self, __alertViewAssociatedObjctKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.delegate = self;
    [self show];
}


#pragma mark - ---UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    void (^completion)(NSInteger buttonIndex) = objc_getAssociatedObject(self, __alertViewAssociatedObjctKey);
    if(completion){
        completion(buttonIndex);
    }
}

#pragma mark - --- Alert Fast Show Method

/**
 显示alert,button顺序:actionTitles(包含destructive) -> cancel
 
 @param title            标题
 @param message          信息
 @param completion       回调
 @param actionTitles     取消标题
 @param cancelTitle      其他标题
 @warning 推荐iOS 8以下使用
 **/
+ (UIAlertView *)alertWithTitle:( NSString *)title
               message:( NSString *)message
            completion:(void (^)(NSUInteger actionIndex))completion
          actionTitles:( NSArray<NSString *> *)actionTitles
           cancelTitle:( NSString *)cancelTitle{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    /// cancle title
    if(cancelTitle && cancelTitle.length){
        alertView.cancelButtonIndex = 0;
        [alertView addButtonWithTitle:cancelTitle];
    }
    
    /// action titles
    if(actionTitles && [actionTitles count]){
        for(NSUInteger idx = 0; idx < actionTitles.count; idx++){
            NSString *title = actionTitles[idx];
            if(title && [title isKindOfClass:[NSString class]] && [title length]){
                [alertView addButtonWithTitle:title];
            }
        }
    }
    
    /// completion
    if(completion){
        [alertView showWithButtonClickedCompletion:(id)completion];
    }else{
        [alertView show];
    }
    
    return alertView;
}


#pragma mark - --- Show Method (DEPRECATED)

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message clickedCompletion:(void (^)(NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles argList:(va_list)argList{
    /// 处理title
    NSMutableArray<NSString *> *actionTitles = [NSMutableArray array];
    NSString *actionTitle = nil;
    if(otherButtonTitles){
        [actionTitles addObject:otherButtonTitles];
    }
    while ((actionTitle = va_arg(argList, NSString *))) {
        if([actionTitle isKindOfClass:[NSString class]] && [actionTitle length]){
            [actionTitles addObject:actionTitle];
        }
    }
    
    if(8.0 <= [[[UIDevice currentDevice] systemVersion] floatValue]){
        
    }else{
        /// iOS 8以下使用UIAlertView
        [self alertWithTitle:title message:message completion:(id)completion actionTitles:actionTitles cancelTitle:cancelButtonTitle];
    }
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message clickedCompletion:(void (^)(NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
    va_list argList;
    va_start(argList, otherButtonTitles);
    
    [self alertWithTitle:title message:message clickedCompletion:completion cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles argList:argList];
    
    va_end(argList);
}

+ (void)alertWithTitle:(NSString *)title clickedCompletion:(void (^)(NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
    va_list argList;
    va_start(argList, otherButtonTitles);
    
    [self alertWithTitle:title message:nil clickedCompletion:completion cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles argList:argList];
    
    va_end(argList);
}

+ (void)alertWithMessage:(NSString *)message clickedCompletion:(void (^)(NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
    va_list argList;
    va_start(argList, otherButtonTitles);
    
    [self alertWithTitle:nil message:message clickedCompletion:completion cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles argList:argList];
    
    va_end(argList);
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message clickedCompletion:(void (^)(NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle{
    [self alertWithTitle:title message:message clickedCompletion:completion cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
}

+ (void)alertWithTitle:(NSString *)title clickedCompletion:(void (^)(NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle{
    [self alertWithTitle:title message:nil clickedCompletion:completion cancelButtonTitle:cancelButtonTitle];
}

+ (void)alertWithMessage:(NSString *)message clickedCompletion:(void (^)(NSInteger buttonIndex))completion cancelButtonTitle:(NSString *)cancelButtonTitle{
    [self alertWithTitle:nil message:message clickedCompletion:completion cancelButtonTitle:cancelButtonTitle];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle{
    [self alertWithTitle:title message:message clickedCompletion:nil cancelButtonTitle:cancelButtonTitle];
}

+ (void)alertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle{
    [self alertWithTitle:title message:nil clickedCompletion:nil cancelButtonTitle:cancelButtonTitle];
}

+ (void)alertWithMessage:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle{
    [self alertWithTitle:nil message:message clickedCompletion:nil cancelButtonTitle:cancelButtonTitle];
}

@end
