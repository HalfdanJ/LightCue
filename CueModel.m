//
//  Cue.m
//  LightCue
//
//  Created by Jonas Jongejan on 09/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueModel.h"
#import "DevicePropertyModel.h"
//
//--------<
//


@interface CueModel (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveDeviceRelations;
- (void)setPrimitiveDeviceRelations:(NSMutableSet*)value;


- (NSNumber *)primitiveFadeTime;
- (void)setPrimitiveFadeTime:(NSNumber *)value;


@end

//
//--------
//

@interface CueModel (MyPrivate)
- (void) updateOutput;

@end


//
//--------
//


@implementation CueModel

@dynamic deviceRelations;
@dynamic fadeTime;
@dynamic lineNumber;

@synthesize preWaitRunningTime, preWaitVisualRep;
@synthesize fadeTimeRunningTime, fadeTimeVisualRep;
@synthesize fadeDownTimeRunningTime, fadeDownTimeVisualRep;
@synthesize postWaitRunningTime, postWaitVisualRep;

-(id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
	if([super initWithEntity:entity insertIntoManagedObjectContext:context]){
		[self addObserver:self forKeyPath:@"follow" options:nil context:@"follow"];
	}
	return self;
}
- (IBAction) go{
	if([self running])
		[self stop];
	[self startPreWait];
}

- (IBAction) stop{
	[self willChangeValueForKey:@"running"];
	
	[preWaitTimer invalidate];
	[fadeTimer invalidate];
	[fadeDownTimer invalidate];
	[postWaitTimer invalidate];
	
	[self willChangeValueForKey:@"preWaitVisualRep"];
	[self willChangeValueForKey:@"fadeTimeVisualRep"];
	[self willChangeValueForKey:@"fadeDownTimeVisualRep"];
	[self willChangeValueForKey:@"postWaitVisualRep"];
	
	preWaitRunningTime = 0;
	fadeTimeRunningTime = 0;
	fadeDownTimeRunningTime = 0;
	postWaitRunningTime = 0;
	
	[self didChangeValueForKey:@"preWaitVisualRep"];
	[self didChangeValueForKey:@"fadeTimeVisualRep"];
	[self didChangeValueForKey:@"fadeDownTimeVisualRep"];
	[self didChangeValueForKey:@"postWaitVisualRep"];
	
	fadePercent = 0;
	fadeDownPercent = 0;
	
	[self didChangeValueForKey:@"running"];
	
	[self finishedRunning];
	
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
		[[self nextCue] willChangeValueForKey:@"name"];
		[[self nextCue] didChangeValueForKey:@"name"];
	}
	
}

- (BOOL) running{
	if([preWaitTimer isValid] || [fadeTimer isValid] || [fadeDownTimer isValid] || [postWaitTimer isValid]){
		return YES;	
	} 
	return NO;
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

+ (NSSet*) keyPathsForValuesAffectingName {
    return [NSSet setWithObjects:@"follow", nil];	
} 

- (CueModel*) nextCue{
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Cue" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lineNumber == %@+1", [self valueForKey:@"lineNumber"]];
	[fetchRequest setPredicate:predicate];	
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
	
	if([fetchedObjects count] > 0){
		return [fetchedObjects lastObject];
	}
	return nil;	
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
				[[propertyRelation valueForKey:@"deviceProperty"] setValue:[NSNumber numberWithFloat:percent*[[propertyRelation valueForKey:@"value"] doubleValue]  + (1-percent)*fadeFrom] forKey:@"outputValue"];
			}
		}
	}
}

-(void) startPreWait{
	fadePercent = 0;
	fadeDownPercent = 0;
	
	[self willChangeValueForKey:@"running"];
	
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
	
	if([[self valueForKey:@"preWait"] doubleValue] > 0 ){
		preWaitTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
														target:self selector:@selector(preWaitTimerFired:)
													  userInfo:[NSNumber numberWithInt:1] repeats:YES];
		preWaitTimerStartDate = [NSDate date];
	} else {
		[self startFade];
		[self startFadeDown];
		[self startPostWait];
		
	}
	
	[self didChangeValueForKey:@"running"];
	
}

-(void) startFade{
	//Update cache of tracking
	for(NSManagedObject * deviceRelation in [self deviceRelations]){
		for(CueDevicePropertyRelationModel * propertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){
			[propertyRelation trackBackwards];
		}
	}
	
	if([[self valueForKey:@"fadeTime"] doubleValue] > 0 ){
		fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
													 target:self selector:@selector(fadeTimerFired:)
												   userInfo:[NSNumber numberWithInt:1] repeats:YES];
		fadeTimerStartDate = [NSDate date];
	} else {
	}
}

-(void) startFadeDown{
	if([[self valueForKey:@"fadeDownTime"] doubleValue] > 0 ){
		fadeDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
														 target:self selector:@selector(fadeDownTimerFired:)
													   userInfo:[NSNumber numberWithInt:1] repeats:YES];
		fadeDownTimerStartDate = [NSDate date];
	} else {
		if([[self valueForKey:@"fadeTime"] doubleValue] == 0){
			[self startPostWait];
		}
	}
}

