//
//  DeviceModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DeviceModel.h"
#import "Helper.h"
#import "DevicePropertyModel.h"



@interface DeviceModel (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;

@end



@implementation DeviceModel
@dynamic properties;
@dynamic deviceNumber;
@dynamic addresses;

@synthesize selectedCue;


-(void) awakeFromFetch{
	_dimmerStore = nil;
	[super awakeFromFetch];
}

-(id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
	if([super initWithEntity:entity insertIntoManagedObjectContext:context]){
		//		[[cueController cueArrayController] addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"cueSelection"];
		[self addObserver:self forKeyPath:@"properties" options:0 context:@"properties"];
		
	}
	return self;
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

-(void) clearDimmer{
	[[self dimmer] clear];
}

- (BOOL) propertySetInCue:(LightCueModel*)cue{
	for(DevicePropertyModel * prop in [self properties]){
		if([prop propertySetInCue:cue])
			return YES;
	}
	return NO;
}

-(BOOL) propertySetInSelectedCue{
	return [self propertySetInCue:selectedCue];
}

-(BOOL) isRunning{
	for(DevicePropertyModel * prop in [self properties]){
		if([prop isRunning])
			return YES;
	}
	return NO;
}

-(float) percentageLiveInSelectedCue{
	float v = 0;
	for(DevicePropertyModel * prop in [self properties]){
		if([prop propertyLiveInSelectedCue])
			v += 1;
	}
	
	v /= [[self properties] count];
	return v;
	
}

-(void) setSelectedCue:(LightCueModel *)c{
	[self willChangeValueForKey:@"selectedCue"];
	selectedCue = c;
	[self didChangeValueForKey:@"selectedCue"];
	
	for(DevicePropertyModel* prop in [self properties]){
		[prop setSelectedCue:selectedCue];
	}
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	/*	if([(NSString*)context isEqualToString:@"cueSelection"]){
	 if([[cueController selectedCues] count] == 1){
	 [self setSelectedCue:[[cueController selectedCues] lastObject]];
	 }
	 else {
	 [self setSelectedCue:nil];	
	 }
	 }*/
	if([(NSString*)context isEqualToString:@"properties"]){
		for(DevicePropertyModel * prop in [self properties]){
			[prop addObserver:self forKeyPath:@"propertySetInSelectedCue" options:nil context:@"propertySetInSelectedCue"];
			[prop addObserver:self forKeyPath:@"isRunning" options:0 context:@"isRunning"];	
			[prop addObserver:self forKeyPath:@"propertyLiveInSelectedCue" options:0 context:@"propertyLiveInSelectedCue"];	
			
		}
	}
	if([(NSString*)context isEqualToString:@"propertySetInSelectedCue"]){
		[self willChangeValueForKey:@"propertySetInSelectedCue"];
		[self didChangeValueForKey:@"propertySetInSelectedCue"];
	}
	if([(NSString*)context isEqualToString:@"propertyLiveInSelectedCue"]){
		[self willChangeValueForKey:@"percentageLiveInSelectedCue"];
		[self didChangeValueForKey:@"percentageLiveInSelectedCu"];
	}
	if([(NSString*)context isEqualToString:@"isRunning"]){
		[self willChangeValueForKey:@"isRunning"];
		[self didChangeValueForKey:@"isRunning"];
	}
	
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







