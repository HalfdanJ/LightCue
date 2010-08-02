//
//  CueModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 31/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueModel.h"


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


#pragma mark Navigation

- (CueModel*) nextCue{	
	if([[super valueForKey:@"nextCues"] count] > 0)
		return [[super valueForKey:@"nextCues"]  lastObject];
	return nil;
}

- (CueModel*) previousCue{
	if([[super valueForKey:@"previousCues"] count] > 0)
		return [[super valueForKey:@"previousCues"]  lastObject];
	return nil;
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


