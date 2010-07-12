//
//  DeviceGroupModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DeviceModel.h"

@interface DeviceGroupModel : NSManagedObject {

}
@property (nonatomic, retain) NSSet* devices;

@end



// coalesce these into one @interface DeviceGroupModel (CoreDataGeneratedAccessors) section
@interface DeviceGroupModel (CoreDataGeneratedAccessors)
- (void)addDevicesObject:(DeviceModel *)value;
- (void)removeDevicesObject:(DeviceModel *)value;
- (void)addDevices:(NSSet *)value;
- (void)removeDevices:(NSSet *)value;

@end





