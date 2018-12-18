//
//  KBContactsWrapper.m
//  ayh
//
//  Created by administrator on 2018/6/15.
//

#import "KBContactsWrapper.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "KBAddressBook.h"
#import "KBSettingPermissionTool.h"

#define kb_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface KBContactsWrapper ()<CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate>

@end

@implementation KBContactsWrapper

+ (KBContactsWrapper *)shareInstance{
    static KBContactsWrapper *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KBContactsWrapper alloc] init];
    });
    shareInstance.selectType = SelectTypeContact;
    return shareInstance;
}
- (void)setSelectType:(selectType)selectType{
    _selectType = selectType;
}

+ (BOOL)isContactAuthorized{

        return  [self contactPermissionAuthorizationStatus] == KBPermissionAuthorizationStatusAuthorized ? YES : NO;
}

+ (KBPermissionAuthorizationStatus)contactPermissionAuthorizationStatus{
    
    if (@available(iOS 9.0, *)) {
        
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status) {
            case CNAuthorizationStatusAuthorized:
                return KBPermissionAuthorizationStatusAuthorized;
            case CNAuthorizationStatusNotDetermined:
                return KBPermissionAuthorizationStatusNotDetermined;
            case CNAuthorizationStatusRestricted:
                return KBPermissionAuthorizationStatusRestricted;
            case CNAuthorizationStatusDenied:
                return KBPermissionAuthorizationStatusDenied;
        }
    }else{
        
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusAuthorized:
                return KBPermissionAuthorizationStatusAuthorized;
            case kABAuthorizationStatusNotDetermined:
                return KBPermissionAuthorizationStatusNotDetermined;
            case kABAuthorizationStatusRestricted:
                return KBPermissionAuthorizationStatusRestricted;
            case kABAuthorizationStatusDenied:
                return KBPermissionAuthorizationStatusDenied;
        }
    }
}

-(void)loadContact:(contact)contact{
    _contact = contact;
    [self launchContact];
}

- (void)launchContact{
    UIViewController *picker;
    if([CNContactPickerViewController class]) {
        picker = [[CNContactPickerViewController alloc] init];
        ((CNContactPickerViewController *)picker).delegate = self;
    } else {
        picker = [[ABPeoplePickerNavigationController alloc] init];
        [((ABPeoplePickerNavigationController *)picker) setPeoplePickerDelegate:self];
    }
    
    kb_dispatch_main_async_safe(^{
        UIViewController *root = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        BOOL modalPresent = (BOOL) (root.presentedViewController);
        if (modalPresent) {
            UIViewController *parent = root.presentedViewController;
            [UINavigationBar appearance].tintColor = self.pickerTintColor ?: [UIColor whiteColor];
            
            [parent presentViewController:picker animated:YES completion:nil];
            
        } else {
            [UINavigationBar appearance].tintColor = self.pickerTintColor ?: [UIColor whiteColor];
            [root presentViewController:picker animated:YES completion:nil];
        }
    })
}

- (void)loadContactAndPermission:(requestPermLoadContactBlock )reqPermLoadContactBlock{
    _requestPermLoadContactBlock = reqPermLoadContactBlock;
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *store = [[CNContactStore alloc] init];
            [store requestAccessForEntityType:CNEntityTypeContacts
                            completionHandler:^(BOOL granted, NSError* _Nullable error) {
                                if (error) {
                                }else {
                                    [self launchContact];
                                } }];
        } else if(status == CNAuthorizationStatusRestricted || status == CNAuthorizationStatusDenied) {
            
            NSError *error = [NSError errorWithDomain:@"请求用户通讯录权限" code:0 userInfo:@{@"permissonError":@"用户拒绝了通讯录授权 status =CNAuthorizationStatusDenied"}];
            if (reqPermLoadContactBlock) {
                reqPermLoadContactBlock(nil,error);
            }
        } else if (status == CNAuthorizationStatusAuthorized){
            [self launchContact];
        }
    }else{
        ABAddressBookRef bookref = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined){
            ABAddressBookRequestAccessWithCompletion(bookref, ^(bool granted, CFErrorRef error) {
                if (error) {
                } if (granted) {
                    [self launchContact];
                }
            });
            
        }else  if(status == kABAuthorizationStatusAuthorized){
            [self launchContact];
        }else {

            NSError *error = [NSError errorWithDomain:@"请求用户通讯录权限" code:0 userInfo:@{@"permissonError":@"用户拒绝了通讯录授权 status =CNAuthorizationStatusDenied"}];
            if (reqPermLoadContactBlock) {
                reqPermLoadContactBlock(nil,error);
            }
        }
    }
}


