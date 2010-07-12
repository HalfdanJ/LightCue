//
//  DeviceModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DeviceModel.h"
#import "Helper.h"

@interface DeviceModel (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;

@end



@implementation DeviceModel
@dynamic properties;
@dynamic deviceNumber;
@dynamic addresses;


-(void) awakeFromFetch{
	_dimmerStore = nil;
	[super awakeFromFetch];
}



-(DevicePropertyModel*) getProperty:(NSString*)name{
	NSSet* set = [[self managedObjectContext] fetchObjectsForEntityName:@"DeviceProperty" withPredicate:
				  @"(name like %@) AND (device.deviceNumber == %i)", name,[[self deviceNumber] intValue]];
	if([set count] == 0)
		return nil;
	
	return (DevicePropertyModel*)[set anyObject];
}

-(DevicePropertyModel *) dimmer{
	if(_dimmerStore == nil){
		_dimmerStore = [self getProperty:@"DIM"];

		if(_dimmerStore != nil){
			[_dimmerStore addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionPrior context:@"dimmerChange"];
		}
	}
	return _dimmerStore;
}

-(NSString*) fullName{
	NSString * ret;
	if([[self valueForKey:@"name"] length] == 0){
		ret = [NSString stringWithFormat:@"%@",[self valueForKey:@"deviceNumber"]];
	} else {
		ret = [NSString stringWithFormat:@"%@: %@",[self valueForKey:@"deviceNumber"],[self valueForKey:@"name"]];	
	}
	return ret;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
}

-(void) setAddressesToken:(NSArray *)array{
	
	[self setAddresses:[NSSet set]];
	
	for(NSString * string in array){

		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		NSNumber * number = [f numberFromString:string];
		[f release];
		
		NSManagedObject * channel = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceDmxAddress" 
									  inManagedObjectContext:[self managedObjectContext]];
		[channel setValue:number forKey:@"address"];
		[self addAddressesObject:channel];
	}
	

}

-(NSArray *) addressesToken{
	NSMutableArray * array = [NSMutableArray array];
	for(NSManagedObject * obj in [self addresses]){
		[array addObject:[NSString stringWithFormat:@"%@",[obj valueForKey:@"address"]]];
	}
	
	return array;
}


+ (NSSet *)keyPathsForValuesAffectingAddressesToken{
    return [NSSet setWithObjects:@"addresses", nil];
}







/*
 *
 *
 *
 *
 */

- (void)addAddressesObject:(NSManagedObject *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"addresses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveAddresses] addObject:value];
    [self didChangeValueForKey:@"addresses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeAddressesObject:(NSManagedObject *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"addresses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveAddresses] removeObject:value];
    [self didChangeValueForKey:@"addresses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addAddresses:(NSSet *)value 
{    
    [self willChangeValueForKey:@"addresses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveAddresses] unionSet:value];
    [self didChangeValueForKey:@"addresses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeAddresses:(NSSet *)value 
{
    [self willChangeValueForKey:@"addresses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveAddresses] minusSet:value];
    [self didChangeValueForKey:@"addresses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}





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


// coalesce these into one @interface DeviceModel (CoreDataGeneratedPrimitiveAccessors) section
@interface DeviceModel (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveProperties;
- (void)setPrimitiveProperties:(NSMutableSet*)value;

- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;

@end


- (void)addPropertiesObject:(NSManagedObject *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"properties" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveProperties] addObject:value];
    [self didChangeValueForKey:@"properties" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removePropertiesObject:(NSManagedObject *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"properties" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveProperties] removeObject:value];
    [self didChangeValueForKey:@"properties" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addProperties:(NSSet *)value 
{    
    [self willChangeValueForKey:@"properties" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveProperties] unionSet:value];
    [self didChangeValueForKey:@"properties" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeProperties:(NSSet *)value 
{
    [self willChangeValueForKey:@"properties" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveProperties] minusSet:value];
    [self didChangeValueForKey:@"properties" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#endif





