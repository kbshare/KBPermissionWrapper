//
//  KBLocationWrapper.m
//  ayh
//
//  Created by administrator on 2018/11/9.
//

#import "KBLocationWrapper.h"
#import <CoreLocation/CoreLocation.h>

#define MAX_MONITORING_REGIONS 20

#define kDefaultTimeout 10.0
#define kDefaultUserDistanceFilter  kCLLocationAccuracyBestForNavigation
#define kDefaultUserDesiredAccuracy kCLLocationAccuracyBest
#define kDefaultRegionDistanceFilter  kCLLocationAccuracyBestForNavigation
#define kDefaultRegionDesiredAccuracy kCLLocationAccuracyBest
#define kDefaultRegionRadiusDistance  500

NSString * const KBLocationWrapperUserLocationDidChangeNotification = @"KBLocationWrapperUserLocationDidChangeNotification";
NSString * const KBLocationWrapperNotificationLocationUserInfoKey = @"newLocation";

@interface KBLocationWrapper () <CLLocationManagerDelegate>
{
    BOOL _isUpdatingUserLocation;
    BOOL _isOnlyOneRefresh;
    NSTimer *_queryingTimer;
}

@property (nonatomic, readonly) CLLocationManager *userLocationManager;
@property (nonatomic, readonly) CLLocationManager *regionLocationManager;

- (void)_init;
- (void)_addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy;
- (BOOL)region:(CLRegion *)region inRegion:(CLRegion *)otherRegion;
- (BOOL)isMonitoringThisCoordinate:(CLLocationCoordinate2D)coordinate;
- (BOOL)isMonitoringThisRegion:(CLRegion *)region;

@end

@interface KBLocationWrapper () // Blocks

// Location Blocks
@property (copy) KBLocationWrapperLocationUpdateBlock locationBlock;
@property (copy) KBLocationWrapperLocationUpdateFailBlock errorLocationBlock;

// Region Blocks
@property (copy) KBLocationWrapperRegionUpdateBlock regionBlock;
@property (copy) KBLocationWrapperRegionUpdateFailBlock errorRegionBlock;

// Used one-off for authorization requests
@property (nonatomic, strong) NSMutableArray *userAuthorizationRequests;
@property (nonatomic, strong) NSMutableArray *regionAuthorizationRequests;

// Used for continuous updates of authorization requests
@property (copy) KBLocationWrapperAuthorizationStatusChangeBlock userAuthorizationStatusChangeBlock;
@property (copy) KBLocationWrapperAuthorizationStatusChangeBlock regionAuthorizationStatusChangeBlock;

@end

@implementation KBLocationWrapper

@synthesize delegate = _delegate;

@synthesize location = _location;
@synthesize purpose = _purpose;

@synthesize userLocationManager = _userLocationManager;
@synthesize regionLocationManager = _regionLocationManager;

@synthesize defaultTimeout = _defaultTimeout;
@synthesize userDistanceFilter = _userDistanceFilter;
@synthesize userDesiredAccuracy = _userDesiredAccuracy;
@synthesize regionDistanceFilter = _regionDistanceFilter;
@synthesize regionDesiredAccuracy = _regionDesiredAccuracy;

@synthesize regions = _regions;

@synthesize locationBlock, errorRegionBlock, regionBlock, errorLocationBlock, userAuthorizationRequests, regionAuthorizationRequests, userAuthorizationStatusChangeBlock, regionAuthorizationStatusChangeBlock;

+ (KBLocationWrapper *)sharedManager {
    static KBLocationWrapper *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[KBLocationWrapper alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    NSLog(@"[%@] init:", NSStringFromClass([self class]));
    
    if (self = [super init]) {
        // Init
        [self _init];
    }
    
    return self;
}

+ (BOOL)isLocationAuthorized{
    
    CLAuthorizationStatus type = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled] && type != kCLAuthorizationStatusDenied){
        
        return YES;
    }
    return NO;
}
- (id)initWithUserDistanceFilter:(CLLocationDistance)userDistanceFilter userDesiredAccuracy:(CLLocationAccuracy)userDesiredAccuracy purpose:(NSString *)purpose delegate:(id<KBLocationWrapperDelegate>)delegate
{
    
    NSLog(@"[%@] init:", NSStringFromClass([self class]));
    
    if (self = [super init]) {
        // Init
        [self _init];
        _userLocationManager.distanceFilter = userDistanceFilter;
        _userLocationManager.desiredAccuracy = userDesiredAccuracy;
        _purpose = purpose;
        
        self.delegate = delegate;
    }
    
    return self;
}

