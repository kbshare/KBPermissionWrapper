//
//  KBLocationWrapper.h
//  ayh
//
//  Created by administrator on 2018/11/9.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const KBLocationWrapperUserLocationDidChangeNotification;
extern NSString * const KBLocationWrapperNotificationLocationUserInfoKey;

typedef void(^KBLocationWrapperLocationUpdateBlock)(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation);
typedef void (^KBLocationWrapperLocationUpdateFailBlock)(CLLocationManager *manager, NSError *error);

typedef void(^KBLocationWrapperRegionUpdateBlock)(CLLocationManager *manager, CLRegion *region, BOOL enter);
typedef void(^KBLocationWrapperRegionUpdateFailBlock)(CLLocationManager *manager, CLRegion *region, NSError *error);

typedef void(^KBLocationWrapperAuthorizationStatusChangeBlock)(CLLocationManager *manager, CLAuthorizationStatus status);

@protocol KBLocationWrapperDelegate;

@interface KBLocationWrapper : NSObject

@property (nonatomic, assign) id<KBLocationWrapperDelegate> delegate;

/**
 * @discussion the most recently retrieved user location.
 */
@property (nonatomic, readonly) CLLocation *location;

/**
 * @discussion string that describes the reason for using location services.
 */
@property (nonatomic, copy) NSString *purpose;

#pragma mark - Customization

// Timeout for retrieving an accurate location using blocks, default is 10 seconds
@property (nonatomic, assign) CGFloat defaultTimeout;

@property (nonatomic, assign) CLLocationDistance userDistanceFilter;
@property (nonatomic, assign) CLLocationAccuracy userDesiredAccuracy;

@property (nonatomic, assign) CLLocationDistance regionDistanceFilter;
@property (nonatomic, assign) CLLocationAccuracy regionDesiredAccuracy;

@property (nonatomic, readonly) NSSet *regions;


+ (KBLocationWrapper *)sharedManager;

+ (BOOL)isLocationAuthorized;

- (id)initWithUserDistanceFilter:(CLLocationDistance)userDistanceFilter userDesiredAccuracy:(CLLocationAccuracy)userDesiredAccuracy purpose:(NSString *)purpose delegate:(id<KBLocationWrapperDelegate>)delegate;

+ (BOOL)locationServicesEnabled;
+ (BOOL)regionMonitoringAvailable;
+ (BOOL)regionMonitoringEnabled;
+ (BOOL)significantLocationChangeMonitoringAvailable;

// One of these call is required on iOS8+ to use location services.  However, on iOS7 and below this call is safe to
// make without encountering an exception.  In cases where the underlying API call is not necessary, such as when
// the user has already approved access, the blocks/delegate calls will be immediately dispatched.  For more information
// see the CLLocationManager documentation.

// Used for when you don't care when the app is authorized/deauthorized to use location services.  The delegate
// assigned to this manager will receive call backs as well as any blocks dedicated to continually listening
// for updates.
- (void) requestUserLocationWhenInUse;
- (void) requestUserLocationAlways;

// Used for when you want to receive continuous updates on the authorization status
- (void) requestUserLocationWhenInUseWithBlock:(KBLocationWrapperAuthorizationStatusChangeBlock)block;
- (void) requestUserLocationAlways:(KBLocationWrapperAuthorizationStatusChangeBlock)block;

// Used for when you want to ask once if the user has allowed location services.  Once the blocks
// are called, they are released and forgotten.
- (void) requestUserLocationWhenInUseWithBlockOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block;
- (void) requestUserLocationAlwaysOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block;

// Used for when you don't care when the app is authorized/deauthorized to use location services.  The delegate
// assigned to this manager will receive call backs as well as any blocks dedicated to continually listening
// for updates.
- (void) requestRegionLocationWhenInUse;
- (void) requestRegionLocationAlways;

// Used for when you want to receive continuous updates on the authorization status
- (void) requestRegionLocationWhenInUseWithBlock:(KBLocationWrapperAuthorizationStatusChangeBlock)block;
- (void) requestRegionLocationAlwaysWithBlock:(KBLocationWrapperAuthorizationStatusChangeBlock)block;

// Used for when you want to ask once if the user has allowed location services.  Once the blocks
// are called, they are released and forgotten.
- (void) requestRegionLocationWhenInUseWithBlockOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block;
- (void) requestRegionLocationAlwaysWithBlockOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block;

- (void)startUpdatingLocation;
- (void)startUpdatingLocationWithBlock:(KBLocationWrapperLocationUpdateBlock)block errorBlock:(KBLocationWrapperLocationUpdateFailBlock)errorBlock; // USING BLOCKS
- (void)retrieveUserLocationWithBlock:(KBLocationWrapperLocationUpdateBlock)block errorBlock:(KBLocationWrapperLocationUpdateFailBlock)errorBlock; // USING BLOCKS. Only 1 time.
- (void)updateUserLocation;
- (void)stopUpdatingLocation;

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate;
- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius;
- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy;

- (void)addRegionForMonitoring:(CLRegion *)region;
- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(KBLocationWrapperRegionUpdateBlock)block errorBlock:(KBLocationWrapperRegionUpdateFailBlock)errorBlock; // USING BLOCKS
- (void)stopMonitoringForRegion:(CLRegion *)region;
- (void)stopMonitoringAllRegions;

@end

@protocol KBLocationWrapperDelegate <NSObject>

@optional

- (void)locationManager:(KBLocationWrapper *)manager didChangeUserAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)locationManager:(KBLocationWrapper *)manager didChangeRegionAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)locationManager:(KBLocationWrapper *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(KBLocationWrapper *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(KBLocationWrapper *)manager didEnterRegion:(CLRegion *)region;
- (void)locationManager:(KBLocationWrapper *)manager didExitRegion:(CLRegion *)region;
- (void)locationManager:(KBLocationWrapper *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

@end


NS_ASSUME_NONNULL_END
