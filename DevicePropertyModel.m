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

extern CueController * cueController;

@interface DevicePropertyModel (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveValue;
- (void)setPrimitiveValue:(NSNumber *)value;

@end



@implementation DevicePropertyModel

@dynamic name;
@dynamic value;
@dynamic device;




-(float)floatValue{
	return [[self value] floatValue];
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
		for(NSManagedObject * deviceRelation in [cue deviceRelations]){
			if([deviceRelation valueForKey:@"device"] == [self device]){
				deviceFound = YES;
			}
		}
		
		if(!deviceFound){
			NSManagedObject * deviceRelation = [NSEntityDescription insertNewObjectForEntityForName:@"CueDeviceRelation" 
																	  inManagedObjectContext:[self managedObjectContext]];
			[deviceRelation setValue:[self device] forKey:@"device"];
			
			[cue addDeviceRelationsObject:deviceRelation];
		}
	}
	
}

- (BOOL)validateValue:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

@end










