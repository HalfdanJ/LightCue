//
//  DevicePropertyModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DevicePropertyModel.h"
#import "CueController.h"
#import "CueModel.h"
#import "CueDevicePropertyRelationModel.h"

extern CueController * cueController;

@interface DevicePropertyModel (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveValue;
- (void)setPrimitiveValue:(NSNumber *)value;

@end



@implementation DevicePropertyModel

@dynamic name;
@dynamic value;
@dynamic device;

@synthesize selectedCue, lastModifier, mutexHolder, isRunning;



-(id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
	if([super initWithEntity:entity insertIntoManagedObjectContext:context]){
	//	NSLog(@"%@",[cueController cueArrayController]);
		[[cueController cueArrayController] addObserver:self forKeyPath:@"selectionIndexes" options:nil context:@"cueSelection"];
	}
	return self;
}

-(float)floatValue{
	return [[self value] floatValue];
}

-(NSManagedObject*)devicePropertyInCue:(CueModel*)cue{
	for(NSManagedObject * cueDevicePropertyRelation in [self valueForKey:@"cueRelations"]){
		if([[cueDevicePropertyRelation valueForKey:@"cueDeviceRelation"] valueForKey:@"cue"] == cue){
			return cueDevicePropertyRelation;
		}
	}
	
	return nil;
}

- (NSManagedObject*)devicePropertyModifyingCue:(CueModel*)cue{
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
		if([self devicePropertyInCue:cue] == [self mutexHolder]){
			return [self valueForKey:@"outputValue"];
		} else {		
			return [[self devicePropertyInCue:cue]valueForKey:@"value"];
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
	if([self devicePropertyInCue:cue] != nil)
		return YES;
	
	return NO;
}

-(NSNumber *) valueInSelectedCue{
	if([[cueController selectedCues] count] == 1){
		CueModel * cue = [[cueController selectedCues] lastObject];
		return [self valueInCue:cue];
	}
	return nil;
	
}

-(BOOL) propertySetInSelectedCue{
	if([[cueController selectedCues] count] == 1){
		CueModel * cue = [[cueController selectedCues] lastObject];
		return [self propertySetInCue:cue];
	}
	return NO;
}

-(BOOL) propertyLiveInCue:(CueModel *)cue{
	if([(CueDevicePropertyRelationModel*)lastModifier cue] == cue){
		return YES;
	}
	return NO;
}

-(BOOL) propertyLiveInSelectedCue{
	if([[cueController selectedCues] count] == 1){
		CueModel * cue = [[cueController selectedCues] lastObject];
		return [self propertyLiveInCue:cue];
	}
	return NO;	
}

+ (NSSet *)keyPathsForValuesAffectingValueInSelectedCue{
    return [NSSet setWithObjects:@"selectedCue", @"value",@"cueRelations", nil];
}


+ (NSSet *)keyPathsForValuesAffectingPropertySetInSelectedCue{
    return [NSSet setWithObjects:@"selectedCue", nil];
}

+ (NSSet *)keyPathsForValuesAffectingPropertyLiveInSelectedCue{
    return [NSSet setWithObjects:@"selectedCue", @"cueRelations", @"isRunning", nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"cueSelection"]){
		if([[cueController selectedCues] count] == 1){
			[self setSelectedCue:[[cueController selectedCues] lastObject]];
		}
		else {
			[self setSelectedCue:nil];	
		}
	}
}	



-(void) clear{
	[self willChangeValueForKey:@"value"];
    [self setPrimitiveValue:[NSNumber numberWithInt:0]];
    [self didChangeValueForKey:@"value"];
}

- (NSNumber *)value 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"value"];
    tmpValue = [self primitiveValue];
    [self didAccessValueForKey:@"value"];
    
    return tmpValue;
}

- (void)setValue:(NSNumber *)value 
{
    [self willChangeValueForKey:@"value"];
    [self setPrimitiveValue:value];
    [self didChangeValueForKey:@"value"];
	
	if([[cueController selectedCues] count] == 1){
		CueModel * cue = [[cueController selectedCues] lastObject];
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
		}
	}
	
}

- (BOOL)validateValue:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}



@end

