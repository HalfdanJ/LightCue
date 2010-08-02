//
//  CueDevicePropertyRelationModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 12/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueDevicePropertyRelationModel.h"
#import "DevicePropertyModel.h"

@implementation CueDevicePropertyRelationModel

@synthesize isMutexHolder, lostMutexValue;
@dynamic value;

-(id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
	if([super initWithEntity:entity insertIntoManagedObjectContext:context]){
		[self addObserver:self forKeyPath:@"deviceProperty" options:0 context:@"deviceProperty"];
		[[self valueForKey:@"deviceProperty"] addObserver:self forKeyPath:@"lastModifier" options:0 context:@"lastModifier"];
	}
	return self;
	
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([(NSString*)context isEqualToString:@"deviceProperty"]) {
		[[self valueForKey:@"deviceProperty"] addObserver:self forKeyPath:@"lastModifier" options:0 context:@"lastModifier"];
	}
	
	if ([(NSString*)context isEqualToString:@"lastModifier"]) {
		[self willChangeValueForKey:@"isLive"];
		[self didChangeValueForKey:@"isLive"];
		
		if([(DevicePropertyModel*)[self valueForKey:@"deviceProperty"] mutexHolder] == self){
			[self setIsMutexHolder:YES];
		} else {
			[self setIsMutexHolder:NO];
		}
	}
}

- (LightCueModel*) cue{
	return [[self valueForKey:@"cueDeviceRelation"] valueForKey:@"cue"];
}

-(CueDevicePropertyRelationModel *) trackBackwardsCached{
	return trackBackwardsCached;	
}

- (CueDevicePropertyRelationModel*) trackBackwards{
	//	NSLog(@"Tracking %@ backwards",[[self valueForKey:@"deviceProperty"] valueForKey:@"name"]);
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CueDevicePropertyRelation" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cueDeviceRelation.cue.lineNumber" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cueDeviceRelation.cue.lineNumber < %@ && cueDeviceRelation.device.deviceNumber == %@",
							  [[self cue] valueForKey:@"lineNumber"], [self valueForKeyPath:@"cueDeviceRelation.device.deviceNumber"]];
	[fetchRequest setPredicate:predicate];
	
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		// Handle the error
	}
	
	//NSLog(@"Fetch count: %i",[fetchedObjects count]);
	//for(CueDevicePropertyRelationModel * rel in fetchedObjects){
	//	NSLog(@"%@, line: %@",[[rel valueForKey:@"deviceProperty"] valueForKey:@"name"], [[rel cue] valueForKey:@"lineNumber"]);
	//}
	
	if([fetchedObjects count] > 0){
		trackBackwardsCached =  [fetchedObjects lastObject];
		return trackBackwardsCached;
	}
	
	trackBackwardsCached = nil;
	return nil;
	
	
}

-(BOOL) isLive{
	if([(DevicePropertyModel*)[self valueForKey:@"deviceProperty"] lastModifier] == self){
		return YES;
	}
	return NO;
}

-(void) setIsMutexHolder:(BOOL)b{
	if([self isMutexHolder] && !b){
		//Lost mutex
		[self setLostMutexValue:[self valueForKeyPath:@"deviceProperty.outputValue"]];
	}
	
	
	isMutexHolder = b;
}

@end