- (void)_init
{
    NSLog(@"[%@] _init:", NSStringFromClass([self class]));
    
    _isUpdatingUserLocation = NO;
    _isOnlyOneRefresh = NO;
    
    _userLocationManager = [[CLLocationManager alloc] init];
    _userLocationManager.distanceFilter = kDefaultUserDistanceFilter;
    _userLocationManager.desiredAccuracy = kDefaultUserDesiredAccuracy;
    _userLocationManager.delegate = self;
    
    _regionLocationManager = [[CLLocationManager alloc] init];
    _regionLocationManager.distanceFilter = kDefaultRegionDistanceFilter;
    _regionLocationManager.desiredAccuracy = kDefaultRegionDesiredAccuracy;
    _regionLocationManager.delegate = self;
    
    _defaultTimeout = kDefaultTimeout;
    
    userAuthorizationRequests = [NSMutableArray array];
    regionAuthorizationRequests = [NSMutableArray array];
    
}

#pragma mark - Private

/**
 * @discussion check if region is correct
 */
- (void)_addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy
{
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    NSLog(@"[%@] _addRegionForMonitoring:desiredAccuracy: [regions count]: %d", NSStringFromClass([self class]), [regions count]);
    
    NSAssert([CLLocationManager regionMonitoringAvailable] || [CLLocationManager regionMonitoringEnabled], @"RegionMonitoring not available!");
    NSAssert([regions count] < MAX_MONITORING_REGIONS, @"Only support %d regions!", MAX_MONITORING_REGIONS);
    NSAssert(accuracy < self.regionLocationManager.maximumRegionMonitoringDistance, @"Accuracy is too long!");
    
    
    [self.regionLocationManager startMonitoringForRegion:region desiredAccuracy:accuracy];
    
}

/**
 * @discussion only check if region is inside otherRegion
 */
- (BOOL)region:(CLRegion *)region inRegion:(CLRegion *)otherRegion
{
    NSLog(@"[%@] region:containsRegion:", NSStringFromClass([self class]));
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:otherRegion.center.latitude longitude:otherRegion.center.longitude];
    
    if ([otherRegion containsCoordinate:region.center]) {
        if ([location distanceFromLocation:otherLocation] + region.radius <= otherRegion.radius ) {
            return YES;
        }
    }
    return NO;
}

/**
 * @discussion check if coordinate is in a region
 */
- (BOOL)isMonitoringThisCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"[%@] isMonitoringThisCoordinate:", NSStringFromClass([self class]));
    
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    
    for (CLRegion *reg in regions) {
        if ([reg containsCoordinate:coordinate]) {
            return YES;
        }
    }
    return NO;
}

/**
 * @discussion check if region is inside other region
 */
