//
//  CueTableView.m
//  LightCue
//
//  Created by Jonas Jongejan on 13/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueTableView.h"

@implementation NSColor (alt)

+(NSArray *)controlAlternatingRowBackgroundColors {
	return [NSArray arrayWithObjects:
			[NSColor colorWithDeviceRed:73.0/255.0 green:73.0/255.0 blue:73.0/255.0 alpha:1.0],
			[NSColor colorWithDeviceRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0], nil];
}	

@end


@implementation CueTableView
/*-(void) drawBackgroundInClipRect:(NSRect)clipRect{
	NSRange rows = [self rowsInRect:clipRect];
	NSLog(@"Row %i %i",rows.location,clipRect.size.height);
	
}*/


-(id) copy:sender{
	NSArray *selectedObjects = [[cueController cueTreeController] selectedObjects];
    NSUInteger count = [selectedObjects count];
    if (count == 0) {
        return nil;
    }
	NSLog(@"Copy");


	NSMutableArray *copyObjectsArray = [NSMutableArray arrayWithCapacity:count];
	NSMutableArray *copyStringsArray = [NSMutableArray arrayWithCapacity:count];
	
	for (LightCueModel *cue in selectedObjects) {
		[copyObjectsArray addObject:[cue dictionaryRepresentation]];
		[copyStringsArray addObject:[cue stringDescription]];
	}
	
	NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
	[generalPasteboard declareTypes:
	 [NSArray arrayWithObjects:CuePBoardType, NSStringPboardType, nil]
							  owner:self];
	NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:copyObjectsArray];
	[generalPasteboard setData:copyData forType:CuePBoardType];
	[generalPasteboard setString:[copyStringsArray componentsJoinedByString:@"\n"]
						 forType:NSStringPboardType];
	
	return generalPasteboard;
	
}

- (void)paste:sender {
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    NSData *data = [generalPasteboard dataForType:CuePBoardType];
    if (data == nil) {
        return;
    }
	
    NSManagedObjectContext *moc = [[cueController cueTreeController] managedObjectContext];
//    NSMutableSet *departmentEmployees = [self.department mutableSetValueForKey:@"LightCue"];
    NSArray *cuesArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
    for (NSDictionary *cueDictionary in cuesArray) {
        LightCueModel *newCue;
        newCue = (LightCueModel *)[NSEntityDescription insertNewObjectForEntityForName:@"LightCue"
																inManagedObjectContext:moc];
        [newCue setValuesForKeysWithDictionary:cueDictionary];		
		if([[[cueController cueTreeController]  selectedObjects] count] > 0)
			[newCue setValue:[NSNumber numberWithFloat:[[[[[cueController cueTreeController] selectedObjects]  lastObject] valueForKey:@"lineNumber"] doubleValue]+0.1] forKey:@"lineNumber"];
		else 
			[newCue setValue:[NSNumber numberWithFloat:0] forKey:@"lineNumber"];
		[cueController renumberViewPositions];
//        [departmentEmployees addObject:newEmployee];
    }
	
	NSLog(@"Paste");
}

- (void)cut:sender {
    [self copy:sender];
	NSArray *selectedObjects = [[cueController cueTreeController] selectedObjects];
    if ([selectedObjects count] == 0) {
        return;
    }
//    NSManagedObjectContext *moc = [[cueController cueArrayController] managedObjectContext];
	
    for (LightCueModel *cue in selectedObjects) {
		[[cueController cueTreeController] removeObject:cue];
//        [moc deleteObject:cue];
    }
	
	[cueController renumberViewPositions];

}
@end


