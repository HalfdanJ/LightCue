//
//  DevicesController.m
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DevicesController.h"

#import "DeviceModel.h"
#import "DeviceGroupModel.h"
#import "DevicePropertyModel.h"

@implementation DevicesController

-(void) startAutoRearranger{
	[devicesArrayController setAutomaticallyRearrangesObjects:YES];	
}

-(void) awakeFromNib{
	[devicesArrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"deviceSelection"];
	[groupsArrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:@"groupsSelection"];
	
	[[cueController cueTreeController] addObserver:self forKeyPath:@"selectedObjects" options:0 context:@"cueSelection"];
	[cueController addObserver:self forKeyPath:@"activeCue" options:0 context:@"activeCue"];

	devicesSelectedByGroup = [NSMutableArray array];
	

	//Performance hack
	[self performSelector:@selector(startAutoRearranger) withObject:nil afterDelay:2.0];
	
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([((NSString*)context) isEqualToString:@"activeCue"]){
		for(DeviceModel * device in [devicesArrayController arrangedObjects]){
			for(DevicePropertyModel* prop in [device properties]){
				[prop setActiveCue:[cueController activeCue]];
			}
		}
	}
	
	if([((NSString*)context) isEqualToString:@"deviceSelection"]){
		
		//Find all the groups that should be selected
		for(DeviceGroupModel *group in [groupsArrayController selectedObjects]){
			BOOL allFound = YES;
			for(DeviceModel * device in [group devices]){
				if(![[devicesArrayController selectedObjects] containsObject:device]){
					allFound = NO;
					break;
				}
			}
			
			if(!allFound){
				if(!silentClear){ 
					//when the groups change, it clears the selection ,before setting it again. 
					//Therefore the first clear has to be silent, so it doenst deselect the newly selected group 
					[groupsArrayController removeSelectedObjects:[NSArray arrayWithObject:group]];
				}
			}
			
		}
	} 
	
	if([((NSString*)context) isEqualToString:@"groupsSelection"]){
		
		if (!([NSEvent modifierFlags] & NSShiftKeyMask)) {
			silentClear = YES;
			[devicesArrayController setSelectionIndexes:[NSIndexSet indexSet]];
			silentClear = NO;
		}
		[devicesSelectedByGroup removeAllObjects];
		
		
		for(DeviceGroupModel * group in [groupsArrayController selectedObjects]){
			//Add the devices that are not alreade selected to devicesSelectedByGroup
			
			for(DeviceModel * device in [group devices]){
				if(![[devicesArrayController selectedObjects] containsObject:device] && ![devicesSelectedByGroup containsObject:device]){
					[devicesSelectedByGroup addObject:device];
				}
			}
		}
		
		[devicesArrayController addSelectedObjects:devicesSelectedByGroup];
		
		
		
	} 
	
	if([((NSString*)context) isEqualToString:@"cueSelection"]){
		[[devicesArrayController managedObjectContext] processPendingChanges];
		[[[devicesArrayController managedObjectContext] undoManager] disableUndoRegistration];

		NSArray * selectedCues = [[cueController cueTreeController] selectedObjects];
	
		if([selectedCues count] == 1 ){
			for(DeviceModel * device in [devicesArrayController arrangedObjects]){
				[device setSelectedCue:[selectedCues lastObject]];
				
				NSManagedObject* cueDeviceProperty = [[device dimmer] devicePropertyInCue:[selectedCues lastObject]];
				if(cueDeviceProperty != nil){
					[[device dimmer]  bind:@"value" toObject:cueDeviceProperty withKeyPath:@"value" options:nil];	
				} else {
					[device clearDimmer];						
				}
				[device setSelectedCue:[selectedCues lastObject]];
			}
			
			
		} else {
			for(DeviceModel * device in [devicesArrayController arrangedObjects]){
				[device setSelectedCue:nil];
				[device  clearDimmer];	
				[device setSelectedCue:nil];
			}	
		
		}
		
		[[devicesArrayController managedObjectContext] processPendingChanges];
		[[[devicesArrayController managedObjectContext] undoManager] enableUndoRegistration];
	}
}

-(NSArrayController *) devicesArrayController{
	return devicesArrayController;
}
@end