- (BOOL)isMonitoringThisRegion:(CLRegion *)region
{
    NSLog(@"[%@] isMonitoringThisRegion:", NSStringFromClass([self class]));
    
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    
    for (CLRegion *reg in regions) {
        if ([self region:region inRegion:reg]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Setters

- (void)setDefaultTimeout:(CGFloat)defaultTimeout
{
    NSLog(@"[%@] setDefaultTimeout:%f", NSStringFromClass([self class]), defaultTimeout);
    
    _defaultTimeout = defaultTimeout;
}

- (void)setUserDistanceFilter:(CLLocationDistance)userDistanceFilter
{
    NSLog(@"[%@] setUserDistanceFilter:%f", NSStringFromClass([self class]), userDistanceFilter);
    
    _userDistanceFilter = userDistanceFilter;
    [_userLocationManager setDistanceFilter:_userDistanceFilter];
}

- (void)setUserDesiredAccuracy:(CLLocationAccuracy)userDesiredAccuracy
{
    NSLog(@"[%@] setUserDesiredAccuracy:%f", NSStringFromClass([self class]), userDesiredAccuracy);
    
    _userDesiredAccuracy = userDesiredAccuracy;
    [_userLocationManager setDesiredAccuracy:_userDesiredAccuracy];
}

- (void)setRegionDistanceFilter:(CLLocationDistance)regionDistanceFilter
{
    NSLog(@"[%@] setRegionDistanceFilter:%f", NSStringFromClass([self class]), regionDistanceFilter);
    
    _regionDistanceFilter = regionDistanceFilter;
    [_regionLocationManager setDistanceFilter:_regionDistanceFilter];
}

- (void)setRegionDesiredAccuracy:(CLLocationAccuracy)regionDesiredAccuracy
{
    NSLog(@"[%@] setRegionDesiredAccuracy:%f", NSStringFromClass([self class]), regionDesiredAccuracy);
    
    _regionDesiredAccuracy = regionDesiredAccuracy;
    [_regionLocationManager setDesiredAccuracy:_regionDesiredAccuracy];
}

- (void)setDelegate:(id<KBLocationWrapperDelegate>)delegate
{
    NSLog(@"[%@] setDelegate:", NSStringFromClass([self class]));
    
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)setPurpose:(NSString *)purpose
{
    NSLog(@"[%@] setPurpose:%@", NSStringFromClass([self class]), purpose);
    
    if (![_purpose isEqualToString:purpose]) {
        self.userLocationManager.purpose = [purpose copy];
        self.regionLocationManager.purpose = [purpose copy];
        _purpose = [purpose copy];
    }
}

#pragma mark - Getters

- (CLLocation *)location
{
    //Get locally stored location so that the location system icon does not falsely appear when reading user location
    return _location;
}

- (NSSet *)regions
{
    return self.regionLocationManager.monitoredRegions;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"[%@] locationManager:didFailWithError:%@", NSStringFromClass([self class]), error);
    
    // Call location block
    if (self.errorLocationBlock != nil) {
        self.errorLocationBlock(manager, error);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
        [self.delegate locationManager:self didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSDate* eventDate            = newLocation.timestamp;
    NSTimeInterval howRecent    = [eventDate timeIntervalSinceNow];
    
    if(abs(howRecent) > 10.0) {
        NSLog(@"locationManager didUpdateToLocation with timestamp %@ which is to old to use", newLocation.timestamp);
        return;
    }
    
    // Store user location locally
    _location = newLocation;
    
    if (newLocation.horizontalAccuracy <= manager.desiredAccuracy || _isOnlyOneRefresh == NO) {
        //        NSLog(@"[%@] locationManager:didUpdateToLocation:fromLocation: %@", NSStringFromClass([self class]), newLocation);
        
        if (_isOnlyOneRefresh) {
            // Stop querying timer because accurate location was obtained
            [self stopQueryingTimer];
            [_userLocationManager stopUpdatingLocation];
            _isOnlyOneRefresh = NO;
        }
        
        // Call location block
        if (self.locationBlock != nil) {
            self.locationBlock(manager, newLocation, oldLocation);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KBLocationWrapperUserLocationDidChangeNotification
                                                            object:self
                                                          userInfo:(
                                                                    [NSDictionary dictionaryWithObject:newLocation
                                                                                                forKey:KBLocationWrapperNotificationLocationUserInfoKey])];
        
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
            [self.delegate locationManager:self didUpdateToLocation:newLocation fromLocation:oldLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //    NSLog(@"[%@] locationManager:didEnterRegion:%@ at %@", NSStringFromClass([self class]), region.identifier, [NSDate date]);
    
    if (self.regionBlock != nil) {
        self.regionBlock(manager, region, YES);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        [self.delegate locationManager:self didEnterRegion:region];
    }
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"[%@] locationManager:didExitRegion:%@ at %@", NSStringFromClass([self class]), region.identifier, [NSDate date]);
    
    if (self.regionBlock != nil) {
        self.regionBlock(manager, region, NO);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didExitRegion:)]) {
        [self.delegate locationManager:self didExitRegion:region];
    }
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"[%@] locationManager:monitoringDidFailForRegion:%@: %@", NSStringFromClass([self class]), region.identifier, error);
    
    if (self.errorRegionBlock != nil) {
        self.errorRegionBlock(manager, region, error);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)]) {
        [self.delegate locationManager:self monitoringDidFailForRegion:region withError:error];
    }
}

