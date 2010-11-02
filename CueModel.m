//
//  CueModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 31/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueModel.h"

#import "NSManagedObjectContext-Category.h"


@implementation CueModel

@synthesize preWaitRunningTime, preWaitTimerStartDate, fadeTimeRunningTime, fadeDownTimeRunningTime, postWaitRunningTime;
@dynamic cueNumber;
@dynamic descriptionText;
@dynamic isLeaf;
@dynamic lineNumber;
@dynamic mscNumber;
@dynamic name;
@dynamic postWait;
@dynamic preWait;
@dynamic fadeTime;
@dynamic fadeDownTime;
@dynamic parent;
#pragma mark Actions


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
	
    
	preWaitTimerStartDate = nil;
	fadeTimerStartDate = nil;
	fadeDownTimerStartDate = nil;
	postWaitTimerStartDate = nil;
	
	[self didChangeValueForKey:@"running"];
	
	[self finishedRunning];
	
	
}


#pragma mark Cue timing


-(void) startPreWait{
	[self willChangeValueForKey:@"running"];
	
	preWaitTimerStartDate = [NSDate date];
	
	if([[self valueForKey:@"preWait"] doubleValue] > 0 ){
		preWaitTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
														target:self selector:@selector(preWaitTimerFired:)
													  userInfo:[NSNumber numberWithInt:1] repeats:YES];
	} else {
		[self startFade];
		[self startFadeDown];
		[self startPostWait];
		
	}
	
	[self didChangeValueForKey:@"running"];
	
}

-(void) startFade{	
	//	[CueModel runloop];
	
	
	if([[self valueForKey:@"fadeTime"] doubleValue] > 0 ){
		//		fadeTimer = [NSTimer timer
		
		
		fadeTimer = [NSTimer timerWithTimeInterval:0.001   //a 1ms time interval
											target:self
										  selector:@selector(fadeTimerFired:)
										  userInfo:nil
										   repeats:YES];
		
		[[NSRunLoop currentRunLoop] addTimer:fadeTimer 
									 forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:fadeTimer 
									 forMode:NSEventTrackingRunLoopMode]; //Ensure timer */
		
		
		/*fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.0001
		 target:self selector:@selector(fadeTimerFired:)
		 userInfo:[NSNumber numberWithInt:1] repeats:YES];*/
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
}

-(void) performFollow{
	if([self follow] ){
		[[self nextRunCue] go];
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
		if(![fadeDownTimer isValid] && ![postWaitTimer isValid] ){
			[self finishedRunning];
			fadeTimeRunningTime = 0;
			fadeDownTimeRunningTime = 0;
			postWaitRunningTime = 0;
		}
	}
	[self didChangeValueForKey:@"fadeTimeVisualRep"];
	
}

- (void)fadeDownTimerFired:(NSTimer*)theTimer{
	[self willChangeValueForKey:@"fadeDownTimeVisualRep"];
	fadeDownTimeRunningTime = [[theTimer fireDate] timeIntervalSinceDate:fadeDownTimerStartDate];
	
	if (fadeDownTimeRunningTime >= [[self valueForKey:@"fadeDownTime"] doubleValue]) {
		[fadeDownTimer invalidate];
		if(![fadeTimer isValid] && ![postWaitTimer isValid] ){
			[self finishedRunning];
			fadeTimeRunningTime = 0;
			fadeDownTimeRunningTime = 0;
			postWaitRunningTime = 0;
		}
		
	}
	[self didChangeValueForKey:@"fadeDownTimeVisualRep"];
}

- (void)postWaitTimerFired:(NSTimer*)theTimer{
	[self willChangeValueForKey:@"postWaitVisualRep"];
	postWaitRunningTime = [[theTimer fireDate] timeIntervalSinceDate:postWaitTimerStartDate];
	
	if (postWaitRunningTime >= [[self valueForKey:@"postWait"] doubleValue]) {
		[postWaitTimer invalidate];
		[self performFollow];
		if(![fadeTimer isValid] && ![fadeDownTimer isValid] ){
			[self finishedRunning];
			fadeTimeRunningTime = 0;
			fadeDownTimeRunningTime = 0;
			postWaitRunningTime = 0;
		}
	}
	[self didChangeValueForKey:@"postWaitVisualRep"];
}



#pragma mark Table bindings

+ (NSSet*) keyPathsForValuesAffectingStatusImage {
	return [NSSet setWithObjects: nil];
}
- (NSImage *) statusImage{
	return nil;
}

//Pre wait
-(NSNumber *) preWaitVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"preWait"] doubleValue] - preWaitRunningTime];
}
-(void) setPreWaitVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"preWait"];	
}

//Fade
-(NSNumber *) fadeTimeVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"fadeTime"] doubleValue] - fadeTimeRunningTime];
}
-(void) setFadeTimeVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"fadeTime"];	
}

//Fade down
-(NSNumber *) fadeDownTimeVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"fadeDownTime"] doubleValue] - fadeDownTimeRunningTime];
}
-(void) setFadeDownTimeVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"fadeDownTime"];	
}

