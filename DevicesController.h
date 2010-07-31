//
//  DevicesController.h
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define DEVICES 1
#define GROUPS 2
@class CueController;
@interface DevicesController :  NSObject {
	NSMutableArray * devicesSelectedByGroup; //Used to keep track what groups has been selected by a group, and wich are on their own
	
	IBOutlet NSArrayController * devicesArrayController;
	IBOutlet NSArrayController * groupsArrayController;
	
	IBOutlet CueController * cueController;
	IBOutlet NSArrayController * cueArrayController;
	
	BOOL silentClear; //internal usage
}

-(NSArrayController *) devicesArrayController;

@end
