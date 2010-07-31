//
//  GraphView.h
//
//  Created by Jonas Jongejan on 25/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import "CueModel.h"
#import "CueController.h"
#import "DevicesController.h"
#import "DeviceModel.h"
#import "CueDeviceRelationModel.h"
#import "DevicePropertyModel.h"

#import "GraphCueAreaView.h"

@interface GraphView : NSControl {
	NSMutableDictionary * drawingDict;
	NSMutableArray * timelineEvents;
	NSMutableArray * deviceKeypoints;
	
	float timeScale;

	NSArray * cueSelection;
	double graphStartTime;
	double graphTimePosition;
	
	NSView * areaViewHolder;
	
		
	IBOutlet CueController * cueController;
	IBOutlet DevicesController * devicesController;

/*	
	NSNumber * preWaitValue;
	NSNumber * postWaitValue;
	NSNumber * fadeValue;
	NSNumber * fadeDownValue;
*/	
	
}



@property (retain) NSArray * cueSelection;
@property (readwrite) double graphStartTime;
@property (readwrite) double graphTimePosition;

/*
@property (retain) NSNumber * preWaitValue;
@property (retain) NSNumber * postWaitValue;
@property (retain) NSNumber * fadeValue;
@property (retain) NSNumber * fadeDownValue;
*/
@end
