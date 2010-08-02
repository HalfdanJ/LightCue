//
//  CueDevicePropertyRelationModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 12/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LightCueModel;
@interface CueDevicePropertyRelationModel : NSManagedObject {
	CueDevicePropertyRelationModel * trackBackwardsCached;
	BOOL isMutexHolder;
	
	//The value when lost the mutex
	NSNumber * lostMutexValue;
}

@property (nonatomic, retain) NSNumber * value;
@property (readonly) BOOL isLive;
@property (readwrite) BOOL isMutexHolder;
@property (copy) NSNumber * lostMutexValue;
@property (retain, readonly) LightCueModel * cue;


- (CueDevicePropertyRelationModel*) trackBackwards;
- (CueDevicePropertyRelationModel*) trackBackwardsCached;

@end


