//
//  DevicePropertyModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DeviceModel;
@class CueModel;


@interface DevicePropertyModel : NSManagedObject {
	//For easy binding, simply a link to the selected cue in the cue list
	CueModel * selectedCue;
	
	//The object that modified the outputValue last time
	NSManagedObject * lastModifier;
	
	//The object that currently is modifying the device output value
	NSManagedObject * mutexHolder;
	
	//YES if the device is used in a cue that is currently running
	BOOL isRunning;
}

-(float)floatValue;

//Finds a cueDevicePropertyRelation for the cue if one
- (NSManagedObject*)devicePropertyInCue:(CueModel*)cue;

//Finds the cueDevicePropertyRelation for the cue that edits it
- (NSManagedObject*)devicePropertyModifyingCue:(CueModel*)cue;


//tracks the property backwards from the cue to find the first occurance, and returns the value
- (NSNumber*) valueInCue:(CueModel*)cue;

//Returns if the property is being set in the cue (Blue color)
- (BOOL) propertySetInCue:(CueModel*)cue;

//Returns if the property is being set in the cue, and is currently live  (Yellow color)
- (BOOL) propertyLiveInCue:(CueModel*)cue;


//Clears the value (for deselection)
-(void) clear;
@property (readwrite, retain) CueModel * selectedCue;

@property (readonly, retain) NSNumber* valueInSelectedCue;
@property (readonly) BOOL propertySetInSelectedCue;
@property (readonly) BOOL propertyLiveInSelectedCue;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) DeviceModel * device;

@property (readwrite, retain) NSManagedObject * lastModifier;
@property (readwrite, retain) NSManagedObject * mutexHolder;
@property (readwrite) BOOL isRunning;

@end

