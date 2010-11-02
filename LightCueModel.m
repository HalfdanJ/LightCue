//
//  Cue.m
//  LightCue
//
//  Created by Jonas Jongejan on 09/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "LightCueModel.h"
#import "DevicePropertyModel.h"
//
//--------<
//


@interface LightCueModel (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveDeviceRelations;
- (void)setPrimitiveDeviceRelations:(NSMutableSet*)value;


- (NSNumber *)primitiveFadeTime;
- (void)setPrimitiveFadeTime:(NSNumber *)value;


@end

//
//--------
//

@interface LightCueModel (MyPrivate)
- (void) updateOutput;

@end


//
//--------
//


@implementation LightCueModel

@dynamic deviceRelations;
@dynamic fadeTime;

-(id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
	if([super initWithEntity:entity insertIntoManagedObjectContext:context]){
		[self addObserver:self forKeyPath:@"follow" options:0 context:@"follow"];

	}
	return self;
}

- (void)awakeFromInsert;
{
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"isLeaf"];
}

-(void) prepareForDeletion{
	[self removeObserver:self forKeyPath:@"follow"];
}


- (IBAction) stop{
	[super stop];

	fadePercent = 0;
	fadeDownPercent = 0;
		
	for(NSManagedObject * deviceRelation in [self deviceRelations]){
		for(CueDevicePropertyRelationModel * propertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
			if([[propertyRelation valueForKey:@"deviceProperty"] valueForKey:@"mutexHolder"] == propertyRelation){
				[[propertyRelation valueForKey:@"deviceProperty"]  setValue:nil forKey:@"mutexHolder"];
				[[propertyRelation valueForKey:@"deviceProperty"]  setValue:nil forKey:@"lastModifier"];
			}
		}
	}
	
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([(NSString*)context isEqualToString:@"isLive"]){
		[self willChangeValueForKey:@"percentageLive"];
		[self didChangeValueForKey:@"percentageLive"];
	}
	if([(NSString*)context isEqualToString:@"follow"]){
		[[self managedObjectContext] processPendingChanges];
		[[[self managedObjectContext] undoManager] disableUndoRegistration];
		
		[[self nextCue] willChangeValueForKey:@"name"];
		[[self nextCue] didChangeValueForKey:@"name"];
		
		[[self managedObjectContext] processPendingChanges];
		[[[self managedObjectContext] undoManager] enableUndoRegistration];
		
		
	}
	
}


+ (NSArray *)keysToBeCopied {
    static NSArray *keysToBeCopied = nil;
    if (keysToBeCopied == nil) {
        keysToBeCopied = [[NSArray alloc] initWithObjects:
						  @"relationsDictionaryRepresentation", @"name", @"cueNumber", @"descriptionText", @"fadeDownTime", @"fadeTime", @"follow",@"mscNumber",@"name",@"postWait",@"preWait", nil];
    }
    return keysToBeCopied;
}

-(NSArray *) relationsDictionaryRepresentation{
	NSMutableArray * dict = [NSMutableArray array];
	for(CueDeviceRelationModel * deviceRelation in [self deviceRelations]){
		NSMutableArray * propRelations = [NSMutableArray array];
		
		for(CueDevicePropertyRelationModel * propRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
			
			NSString * linkName  = [propRelation valueForKey:@"linkName"];
			if(linkName == nil) linkName = @"";
			
			[propRelations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									  linkName,@"linkName", 
									  [propRelation valueForKeyPath:@"deviceProperty.name"],@"name", 
									  [propRelation valueForKey:@"value"], @"value",nil]];
			
			
		}
		[dict addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						 propRelations,@"relations",
						 [deviceRelation valueForKeyPath:@"device.deviceNumber"],@"deviceNumber",nil]];
	}
	
	return dict;
}


-(NSArray *) deviceRelationsChangeNotifier{
	return [self valueForKey:@"deviceRelations"];
}

+ (NSSet*) keyPathsForValuesAffectingDeviceRelationsChangeNotifier{
	return [NSSet setWithObjects:@"deviceRelations", nil];

}


