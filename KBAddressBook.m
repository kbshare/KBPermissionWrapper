//
//  ayh
//
//  Created by administrator on 2018/6/15.
//

#import "KBAddressBook.h"

@implementation KBAddressBook

- (NSDictionary *)dict {
    return @{
             @"name":self.name?:@"",
             @"email":self.email?:@"",
             @"number":self.tel?:@"",
             @"recordId":[NSNumber numberWithInteger:self.recordID]?:[NSNumber numberWithInt:0],
             @"sectionNumber":[NSNumber numberWithInteger:self.sectionNumber]?:[NSNumber numberWithInt:0]};
}

- (BOOL)isEqual:(KBAddressBook *)object {
    return [self.name isEqualToString:object.name];
}

@end