//Post wait
-(NSNumber *) postWaitVisualRep{
	return [NSNumber numberWithDouble:[[self valueForKey:@"postWait"] doubleValue] - postWaitRunningTime];
}
-(void) setPostWaitVisualRep:(NSNumber *)n{
	[self setValue:n forKey:@"postWait"];	
}

#pragma mark Other bindings

+ (NSSet*) keyPathsForValuesAffectingName {
	return [NSSet setWithObjects:@"follow", nil];	
} 

#pragma mark Getters

-(double) duration{
	return [[self valueForKey:@"preWait"] doubleValue] + MAX( MAX([[self valueForKey:@"postWait"] doubleValue], [[self valueForKey:@"fadeTime"] doubleValue]), [[self valueForKey:@"fadeDownTime"] doubleValue]);
}
- (BOOL) running{
	if([preWaitTimer isValid] || [fadeTimer isValid] || [fadeDownTimer isValid] || [postWaitTimer isValid]){
		return YES;	
	} 
	return NO;
}

-(double) runningTime{
	if(![self running])
		return 0;
	
	if([preWaitTimer isValid]){	
		return [self preWaitRunningTime];
	}
	if([fadeTimer isValid]){	
		return [[self valueForKey:@"preWait"] doubleValue] + [self fadeTimeRunningTime];
	}
	if([fadeDownTimer isValid]){	
		return [[self valueForKey:@"preWait"] doubleValue] + [self fadeDownTimeRunningTime];
	}
	if([postWaitTimer isValid]){	
		return [[self valueForKey:@"preWait"] doubleValue] + [self postWaitRunningTime];
	}
	
	return 0;
}	

+ (NSSet*) keyPathsForValuesAffectingRunningTime{
	return [NSSet setWithObjects:@"running", @"preWaitVisualRep", @"postWaitVisualRep", @"fadeTimeVisualRep", @"fadeDownTimeVisualRep", nil];
}


-(int)childCount{
	int ret = 0;
	for(CueModel * child in [self valueForKey:@"children"]){
		ret += 1 + [child childCount];
	}
	
	return ret;
}

-(NSArray*) childrenFlattened{
	NSMutableArray * ret = [NSMutableArray array];
	for(CueModel * child in [self valueForKey:@"children"]){
		[ret addObject:child];
		[ret addObjectsFromArray:[child childrenFlattened]];
	}
	
	return ret;
}

-(BOOL) isGroup{
	return NO;	
}

#pragma mark  Copy Paste

+ (NSArray *)keysToBeCopied {
	static NSArray *keysToBeCopied = nil;
	if (keysToBeCopied == nil) {
		keysToBeCopied = [[NSArray alloc] initWithObjects:
						  @"name", @"cueNumber", @"descriptionText", @"fadeDownTime", @"fadeTime", @"follow",@"mscNumber",@"name",@"postWait",@"preWait", nil];
	}
	return keysToBeCopied;
}

- (NSString *)stringDescription {
	NSString *stringDescription = [self valueForKey:@"name"];
	return stringDescription;
}

- (NSDictionary *)dictionaryRepresentation {
	return [self dictionaryWithValuesForKeys:[[self class] keysToBeCopied]];
}



#pragma mark Navigation

- (CueModel*) nextCue{	
	return [[[self managedObjectContext] fetchObjectsForEntityName:@"Cue" withPredicate:@"lineNumber == %@ + 1",[self lineNumber]] anyObject];
	
	
	if([[super valueForKey:@"nextCues"] count] > 0)
		return [[super valueForKey:@"nextCues"]  lastObject];
	return nil;
}

- (CueModel*) previousCue{
	return [[[self managedObjectContext] fetchObjectsForEntityName:@"Cue" withPredicate:@"lineNumber == %@ - 1",[self lineNumber]] anyObject];
	if([[super valueForKey:@"previousCues"] count] > 0)
		return [[super valueForKey:@"previousCues"]  lastObject];
	return nil;
}

//A cue that is not a group
- (CueModel*) nextRunCue{
	CueModel * cue = [self nextCue];
	while([cue isGroup]){
		cue = [cue nextCue];
		if(cue == nil){
			return nil;
		}
	}
	return cue;
	
}
- (CueModel*) previousRunCue{
	CueModel * cue = [self previousCue];
	while([cue isGroup]){
		cue = [cue previousCue];
		if(cue == nil){
			return nil;
		}
	}
	return cue;
	
}




#pragma mark CoreData Access 

- (BOOL)follow 
{
	NSNumber * tmpValue;
	
	[self willAccessValueForKey:@"follow"];
	tmpValue = [self primitiveValueForKey:@"follow"];
	[self didAccessValueForKey:@"follow"];
	
	return [tmpValue boolValue];
}

- (void)setFollow:(BOOL)value 
{
	if(!value  || [self nextCue] != nil){
		
		[self willChangeValueForKey:@"follow"];
		[self setPrimitiveValue:[NSNumber numberWithBool:value] forKey:@"follow"];
		[self didChangeValueForKey:@"follow"];
	}
}

@end


