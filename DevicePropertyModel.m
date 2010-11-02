//
//  DevicePropertyModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DevicePropertyModel.h"
#import "CueController.h"
#import "LightCueModel.h"
#import "CueDevicePropertyRelationModel.h"


@interface DevicePropertyModel (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveValue;
- (void)setPrimitiveValue:(NSNumber *)value;

@end



@implementation DevicePropertyModel

@dynamic name;
@dynamic value;
@dynamic device;

@synthesize selectedCue,activeCue , lastModifier, mutexHolder, isRunning, unsavedChanges;


/*
-(id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
	if([super initWithEntity:entity insertIntoManagedObjectContext:context]){
		//	NSLog(@"%@",[cueController cueArrayController]);
		//		[[cueController cueArrayController] addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"cueSelection"];
	}
	return self;
}*/

-(float)floatValue{
	return [[self value] floatValue];
}

-(NSManagedObject*)devicePropertyInCue:(LightCueModel*)cue{
	for(NSManagedObject * cueDevicePropertyRelation in [self valueForKey:@"cueRelations"]){
		if([[cueDevicePropertyRelation valueForKey:@"cueDeviceRelation"] valueForKey:@"cue"] == cue){
			return cueDevicePropertyRelation;
		}
	}

	return nil;
}

- (NSManagedObject*)devicePropertyModifyingCue:(LightCueModel*)cue{
	if([self propertySetInCue:cue]){
		return [self devicePropertyInCue:cue];
	} else {
		CueDevicePropertyRelationModel * wantedRelation = nil;
		int lowestLineNumber = -1;
		for(CueDevicePropertyRelationModel * cueRelation in [self valueForKey:@"cueRelations"]){
			if([[[cueRelation cue] lineNumber] intValue] > lowestLineNumber && [[[cueRelation cue] lineNumber] intValue] < [[cue lineNumber] intValue]){
				lowestLineNumber = [[[cueRelation cue] lineNumber] intValue];
				wantedRelation = cueRelation;
			}
		}
		return wantedRelation;
	}
}

-(void) setMutexHolder:(NSManagedObject *)obj{
	[self willChangeValueForKey:@"mutexHolder"];
	mutexHolder = obj;
	[self didChangeValueForKey:@"mutexHolder"];
	
	if(mutexHolder != nil)
		[self setLastModifier:obj];
}

- (NSNumber*) valueInCue:(CueModel*)cue{
	if([self propertySetInCue:cue]){
		if([self devicePropertyInCue:(LightCueModel*) cue] == [self mutexHolder]){
			return [self valueForKey:@"outputValue"];
		} else {		
			return [[self devicePropertyInCue:(LightCueModel*)cue] valueForKey:@"value"];
		}
	} else {
		CueDevicePropertyRelationModel * wantedRelation = nil;
		int lowestLineNumber = -1;
		for(CueDevicePropertyRelationModel * cueRelation in [self valueForKey:@"cueRelations"]){
			if([[[cueRelation cue] lineNumber] intValue] > lowestLineNumber && [[[cueRelation cue] lineNumber] intValue] < [[cue lineNumber] intValue]){
				lowestLineNumber = [[[cueRelation cue] lineNumber] intValue];
				wantedRelation = cueRelation;
			}
		}
		
		if(wantedRelation != nil){
			if(wantedRelation == [self mutexHolder]){
				return [self valueForKey:@"outputValue"];
			}
			else {
				return [wantedRelation valueForKey:@"value"];
			}
		} else {
			return [NSNumber numberWithInt:0];
		}
	}
}

- (BOOL) propertySetInCue:(CueModel*)cue{
	if([cue isKindOfClass:[LightCueModel class]] && [self devicePropertyInCue:(LightCueModel*)cue] != nil){
		return YES;
	}
	
	return NO;
}

-(NSNumber *) valueInSelectedCue{
	if([self selectedCue] != nil){
		LightCueModel * cue = selectedCue;
		return [self valueInCue:cue];
	}
	return nil;	
}

-(BOOL) propertySetInSelectedCue{
	if([self selectedCue] != nil){
		LightCueModel * cue = selectedCue;
		return [self propertySetInCue:cue];
	}
	return NO;
}

-(BOOL) propertyLiveInCue:(LightCueModel *)cue{
	if([(CueDevicePropertyRelationModel*)lastModifier cue] == cue){
		return YES;
	}
	return NO;
}

-(BOOL) propertyLiveInSelectedCue{
	if([self selectedCue] != nil){
		LightCueModel * cue = selectedCue;
		return [self propertyLiveInCue:cue];
	}
	return NO;	
}

+ (NSSet *)keyPathsForValuesAffectingValueInSelectedCue{
    return [NSSet setWithObjects:@"selectedCue", @"value",@"cueRelations", @"outputValue", nil];
}


+ (NSSet *)keyPathsForValuesAffectingPropertySetInSelectedCue{
    return [NSSet setWithObjects:@"selectedCue", nil];
}

+ (NSSet *)keyPathsForValuesAffectingPropertyLiveInSelectedCue{
    return [NSSet setWithObjects:@"selectedCue", @"cueRelations", @"isRunning", @"lastModifier", nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
}	



-(void) clear{
	[self setUnsavedChanges:NO];
	[self setValue:[NSNumber numberWithInt:-1] forKey:@"value"];	
	[self setValue:restoreOutputValue forKey:@"outputValue"];
	restoreOutputValue = nil;
}

- (NSNumber *)value 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"value"];
    tmpValue = [self primitiveValue];
    [self didAccessValueForKey:@"value"];
    
    return tmpValue;
}

- (void) setValue:(NSNumber *)value;
{
    [self willChangeValueForKey:@"value"];
    [self setPrimitiveValue:value];
    [self didChangeValueForKey:@"value"];
}

