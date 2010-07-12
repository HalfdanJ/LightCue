//
//  DeviceGroupModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DeviceGroupModel.h"


@implementation DeviceGroupModel
@dynamic devices;

@end





#if 0
/*
 *
 * You do not need any of these.  
 * These are templates for writing custom functions that override the default CoreData functionality.
 * You should delete all the methods that you do not customize.
 * Optimized versions will be provided dynamically by the framework.
 *
 *
 */


// coalesce these into one @interface DeviceGroupModel (CoreDataGeneratedPrimitiveAccessors) section
@interface DeviceGroupModel (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveDevices;
- (void)setPrimitiveDevices:(NSMutableSet*)value;

@end


- (void)addDevicesObject:(DeviceModel *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"devices" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveDevices] addObject:value];
    [self didChangeValueForKey:@"devices" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeDevicesObject:(DeviceModel *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"devices" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveDevices] removeObject:value];
    [self didChangeValueForKey:@"devices" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addDevices:(NSSet *)value 
{    
    [self willChangeValueForKey:@"devices" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveDevices] unionSet:value];
    [self didChangeValueForKey:@"devices" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeDevices:(NSSet *)value 
{
    [self willChangeValueForKey:@"devices" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveDevices] minusSet:value];
    [self didChangeValueForKey:@"devices" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#endif

