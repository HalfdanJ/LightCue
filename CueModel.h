//
//  CueModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 31/07/10.
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

//Table bindings
@property (readonly,retain)		NSImage * statusImage;
@property (readwrite, retain)	NSNumber * preWaitVisualRep;
@property (readwrite, retain)	NSNumber * fadeTimeVisualRep;
@property (readwrite, retain)	NSNumber * fadeDownTimeVisualRep;
@property (readwrite, retain)	NSNumber * postWaitVisualRep;


//Usefull bindings
@property (readonly, retain) NSDate * preWaitTimerStartDate;
@property (readwrite) double preWaitRunningTime;
@property (readwrite) double fadeTimeRunningTime;
@property (readwrite) double fadeDownTimeRunningTime;
@property (readwrite) double postWaitRunningTime;
@property (readonly) double runningTime;


//CoreData properties
@property (nonatomic, retain) NSDecimalNumber * cueNumber;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSNumber * isLeaf;
@property (nonatomic, retain) NSNumber * lineNumber;
@property (nonatomic, retain) NSNumber * mscNumber;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * postWait;
@property (nonatomic, retain) NSNumber * preWait;
@property (nonatomic, retain) NSNumber * fadeTime;
@property (nonatomic, retain) NSNumber * fadeDownTime;
@property (nonatomic, retain) CueModel * parent;

//Usefull functions
- (double) duration;
- (BOOL) running;



- (BOOL)follow;
- (void)setFollow:(BOOL)value;
 
- (CueModel*) nextCue;
- (CueModel*) previousCue;

@end