- (void) locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (manager == _regionLocationManager) {
        
        if ([_delegate respondsToSelector:@selector(locationManager:didChangeRegionAuthorizationStatus:)]) {
            [_delegate locationManager:self didChangeRegionAuthorizationStatus:status];
        }
        
        if (regionAuthorizationStatusChangeBlock != nil) {
            regionAuthorizationStatusChangeBlock(manager, status);
        }
        
        for (KBLocationWrapperAuthorizationStatusChangeBlock block in [regionAuthorizationRequests copy])
        {
            block(manager, status);
        }
        
        regionAuthorizationRequests = [NSMutableArray array];
        
    } else if (manager == _userLocationManager) {
        
        if ([_delegate respondsToSelector:@selector(locationManager:didChangeUserAuthorizationStatus:)]) {
            [_delegate locationManager:self didChangeUserAuthorizationStatus:status];
        }
        
        if (userAuthorizationStatusChangeBlock != nil) {
            userAuthorizationStatusChangeBlock(manager, status);
        }
        
        for (KBLocationWrapperAuthorizationStatusChangeBlock block in [userAuthorizationRequests copy])
        {
            block(manager, status);
        }
        
        userAuthorizationRequests = [NSMutableArray array];
        
    }
}

#pragma mark Method's

+ (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)regionMonitoringAvailable
{
    return [CLLocationManager regionMonitoringAvailable];
}

+ (BOOL)regionMonitoringEnabled
{
    return [CLLocationManager regionMonitoringEnabled];
}

+ (BOOL)significantLocationChangeMonitoringAvailable
{
    return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

- (void) requestUserLocationWhenInUse
{
    
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    
    if ([_userLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self checkBundleInfoFor:@"NSLocationWhenInUseUsageDescription"];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_userLocationManager requestWhenInUseAuthorization];
        } else {
            [self locationManager:_userLocationManager didChangeAuthorizationStatus:status];
        }
        
    } else {
        [self locationManager:_userLocationManager didChangeAuthorizationStatus:status];
    }
    
}

- (void) requestUserLocationAlways
{
    
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    
    if ([_userLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        
        [self checkBundleInfoFor:@"NSLocationAlwaysUsageDescription"];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_userLocationManager requestAlwaysAuthorization];
        } else {
            [self locationManager:_userLocationManager didChangeAuthorizationStatus:status];
        }
        
    } else {
        [self locationManager:_userLocationManager didChangeAuthorizationStatus:status];
    }
    
}

- (void) requestUserLocationWhenInUseWithBlock:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    self.userAuthorizationStatusChangeBlock = block;
    [self requestUserLocationWhenInUse];
}

- (void) requestUserLocationAlways:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    self.userAuthorizationStatusChangeBlock = block;
    [self requestUserLocationAlways];
}

- (void) requestUserLocationWhenInUseWithBlockOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    [userAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationWhenInUse];
}

- (void) requestUserLocationAlwaysOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    [userAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationAlways];
}

- (void) requestRegionLocationWhenInUse
{
    
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    
    if ([_regionLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self checkBundleInfoFor:@"NSLocationWhenInUseUsageDescription"];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_regionLocationManager requestWhenInUseAuthorization];
        } else {
            [self locationManager:_regionLocationManager didChangeAuthorizationStatus:status];
        }
        
    } else {
        [self locationManager:_regionLocationManager didChangeAuthorizationStatus:status];
    }
    
}

- (void) requestRegionLocationAlways
{
    
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    
    if ([_regionLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        
        [self checkBundleInfoFor:@"NSLocationAlwaysUsageDescription"];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_regionLocationManager requestAlwaysAuthorization];
        } else {
            [self locationManager:_regionLocationManager didChangeAuthorizationStatus:status];
        }
        
    } else {
        [self locationManager:_regionLocationManager didChangeAuthorizationStatus:status];
    }
    
}

- (void) requestRegionLocationWhenInUseWithBlock:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestRegionLocationWhenInUse];
}

- (void) requestRegionLocationAlwaysWithBlock:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestRegionLocationAlways];
}

- (void) requestRegionLocationWhenInUseWithBlockOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    [regionAuthorizationRequests addObject:[block copy]];
    [self requestRegionLocationWhenInUse];
}

- (void) requestRegionLocationAlwaysWithBlockOnce:(KBLocationWrapperAuthorizationStatusChangeBlock)block
{
    [regionAuthorizationRequests addObject:[block copy]];
    [self requestRegionLocationAlways];
}

-(void) checkBundleInfoFor:(NSString*)key {
    
    static NSString * const kMsg = @"Warning! Unable to find %@ in Info.plist.  \
    CLLocationManager requires that %@ be set in \
    the Info.plist in order to function correctly.  \
    Please consult the Apple Developer documentation titled \
    \"Information Property List Key Reference.\"";
    
    NSDictionary * const infoPlist = [[NSBundle mainBundle] infoDictionary];
    
    if (![infoPlist objectForKey:key]) {
        NSLog(kMsg, key, key);
    }
    
}

