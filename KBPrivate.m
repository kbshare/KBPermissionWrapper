//
//  KBPrivate.m
//  KBPermission
//
//  Created by administrator on 2018/12/13.
//

#import "KBPrivate.h"
#import "UIAlertView+Extral.h"

@implementation KBPrivate
+ (BOOL)isChinese{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    if([currentLang compare:@"zh-Hans" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
       [currentLang compare:@"zh-Hant" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
       [currentLang compare:@"zh-Hans-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
       [currentLang compare:@"zh-HK" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
       [currentLang compare:@"zh-Hant-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame){
        return YES;
    }else{
        return NO;
    }
}


+(void)creatActionSheetTitle:(NSString *)title handler:(void (^)(NSString * type))selectorAction delegate:(id)object  cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles,...NS_REQUIRES_NIL_TERMINATION
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([title isEqualToString:@""]){
            title = nil;
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        if (destructiveButtonTitle && ![destructiveButtonTitle isEqualToString:@""]){
            UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                selectorAction(destructiveButtonTitle);
                
            }];
            [alertController addAction:destructiveAction];
        }
        
        if (otherButtonTitles && ![otherButtonTitles isEqualToString:@""]){
            UIAlertAction *otherButtonAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                selectorAction(otherButtonTitles);
                
            }];
            [alertController addAction:otherButtonAction];
        }
        
        va_list varList;
        id arg;
        if(otherButtonTitles){
            va_start(varList,otherButtonTitles);
            while((arg = va_arg(varList,id))){
                //这里查找到可变参数中除了otherButtonTitles之外的所有参数
                if (arg && ![arg isEqualToString:@""]){
                    UIAlertAction *othersButtonAction = [UIAlertAction actionWithTitle:arg style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        selectorAction(arg);
                        
                    }];
                    [alertController addAction:othersButtonAction];
                }
            }
            va_end(varList);
        }
        if (cancelButtonTitle && ![cancelButtonTitle isEqualToString:@""]){
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                selectorAction(cancelButtonTitle);
                
            }];
            [alertController addAction:cancelAction];
        }
        
        [object presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}

+(void)creatAlertView:(NSString *)title message:(NSString *)message cancel:(NSString *)cancelTitle sure:(NSString *)sureTitle handler:(void(^)(NSString * type))selectorAction delegate:(id)object otherButtonTitles:(NSString *)otherButtonTitles,...NS_REQUIRES_NIL_TERMINATION
{
    if (object == nil || ![object isKindOfClass:[UIViewController class]]){
        return;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title==nil?@"":title message:message==nil?@"":message preferredStyle:UIAlertControllerStyleAlert];
        if (cancelTitle && ![cancelTitle isEqualToString:@""]){
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                selectorAction(cancelTitle);
            }];
            [alertController addAction:cancelAction];
        }
        if (sureTitle && ![sureTitle isEqualToString:@""]){
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                selectorAction(sureTitle);
                
            }];
            
            [alertController addAction:otherAction];
        }
        if (otherButtonTitles && ![otherButtonTitles isEqualToString:@""]){
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                selectorAction(otherButtonTitles);
                
            }];
            
            [alertController addAction:otherAction];
        }
        [object presentViewController:alertController animated:YES completion:nil];
        
    }
    else
    {
        //处理title
        NSMutableArray * titles = [NSMutableArray arrayWithCapacity:3];
            [titles addObject:cancelTitle];
            [titles addObject:sureTitle];
            [titles addObject:otherButtonTitles];
        
        va_list varList;
        id arg;
        if(otherButtonTitles){
            va_start(varList,otherButtonTitles);
            while((arg = va_arg(varList,id))){
                
                if (arg && ![arg isEqualToString:@""]){
                    [titles addObject: arg];
                }
            }
            va_end(varList);
        }
        
        
        __block UIAlertView * alerView = nil;
        alerView = [UIAlertView alertWithTitle:title message:message completion:^(NSUInteger actionIndex) {
            
            NSString * btnTitle = [alerView buttonTitleAtIndex:actionIndex];
            
            for(NSString * title in titles){
                if([btnTitle isEqualToString:title]){
                    selectorAction(title);
                    return;
                }
            }
            
        } actionTitles:titles cancelTitle:nil];
    }
}

@end

@implementation UIViewController (Extra)


+ (UIViewController *)appVisibleViewController {
    
    return [self getVisibleViewControllerFrom:UIApplication.sharedApplication.delegate.window.rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

@end
