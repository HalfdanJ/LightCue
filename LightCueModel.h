//
//  Cue.h
//  LightCue
//
//  Created by Jonas Jongejan on 09/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CueDevicePropertyRelationModel.h"
#import "CueDeviceRelationModel.h"
#import "CueModel.h"

@interface LightCueModel : CueModel {
	double fadePercent;
	double fadeDownPercent;
}

- (IBAction) go;
- (IBAction) stop;


- (void) startPreWait;
- (void) startFade;
- (void) startFadeDown;
- (void) startPostWait;

- (void)preWaitTimerFired:(NSTimer*)theTimer;
- (void)fadeTimerFired:(NSTimer*)theTimer;
- (void)fadeDownTimerFired:(NSTimer*)theTimer;
- (void)postWaitTimerFired:(NSTimer*)theTimer;

- (void) finishedRunning;
- (void) performFollow;





+ (NSArray *)keysToBeCopied;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)stringDescription;


@property (readonly) BOOL running;
@property (readonly) NSArray * deviceRelationsChangeNotifier;





@property (nonatomic, retain) NSSet* deviceRelations;


@property (readonly) float percentageLive;

@property (readwrite, retain) NSArray * relationsDictionaryRepresentation;


- (void)addDeviceRelationsObject:(NSManagedObject *)value;
- (void)removeDeviceRelationsObject:(NSManagedObject *)value;
- (void)addDeviceRelations:(NSSet *)value;
- (void)removeDeviceRelations:(NSSet *)value;

@end




