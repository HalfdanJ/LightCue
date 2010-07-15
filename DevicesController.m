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

-(void) awakeFromNib{
	[devicesArrayController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:@"deviceSelection"];
	[groupsArrayController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:@"groupsSelection"];
	
	[cueArrayController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:@"cueSelection"];
	
	devicesSelectedByGroup = [NSMutableArray array];
	
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
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
		NSArray * selectedCues = [cueArrayController selectedObjects];
	
		if([selectedCues count] == 1 ){
			for(DeviceModel * device in [devicesArrayController arrangedObjects]){
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
				[device  clearDimmer];	
				[device setSelectedCue:nil];
			}	
		
		}
		
		
	}
}
@end
