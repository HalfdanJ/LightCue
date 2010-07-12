//
//  MyDocument.m
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright HalfdanJ 2010 . All rights reserved.
//

#import "ShowDocument.h"
#import "DevicePropertyModel.h"
#import "DeviceModel.h"
#import "Helper.h"


@implementation ShowDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

//Prepopulate new document
- (id)initWithType:(NSString *)typeName error:(NSError **)outError{
	self = [super initWithType:typeName error:outError];
    if (self != nil) {
		NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
		[[managedObjectContext undoManager] disableUndoRegistration];
		
		for(int i=1;i<32;i++){
			DeviceModel *device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" 
																	inManagedObjectContext:[self managedObjectContext]];
			[device setValue:[NSNumber numberWithInt:i] forKey:@"deviceNumber"];
			

			
			DevicePropertyModel * prop = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceProperty" 
																	   inManagedObjectContext:[self managedObjectContext]];
			[prop setName:@"DIM"];
			 
			[device addPropertiesObject:prop];
			
		}
		
		for(int i=1;i<32;i++){
			NSManagedObject *group = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceGroup" 
																   inManagedObjectContext:[self managedObjectContext]];
			[group setValue:[NSNumber numberWithInt:i] forKey:@"groupNumber"];
		}
		
		[managedObjectContext processPendingChanges];
		[[managedObjectContext undoManager] enableUndoRegistration];
	}
	return self;
}

- (NSString *)windowNibName 
{
    return @"ShowDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
}

-(void) awakeFromNib{
	NSSortDescriptor *deviceSorter = [[NSSortDescriptor alloc] initWithKey:@"deviceNumber" ascending:YES];
	[devicesArrayController setSortDescriptors:[NSArray arrayWithObject:deviceSorter]];
	
	NSSortDescriptor *groupSorter = [[NSSortDescriptor alloc] initWithKey:@"groupNumber" ascending:YES];
	[groupsArrayController setSortDescriptors:[NSArray arrayWithObject:groupSorter]];	
}


@end