- (void)requestContactPermission:(requestPermResult)resultBlock{
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *store = [[CNContactStore alloc] init];
            [store requestAccessForEntityType:CNEntityTypeContacts
                            completionHandler:^(BOOL granted, NSError* _Nullable error) {
                                if (error) {
                                    resultBlock(NO);
                                }else {
                                    resultBlock(YES);
                                } }];
            
        } else if (status == CNAuthorizationStatusAuthorized){
            resultBlock(YES);
        }else{// CNAuthorizationStatusRestricted CNAuthorizationStatusDenied)
            resultBlock(NO);
        }
    }else{
        ABAddressBookRef bookref = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined){
            ABAddressBookRequestAccessWithCompletion(bookref, ^(bool granted, CFErrorRef error) {
                if (error) {
                    resultBlock(NO);
                    
                } if (granted) {
                    resultBlock(YES);
                }
            });
            
        }else  if(status == kABAuthorizationStatusAuthorized){
            resultBlock(YES);
        }else {
            resultBlock(NO);
        }
    }
}

#pragma mark - Event handlers - iOS 9+
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    switch(_selectType){
        case SelectTypeContact:
        {
            NSMutableDictionary *contactData = [self emptyContactDict];
            
            NSString *fullName = [self getFullNameForFirst:contact.givenName middle:contact.middleName last:contact.familyName ];
            NSArray *phoneNos = contact.phoneNumbers;
            NSArray *emailAddresses = contact.emailAddresses;
            
            [contactData setValue:fullName forKey:@"name"];
            
            //Return first phone number
            if([phoneNos count] > 0) {
                CNPhoneNumber *phone = ((CNLabeledValue *)phoneNos[0]).value;
                [contactData setValue:phone.stringValue forKey:@"phone"];
            }
            
            //Return first email address
            if([emailAddresses count] > 0) {
                [contactData setValue:((CNLabeledValue *)emailAddresses[0]).value forKey:@"email"];
            }
            
            [self contactPicked:contactData];
        }
            break;
        case SelectTypeEmail :
        {
            if([contact.emailAddresses count] < 1) {
                [self pickerNoEmail];
                return;
            }
            
            NSString *email = contact.emailAddresses[0].value;
            [self emailPicked:email];
        }
            break;
        default:
            break;
    }
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    [self pickerCancelled];
}
#pragma mark - Event handlers - iOS 8

/* Same functionality as above, implemented using iOS8 AddressBook library */
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    switch(_selectType) {
        case(SelectTypeContact):
        {
            
            /* Return NSDictionary ans JS Object to RN, containing basic contact data
             This is a starting point, in future more fields should be added, as required.
             This could also be extended to return arrays of phone numbers, email addresses etc. instead of jsut first found
             */
            NSMutableDictionary *contactData = [self emptyContactDict];
            NSString *fNameObject, *mNameObject, *lNameObject;
            fNameObject = (__bridge NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty);
            mNameObject = (__bridge NSString *) ABRecordCopyValue(person, kABPersonMiddleNameProperty);
            lNameObject = (__bridge NSString *) ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            NSString *fullName = [self getFullNameForFirst:fNameObject middle:mNameObject last:lNameObject];
            
            //Return full name
            [contactData setValue:fullName forKey:@"name"];
            
            //Return first phone number
            ABMultiValueRef phoneMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSArray *phoneNos = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneMultiValue);
            if([phoneNos count] > 0) {
                [contactData setValue:phoneNos[0] forKey:@"phone"];
            }
            
            //Return first email
            ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
            if([emailAddresses count] > 0) {
                [contactData setValue:emailAddresses[0] forKey:@"email"];
            }
            [self contactPicked:contactData];
        }
            break;
        case(SelectTypeEmail):
        {
            /* Return Only email address as string */
            ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
            if([emailAddresses count] < 1) {
                [self pickerNoEmail];
                return;
            }
            
            [self emailPicked:emailAddresses[0]];
        }
            break;
            
        default:
            return;
    }
    
}

- (void)pickerCancelled {
    
}

- (NSMutableDictionary *) emptyContactDict {
    return [[NSMutableDictionary alloc] initWithObjects:@[@"", @"", @""] forKeys:@[@"name", @"phone", @"email"]];
}

- (void)pickerNoEmail {
    if (_requestPermLoadContactBlock) {
        _requestPermLoadContactBlock(@"Email Error: NO Email...",nil);
    }
}

-(void)emailPicked:(NSString *)email {
    
    if (_requestPermLoadContactBlock) {
        _requestPermLoadContactBlock(email,nil);
    }
}


-(void)contactPicked:(NSDictionary *)contactData {
    if (_requestPermLoadContactBlock) {
        _requestPermLoadContactBlock(contactData,nil);
    }
}

- (void)settingContactPermission{
    
    [KBSettingPermissionTool settingPermissonType:KBPermissionTypeAddressBook forced:YES];
}

