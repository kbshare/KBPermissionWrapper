//
//  KBPrivate.h
//  KBPermission
//
//  Created by administrator on 2018/12/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface KBPrivate : NSObject

+ (BOOL)isChinese;

+(void)creatActionSheetTitle:(NSString *)title handler:(void (^)(NSString * type))selectorAction delegate:(id)object  cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles,...NS_REQUIRES_NIL_TERMINATION;

/** 兼容iOS7与iOS8以上系统
 */
+(void)creatAlertView:(NSString *)title message:(NSString *)message cancel:(NSString *)cancelTitle sure:(NSString *)sureTitle handler:(void(^)(NSString * type))selectorAction delegate:(id)object otherButtonTitles:(NSString *)otherButtonTitles,...NS_REQUIRES_NIL_TERMINATION;
@end

@interface UIViewController (Extra)

+ (UIViewController *)appVisibleViewController;
@end

NS_ASSUME_NONNULL_END
