//
//  Cue.m
//  LightCue
//
//  Created by Jonas Jongejan on 09/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueModel.h"

@interface CueModel (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveDeviceRelations;
- (void)setPrimitiveDeviceRelations:(NSMutableSet*)value;

@end



@implementation CueModel

@dynamic deviceRelations;

@synthesize preWaitRunningTime, preWaitVisualRep;
@synthesize fadeTimeRunningTime, fadeTimeVisualRep;
@synthesize fadeDownTimeRunningTime, fadeDownTimeVisualRep;
@synthesize postWaitRunningTime, postWaitVisualRep;

- (IBAction) go{
	NSLog(@"GO");
	[self startPreWait];
}

-(void) startPreWait{
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
	
}

-(void) startFade{
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
	
	if (fadeTimeRunningTime >= [[self valueForKey:@"fadeTime"] doubleValue]) {
		[fadeTimer invalidate];
		if(![fadeDownTimer isValid]){
		}
		fadeTimeRunningTime = 0;
	}
	[self didChangeValueForKey:@"fadeTimeVisualRep"];
}

- (void)fadeDownTimerFired:(NSTimer*)theTimer{
	[self willChangeValueForKey:@"fadeDownTimeVisualRep"];
	fadeDownTimeRunningTime = [[theTimer fireDate] timeIntervalSinceDate:fadeDownTimerStartDate];
	
	if (fadeDownTimeRunningTime >= [[self valueForKey:@"fadeDownTime"] doubleValue]) {
		[fadeDownTimer invalidate];
		if(![fadeTimer isValid]){
			[self startPostWait];
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



@end