-(void) setRelationsDictionaryRepresentation:(NSArray *)d{
	for(NSDictionary * devicesRelation in d){
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"Device" inManagedObjectContext:[self managedObjectContext]]];
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"deviceNumber == %@", [devicesRelation valueForKey:@"deviceNumber"]]];	
		NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
		
		if([fetchedObjects count] > 0){
			DeviceModel * device = [fetchedObjects lastObject];
			CueDeviceRelationModel* deviceRelation = [NSEntityDescription insertNewObjectForEntityForName:@"CueDeviceRelation" inManagedObjectContext:[self managedObjectContext]];
			[deviceRelation setValue:device forKey:@"device"];
			[self addDeviceRelationsObject:deviceRelation];
			
			for(NSDictionary * depropertyRelation in [devicesRelation valueForKey:@"relations"]){		
				NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
				[fetchRequest setEntity:[NSEntityDescription entityForName:@"DeviceProperty" inManagedObjectContext:[self managedObjectContext]]];
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@ && device.deviceNumber == %@", [depropertyRelation valueForKey:@"name"], [devicesRelation valueForKey:@"deviceNumber"]]];	
				NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];

				if([fetchedObjects count] > 0){
					CueDevicePropertyRelationModel* propertyRelation = [NSEntityDescription insertNewObjectForEntityForName:@"CueDevicePropertyRelation" inManagedObjectContext:[self managedObjectContext]];
					[propertyRelation setValue:[fetchedObjects lastObject] forKey:@"deviceProperty"];
					[propertyRelation setValue:[depropertyRelation valueForKey:@"linkName"] forKey:@"linkName"];
					[propertyRelation setValue:[depropertyRelation valueForKey:@"value"] forKey:@"value"];
					[propertyRelation setValue:deviceRelation forKey:@"cueDeviceRelation"];
				}
				
			}			
		}		
	}
}



-(float) percentageLive{
	float ret = 0;
	int num = 0;
	for(NSManagedObject * deviceRelation in [self deviceRelations]){
		for(CueDevicePropertyRelationModel * propertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
			num += 1;
			if([propertyRelation isLive]){
				ret += 1;
			}
		}
	}
	ret /=(float) num;
	
	return ret;
}


+ (NSSet*) keyPathsForValuesAffectingStatusImage {
	return [NSSet setWithObjects:@"running", @"percentageLive", nil];
}
- (NSImage *) statusImage{
	if([self running])
		return  [NSImage imageNamed:@"greenDot"];
	if([self percentageLive] == 1)
		return   [NSImage imageNamed:@"orangeDot"]; 
	
	if([self percentageLive] > 0)
		return   [NSImage imageNamed:@"halfOrangeDot"]; 
	
	
	return nil;
}





- (void) updateOutput{
	double percent = fadePercent;
	
	for(NSManagedObject * deviceRelation in [self deviceRelations]){
		for(CueDevicePropertyRelationModel * propertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
			CueDevicePropertyRelationModel * mutexHolder = [[propertyRelation valueForKey:@"deviceProperty"] valueForKey:@"mutexHolder"];
			if(mutexHolder == propertyRelation){
				
				CueDevicePropertyRelationModel * lastRelation = [propertyRelation trackBackwardsCached];
				double fadeFrom;
				if(lastRelation == nil){
					fadeFrom = 0;
				} else {
					fadeFrom = [[lastRelation valueForKey:@"lostMutexValue"] doubleValue];
				}	
				[[self managedObjectContext] processPendingChanges];
				[[[self managedObjectContext] undoManager] disableUndoRegistration];
								
				[[propertyRelation valueForKey:@"deviceProperty"] setValue:[NSNumber numberWithFloat:percent*[[propertyRelation valueForKey:@"value"] doubleValue]  + (1-percent)*fadeFrom] forKey:@"outputValue"];
				
				[[self managedObjectContext] processPendingChanges];
				[[[self managedObjectContext] undoManager] enableUndoRegistration];

			}
		}
	}
}

