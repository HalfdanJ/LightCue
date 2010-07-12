//
//  Cue.h
//  LightCue
//
//  Created by Jonas Jongejan on 09/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CueModel : NSManagedObject {
	double preWaitRunningTime;
	double fadeTimeRunningTime;
	double fadeDownTimeRunningTime;
	double postWaitRunningTime;
	
	NSTimer * preWaitTimer;
	NSDate * preWaitTimerStartDate;
	
	NSTimer * fadeTimer;
	NSDate * fadeTimerStartDate;
	
	NSTimer * fadeDownTimer;
	NSDate * fadeDownTimerStartDate;
	
	NSTimer * postWaitTimer;
	NSDate * postWaitTimerStartDate;

}

- (IBAction) go;

- (void) startPreWait;
- (void) startFade;
- (void) startFadeDown;
- (void) startPostWait;

- (void)preWaitTimerFired:(NSTimer*)theTimer;
- (void)fadeTimerFired:(NSTimer*)theTimer;
- (void)fadeDownTimerFired:(NSTimer*)theTimer;
- (void)postWaitTimerFired:(NSTimer*)theTimer;





@property (readwrite) double preWaitRunningTime;
@property (readwrite) double fadeTimeRunningTime;
@property (readwrite) double fadeDownTimeRunningTime;
@property (readwrite) double postWaitRunningTime;
@property (readwrite) NSNumber * preWaitVisualRep;
@property (readwrite) NSNumber * fadeTimeVisualRep;
@property (readwrite) NSNumber * fadeDownTimeVisualRep;
@property (readwrite) NSNumber * postWaitVisualRep;

@property (nonatomic, retain) NSSet* deviceRelations;


- (void)addDeviceRelationsObject:(NSManagedObject *)value;
- (void)removeDeviceRelationsObject:(NSManagedObject *)value;
- (void)addDeviceRelations:(NSSet *)value;
- (void)removeDeviceRelations:(NSSet *)value;

@end