-(NSString *) getFullNameForFirst:(NSString *)fName middle:(NSString *)mName last:(NSString *)lName {
    //Check whether to include middle name or not
    NSArray *names = (mName.length > 0) ? [NSArray arrayWithObjects:lName, mName, fName, nil] : [NSArray arrayWithObjects:lName, fName, nil];;
    return [names componentsJoinedByString:@" "];
}



- (NSArray *)loadContacts {
    
    NSArray *addressBooks = [self readUserPhoneAddress];
    
    if (!addressBooks || addressBooks.count==0) {
        return nil;
    }
    
    NSMutableArray *contactsArray = [NSMutableArray array];
    for (int i=0; i<addressBooks.count; i++) {
        KBAddressBook *addressBook = [addressBooks objectAtIndex:i];
        [contactsArray addObject:[addressBook dict]];
    }
    
    NSLog(@"crawler contacts data :%@", contactsArray);
    return contactsArray;
    
}
- (NSArray<KBAddressBook *> *)readUserPhoneAddress {
    
    if (@available(iOS 9.0, *)) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactGivenNameKey,
                                                                                                   CNContactMiddleNameKey,
                                                                                                   CNContactFamilyNameKey ,
                                                                                                   CNContactPhoneNumbersKey,
                                                                                                   CNContactEmailAddressesKey]];
        NSMutableArray *_dataSource = [[NSMutableArray alloc]init];
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            KBAddressBook *addressBook = [[KBAddressBook alloc]init];
            addressBook.name = [NSString stringWithFormat:@"%@%@%@",contact.familyName,contact.middleName,contact.givenName];
            NSMutableArray *telArray = [NSMutableArray array];
            for (CNLabeledValue *phone in contact.phoneNumbers) {
                CNPhoneNumber * phoneNum = phone.value;
                [telArray addObject:phoneNum.stringValue];
            }
            addressBook.tel = [telArray componentsJoinedByString:@"&"];
            
            NSMutableArray *emailArray = [NSMutableArray array];
            for (CNLabeledValue *email in contact.emailAddresses) {
                
                [emailArray addObject:email.value];
            }
            addressBook.email = [[emailArray componentsJoinedByString:@"&"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            if (addressBook.tel.length < 200) {
                [_dataSource addObject:addressBook];
            }
        }];
        [NSThread sleepForTimeInterval:2];
        return _dataSource;
    } else {
        CFErrorRef error;
        //    //新建一个通讯录类
        ABAddressBookRef _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        NSMutableArray *_dataSource = [[NSMutableArray alloc]init];
        if (_addressBook) {
            //获取通讯录中的所有人
            NSArray *_arrayRef = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(_addressBook);
            //循环, 获取每个人的个人信息
            for ( id obj in _arrayRef) {
                //新建一个addressBook model类
                KBAddressBook *addressBook = [[KBAddressBook  alloc]init];
                //获取个人
                ABRecordRef person = (__bridge ABRecordRef)obj;
                //获取个人名字
                CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
                CFStringRef abFullName = ABRecordCopyCompositeName(person);
                NSString *nameString = (__bridge NSString *)abName;
                NSString *lastNameString = (__bridge NSString *)abLastName;
                if ((__bridge id) abFullName != nil) {
                    nameString = (__bridge NSString *)abFullName;
                } else {
                    if ((__bridge id)abLastName != nil) {
                        nameString = [NSString stringWithFormat:@"%@ %@", nameString,lastNameString];
                    }
                }
                addressBook.name = nameString;
                addressBook.recordID = (int)ABRecordGetRecordID(person);
                ABPropertyID multiProPerties[] = {
                    kABPersonPhoneProperty,
                    kABPersonEmailProperty
                };
                NSInteger multiPropertiesTotal = sizeof(multiProPerties) / sizeof(ABPropertyID);
                for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
                    ABPropertyID property = multiProPerties[j];
                    ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
                    NSInteger valuesCount = 0;
                    if (valuesRef != nil) {
                        valuesCount = ABMultiValueGetCount(valuesRef);
                    }
                    if (valuesCount == 0) {
                        continue;
                    }
                    for (NSInteger k = 0; k<valuesCount; k++) {
                        CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                        switch (j) {
                            case 0:
                                addressBook.tel = [NSString stringWithFormat:@"%@&%@",addressBook.tel.length?addressBook.tel:@"",(__bridge NSString *)value];
                                break;
                            case 1:
                                addressBook.email = [NSString stringWithFormat:@"%@&%@",addressBook.email.length?addressBook.email:@"",(__bridge NSString *)value];;
                                break;
                            default:
                                break;
                        }
                    }
                }
                addressBook.email = addressBook.email.length>1?[addressBook.email substringFromIndex:1]:@"";
                addressBook.tel = addressBook.tel.length>1?[addressBook.tel substringFromIndex:1]:@"";
                
                if (addressBook.tel.length < 200) {
                    [_dataSource addObject:addressBook];
                }
            }
            return _dataSource;
        } else {
            return nil;
        }
    }
}
@end