- (void)startUpdatingLocation
{
    NSLog(@"[%@] startUpdatingLocation:", NSStringFromClass([self class]));
    
    _isUpdatingUserLocation = YES;
    [self.userLocationManager startUpdatingLocation];
}

- (void)startUpdatingLocationWithBlock:(KBLocationWrapperLocationUpdateBlock)block errorBlock:(KBLocationWrapperLocationUpdateFailBlock)errorBlock {
    
    self.locationBlock = block;
    self.errorLocationBlock = errorBlock;
    
    [self startUpdatingLocation];
    
}

-(void)startQueryingTimer
{
    [self stopQueryingTimer];
    _queryingTimer = [NSTimer scheduledTimerWithTimeInterval:_defaultTimeout target:self selector:@selector(queryingTimerPassed) userInfo:nil repeats:YES];
}

-(void)stopQueryingTimer
{
    if (_queryingTimer)
    {
        if ([_queryingTimer isValid])
        {
            [_queryingTimer invalidate];
        }
        _queryingTimer = nil;
    }
}

-(void)queryingTimerPassed
{
    [self stopUpdatingLocation];
    [self stopQueryingTimer];
    
    if (self.locationBlock != nil) {
        self.locationBlock(self.userLocationManager, _location, nil);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
        [self.delegate locationManager:self didUpdateToLocation:_location fromLocation:nil];
    }
}

- (void)retrieveUserLocationWithBlock:(KBLocationWrapperLocationUpdateBlock)block errorBlock:(KBLocationWrapperLocationUpdateFailBlock)errorBlock {
    
    _isOnlyOneRefresh = YES;
    [self startQueryingTimer];
    [self startUpdatingLocationWithBlock:block errorBlock:errorBlock];
}

- (void)updateUserLocation
{
    NSLog(@"[%@] updateUserLocation:", NSStringFromClass([self class]));
    
    if (!_isOnlyOneRefresh) {
        _isOnlyOneRefresh = YES;
        [_userLocationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation
{
    NSLog(@"[%@] stopUpdatingLocation:", NSStringFromClass([self class]));
    
    _isUpdatingUserLocation = NO;
    [self.userLocationManager stopUpdatingLocation];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"[%@] addCoordinateForMonitoring:", NSStringFromClass([self class]));
    
    [self addCoordinateForMonitoring:coordinate withRadius:kDefaultRegionRadiusDistance desiredAccuracy:kDefaultRegionDesiredAccuracy];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius
{
    [self addCoordinateForMonitoring:coordinate withRadius:radius desiredAccuracy:kDefaultRegionDesiredAccuracy];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy
{
    NSLog(@"[%@] addCoordinateForMonitoring:withRadius:", NSStringFromClass([self class]));
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coordinate radius:radius identifier:[NSString stringWithFormat:@"Region with center (%f, %f) and radius (%f)", coordinate.latitude, coordinate.longitude, radius]];
    
    [self addRegionForMonitoring:region desiredAccuracy:accuracy];
}

- (void)addRegionForMonitoring:(CLRegion *)region
{
    NSLog(@"[%@] addRegionForMonitoring:", NSStringFromClass([self class]));
    
    [self addRegionForMonitoring:region desiredAccuracy:kDefaultRegionDesiredAccuracy];
}

- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy
{
    NSLog(@"[%@] addRegionForMonitoring:", NSStringFromClass([self class]));
    
    if (![self isMonitoringThisRegion:region]) {
        [self _addRegionForMonitoring:region desiredAccuracy:accuracy];
    }
}

- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(KBLocationWrapperRegionUpdateBlock)block errorBlock:(KBLocationWrapperRegionUpdateFailBlock)errorBlock {
    
    self.regionBlock = block;
    self.errorRegionBlock = errorBlock;
    
    [self addRegionForMonitoring:region desiredAccuracy:accuracy];
}

- (void)stopMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"[%@] stopMonitoringForRegion:", NSStringFromClass([self class]));
    
    [self.regionLocationManager stopMonitoringForRegion:region];
}

- (void)stopMonitoringAllRegions
{
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    NSLog(@"[%@] stopMonitoringAllRegion: [regions count]: %d", NSStringFromClass([self class]), [regions count]);
    
    for (CLRegion *reg in regions) {
        [self.regionLocationManager stopMonitoringForRegion:reg];
    }
}

@end