-(void) startPreWait{
	fadePercent = 0;
	fadeDownPercent = 0;
	
	
		
	NSSet * cueDeviceRelations = [self deviceRelations];
	for(NSManagedObject * obj in cueDeviceRelations){
		for(CueDevicePropertyRelationModel * relation in [obj valueForKey:@"devicePropertyRelations"]){
			CueDevicePropertyRelationModel * lastModifier = [[relation valueForKey:@"deviceProperty"] valueForKey:@"mutexHolder"];
			if(lastModifier == nil || [[[lastModifier cue] lineNumber] intValue] < [[self lineNumber] intValue] ){
				[[relation valueForKey:@"deviceProperty"]  setValue:relation forKey:@"mutexHolder"];
				[(DevicePropertyModel*)[relation valueForKey:@"deviceProperty"] setIsRunning:YES];
			} 
		}
	}
	
	[super startPreWait];
	
	
}

-(void) startFade{	
	//Update cache of tracking
	for(NSManagedObject * deviceRelation in [self deviceRelations]){
		for(CueDevicePropertyRelationModel * propertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
			[propertyRelation trackBackwards];
		}
	}

	[super startFade];
}

-(void) finishedRunning{
	[super finishedRunning];
	
	NSSet * cueDeviceRelations = [self deviceRelations];
	for(NSManagedObject * obj in cueDeviceRelations){
		for(CueDevicePropertyRelationModel * relation in [obj valueForKey:@"devicePropertyRelations"]){
			[(DevicePropertyModel*)[relation valueForKey:@"deviceProperty"] setIsRunning:NO];
			
			CueDevicePropertyRelationModel * mutexHolder = [[relation valueForKey:@"deviceProperty"] valueForKey:@"mutexHolder"];
			if(mutexHolder == relation){
				[[relation valueForKey:@"deviceProperty"]  setValue:nil forKey:@"mutexHolder"];
			} 
			CueDevicePropertyRelationModel * lastRelation = [relation trackBackwardsCached];
			[lastRelation setValue:[lastRelation valueForKey:@"value"] forKey:@"lostMutexValue"];
			
		}
	}
	
}


- (void)fadeTimerFired:(NSTimer*)theTimer{
	[super fadeTimerFired:theTimer];

	fadePercent = fadeTimeRunningTime/[[self valueForKey:@"fadeTime"] doubleValue];
	if(fadePercent > 1)
		fadePercent = 1;
	
	NSLog(@"Fade time %f %f",fadePercent, fadeTimeRunningTime);
	
	[self updateOutput ];
	
	
}

- (void)fadeDownTimerFired:(NSTimer*)theTimer{
	[super fadeDownTimerFired:theTimer];
	
	fadeDownPercent = fadeDownTimeRunningTime/[[self valueForKey:@"fadeTime"] doubleValue];
	if(fadeDownPercent > 1)
		fadeDownPercent = 1;

	[self updateOutput ];

}


#pragma mark CoreData

- (void)addDeviceRelationsObject:(NSManagedObject *)value 
{    
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
	
	[self willChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
	[[self primitiveDeviceRelations] addObject:value];
	[self didChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
	
	[changedObjects release];
	
}

- (void)removeDeviceRelationsObject:(NSManagedObject *)value 
{
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
	
	[self willChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
	[[self primitiveDeviceRelations] removeObject:value];
	[self didChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
	
	[changedObjects release];
}

- (void)addDeviceRelations:(NSSet *)value 
{    
	[self willChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
	[[self primitiveDeviceRelations] unionSet:value];
	[self didChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeDeviceRelations:(NSSet *)value 
{
	[self willChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
	[[self primitiveDeviceRelations] minusSet:value];
	[self didChangeValueForKey:@"deviceRelations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (void)setFadeTime:(NSNumber *)value 
{
	if([[self valueForKey:@"fadeDownTime"] isEqualToNumber:[self primitiveFadeTime]]){
		[self setValue:value forKey:@"fadeDownTime"];
	}
	
	[self willChangeValueForKey:@"fadeTime"];
	[self setPrimitiveFadeTime:value];
	[self didChangeValueForKey:@"fadeTime"];
}



@end