- (void) storeValue{
	if([self unsavedChanges] && [self selectedCue] != nil && [selectedCue isKindOfClass:[LightCueModel class]] ){
		LightCueModel * cue = selectedCue;
		BOOL deviceFound = NO;
		BOOL propertyFound = NO;
		NSManagedObject * deviceRelation, * devicePropertyRelation;
		for(NSManagedObject * _deviceRelation in [cue deviceRelations]){
			if([_deviceRelation valueForKey:@"device"] == [self device]){
				deviceFound = YES;
				deviceRelation = _deviceRelation;
				break;
			}
		}
		
		if(!deviceFound){
			//Add device to the cue
			deviceRelation = [NSEntityDescription insertNewObjectForEntityForName:@"CueDeviceRelation" inManagedObjectContext:[self managedObjectContext]];
			[deviceRelation setValue:[self device] forKey:@"device"];			
			[cue addDeviceRelationsObject:deviceRelation];
		} else {
			//else find the device relation in the cue
			for(NSManagedObject * _devicePropertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
				if([_devicePropertyRelation valueForKey:@"deviceProperty"] == self ){
					propertyFound = YES;
					devicePropertyRelation = _devicePropertyRelation;
					break;
				}
			}
		}
		
		if(!propertyFound){
			devicePropertyRelation = [NSEntityDescription insertNewObjectForEntityForName:@"CueDevicePropertyRelation" 
																   inManagedObjectContext:[self managedObjectContext]];
			[devicePropertyRelation setValue:deviceRelation forKey:@"cueDeviceRelation"];			
			[devicePropertyRelation setValue:[self value] forKey:@"value"];			
			[devicePropertyRelation setValue:self forKey:@"deviceProperty"];
			[self willChangeValueForKey:@"propertySetInSelectedCue"];
			[self didChangeValueForKey:@"propertySetInSelectedCue"];
		}
		
		[devicePropertyRelation setValue:[self value] forKey:@"value"];
		[self setValue:[self valueInSelectedCue] forKey:@"outputValue"];
		[self setUnsavedChanges:NO];
		/*//Check if its live, and should update the output value
		if([self propertyLiveInSelectedCue]){
			[self setValue:value forKey:@"outputValue"];
		} else {
			//Check if the last modifier is not set, or is before the selected cue, and that the selected cue is actually active
			if([[activeCue lineNumber] intValue] >= [[[self selectedCue] lineNumber] intValue] && 
			   ([self lastModifier] == nil || [[[self lastModifier] valueForKeyPath:@"cue.lineNumber"] intValue] <= [[[self selectedCue] lineNumber] intValue]))
			{
				[self setLastModifier:devicePropertyRelation];
				[self setValue:value forKey:@"outputValue"];
			}
		}*/
	}
}

- (void) setValueAndProcess:(NSNumber *)value;
{
	if(restoreOutputValue == nil){
		restoreOutputValue = [NSNumber numberWithInt:[[self valueForKey:@"outputValue"] intValue]];
	}
	[self setValue:value];
	
	[self setValue:value forKey:@"outputValue"];
	
	[self setUnsavedChanges:YES];
/*
	if([self selectedCue] != nil && [selectedCue isKindOfClass:[LightCueModel class]]){
		LightCueModel * cue = selectedCue;
		BOOL deviceFound = NO;
		BOOL propertyFound = NO;
		NSManagedObject * deviceRelation, * devicePropertyRelation;
		for(NSManagedObject * _deviceRelation in [cue deviceRelations]){
			if([_deviceRelation valueForKey:@"device"] == [self device]){
				deviceFound = YES;
				deviceRelation = _deviceRelation;
				break;
			}
		}
		
		if(!deviceFound){
			//Add device to the cue
			deviceRelation = [NSEntityDescription insertNewObjectForEntityForName:@"CueDeviceRelation" inManagedObjectContext:[self managedObjectContext]];
			[deviceRelation setValue:[self device] forKey:@"device"];			
			[cue addDeviceRelationsObject:deviceRelation];
		} else {
			//else find the device relation in the cue
			for(NSManagedObject * _devicePropertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
				if([_devicePropertyRelation valueForKey:@"deviceProperty"] == self ){
					propertyFound = YES;
					devicePropertyRelation = _devicePropertyRelation;
					break;
				}
			}
		}
		
		if(!propertyFound){
			devicePropertyRelation = [NSEntityDescription insertNewObjectForEntityForName:@"CueDevicePropertyRelation" 
																   inManagedObjectContext:[self managedObjectContext]];
			[devicePropertyRelation setValue:deviceRelation forKey:@"cueDeviceRelation"];			
			[devicePropertyRelation setValue:value forKey:@"value"];			
			[devicePropertyRelation setValue:self forKey:@"deviceProperty"];
			[self willChangeValueForKey:@"propertySetInSelectedCue"];
			[self didChangeValueForKey:@"propertySetInSelectedCue"];
		}
		
		[devicePropertyRelation setValue:value forKey:@"value"];
		
		//Check if its live, and should update the output value
		if([self propertyLiveInSelectedCue]){
			[self setValue:value forKey:@"outputValue"];
		} else {
			//Check if the last modifier is not set, or is before the selected cue, and that the selected cue is actually active
			if([[activeCue lineNumber] intValue] >= [[[self selectedCue] lineNumber] intValue] && 
			   ([self lastModifier] == nil || [[[self lastModifier] valueForKeyPath:@"cue.lineNumber"] intValue] <= [[[self selectedCue] lineNumber] intValue]))
			{
				[self setLastModifier:devicePropertyRelation];
				[self setValue:value forKey:@"outputValue"];
			}
		}
	}*/
	
}


@end