-(void) startPostWait{
	if([[self valueForKey:@"postWait"] doubleValue] > 0 ){
		postWaitTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
														 target:self selector:@selector(postWaitTimerFired:)
													   userInfo:[NSNumber numberWithInt:1] repeats:YES];
		postWaitTimerStartDate = [NSDate date];
	} else {
		[self performFollow];
	}
}

-(void) finishedRunning{
	[self willChangeValueForKey:@"running"];
	[self didChangeValueForKey:@"running"];
	
	
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

-(void) performFollow{
	if([[self follow] boolValue]){
		[[self nextCue] go];
	}
}

- (void)preWaitTimerFired:(NSTimer*)theTimer{
	[self willChangeValueForKey:@"preWaitVisualRep"];
	preWaitRunningTime = [[theTimer fireDate] timeIntervalSinceDate:preWaitTimerStartDate];
	
	if (preWaitRunningTime >= [[self valueForKey:@"preWait"] doubleValue]) {
		[preWaitTimer invalidate];
		preWaitRunningTime = 0;
		[self startFade];
		[self startFadeDown];
		[self startPostWait];
		
	}
	[self didChangeValueForKey:@"preWaitVisualRep"];
}

- (void)fadeTimerFired:(NSTimer*)theTimer{
	[self willChangeValueForKey:@"fadeTimeVisualRep"];
	fadeTimeRunningTime = [[theTimer fireDate] timeIntervalSinceDate:fadeTimerStartDate];
	
	fadePercent = fadeTimeRunningTime/[[self valueForKey:@"fadeTime"] doubleValue];
	if(fadePercent > 1)
		fadePercent = 1;
	
	if (fadeTimeRunningTime >= [[self valueForKey:@"fadeTime"] doubleValue]) {
		[fadeTimer invalidate];
		if(![fadeDownTimer isValid] && ![postWaitTimer isValid] ){
			[self finishedRunning];
		}
		fadeTimeRunningTime = 0;
	}
	[self didChangeValueForKey:@"fadeTimeVisualRep"];
	
	[self updateOutput ];
	
	
}

- (void)fadeDownTimerFired:(NSTimer*)theTimer{
	[self willChangeValueForKey:@"fadeDownTimeVisualRep"];
	fadeDownTimeRunningTime = [[theTimer fireDate] timeIntervalSinceDate:fadeDownTimerStartDate];
	fadeDownPercent = fadeDownTimeRunningTime/[[self valueForKey:@"fadeTime"] doubleValue];
	if(fadeDownPercent > 1)
		fadeDownPercent = 1;
	
	
	if (fadeDownTimeRunningTime >= [[self valueForKey:@"fadeDownTime"] doubleValue]) {
		[fadeDownTimer invalidate];
		if(![fadeTimer isValid] && ![postWaitTimer isValid] ){
			[self finishedRunning];
		}
		
		fadeDownTimeRunningTime = 0;
	}
	[self didChangeValueForKey:@"fadeDownTimeVisualRep"];
}

- (void)postWaitTimerFired:(NSTimer*)theTimer{
	[self willChangeValueForKey:@"postWaitVisualRep"];
	postWaitRunningTime = [[theTimer fireDate] timeIntervalSinceDate:postWaitTimerStartDate];
	
	if (postWaitRunningTime >= [[self valueForKey:@"postWait"] doubleValue]) {
		[postWaitTimer invalidate];
		postWaitRunningTime = 0;
		[self performFollow];
		if(![fadeTimer isValid] && ![fadeDownTimer isValid] ){
			[self finishedRunning];
		}
	}
	[self didChangeValueForKey:@"postWaitVisualRep"];
}



-(NSNumber *) preWaitVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"preWait"] doubleValue] - preWaitRunningTime];
}

-(void) setPreWaitVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"preWait"];	
}

-(NSNumber *) fadeTimeVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"fadeTime"] doubleValue] - fadeTimeRunningTime];
}

-(void) setFadeTimeVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"fadeTime"];	
}

-(NSNumber *) fadeDownTimeVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"fadeDownTime"] doubleValue] - fadeDownTimeRunningTime];
}

-(void) setFadeDownTimeVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"fadeDownTime"];	
}

-(NSNumber *) postWaitVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"postWait"] doubleValue] - postWaitRunningTime];
}

-(void) setPostWaitVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"postWait"];	
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

- (NSNumber *)follow 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"follow"];
    tmpValue = [self primitiveValueForKey:@"follow"];
    [self didAccessValueForKey:@"follow"];
    
    return tmpValue;
}

- (void)setFollow:(NSNumber *)value 
{
	if(![value boolValue] || [self nextCue] != nil){
		
		[self willChangeValueForKey:@"follow"];
		[self setPrimitiveValue:value forKey:@"follow"];
		[self didChangeValueForKey:@"follow"];
	}
}

@end
