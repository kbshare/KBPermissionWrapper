//
//  ayh
//
//  Created by administrator on 2018/6/15.
//

#import <Foundation/Foundation.h>

@interface KBAddressBook : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic ,assign) NSInteger sectionNumber;
@property (nonatomic ,assign) NSInteger recordID;

- (NSDictionary *)dict;

@end
