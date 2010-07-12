//
//  DeviceModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DevicePropertyModel;

@interface DeviceModel : NSManagedObject {
	DevicePropertyModel * _dimmerStore;
}
@property (nonatomic, retain) NSSet* properties;
@property (nonatomic, retain) NSNumber * deviceNumber;
@property (readonly, retain) DevicePropertyModel * dimmer;
@property (nonatomic, retain) NSSet* addresses;

@property (retain) NSArray * addressesToken;

-(DevicePropertyModel*) getProperty:(NSString*)name;

@end



// coalesce these into one @interface DeviceModel (CoreDataGeneratedAccessors) section
@interface DeviceModel (CoreDataGeneratedAccessors)
- (void)addPropertiesObject:(NSManagedObject *)value;
- (void)removePropertiesObject:(NSManagedObject *)value;
- (void)addProperties:(NSSet *)value;
- (void)removeProperties:(NSSet *)value;

- (void)addAddressesObject:(NSManagedObject *)value;
- (void)removeAddressesObject:(NSManagedObject *)value;
- (void)addAddresses:(NSSet *)value;
- (void)removeAddresses:(NSSet *)value;
@end


