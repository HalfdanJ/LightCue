//
//  CueController.m
//  LightCue
//
//  Created by Jonas Jongejan on 18/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueController.h"
#include "CueTimeCell.h"
#include "CueModel.h"

NSString *DemoItemsDropType = @"CueDropType";


int temporaryLinePosition = -1;
int startLinePosition = -2;
int endLinePosition = -3;

#define temporaryLinePositionNum [NSNumber numberWithInt:temporaryLinePosition]
#define startLinePositionNum [NSNumber numberWithInt:startLinePosition]
#define endLinePositionNum [NSNumber numberWithInt:endLinePosition]

CueController * cueController;

@implementation CueController
-(void) awakeFromNib{
	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"lineNumber" ascending:YES];
	[cueTable setSortDescriptors:[NSArray arrayWithObject:sd]];
	
	[cueTable setDataSource:self];
	[cueTable registerForDraggedTypes:[NSArray arrayWithObjects:DemoItemsDropType, nil]];
	cueController = self;
	
}

- (NSArray*) selectedCues{
	return [cueArrayController selectedObjects];
}


- (IBAction)addNewItem:(id)sender
{
	NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Cue" inManagedObjectContext:[document managedObjectContext]];
	[newItem setValue:@"" forKey:@"name"];
	[newItem setValue:[NSNumber numberWithFloat:[[cueArrayController selectionIndexes] firstIndex]+0.1		] forKey:@"lineNumber"];
	
	[self renumberViewPositions];
	
}

- (IBAction)removeSelectedItems:(id)sender
{
	NSArray *selectedItems = [cueArrayController selectedObjects];
	
	int count;
	for( count = 0; count < [selectedItems count]; count ++ )
	{
		NSManagedObject *currentObject = [selectedItems objectAtIndex:count];
		[[document managedObjectContext] deleteObject:currentObject];
	}
	
	[self renumberViewPositions];
	
}

- (NSArray *)sortDescriptors
{
	if( _sortDescriptors == nil )
	{
		_sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"lineNumber" ascending:YES]];
	}
	return _sortDescriptors;
}



#pragma mark -
#pragma mark CueReorder Helpers


- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate
{
	NSError *error = nil;
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Cue" inManagedObjectContext:[document managedObjectContext]];
	
	NSArray *arrayOfItems;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDesc];
	[fetchRequest setPredicate:fetchPredicate];
	[fetchRequest setSortDescriptors:[self sortDescriptors]];
	arrayOfItems = [[document managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	return arrayOfItems;
}

- (NSArray *)itemsWithViewPosition:(int)value
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"lineNumber == %i", value];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithNonTemporaryViewPosition
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"lineNumber >= 0"];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithViewPositionGreaterThanOrEqualTo:(int)value
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"lineNumber >= %i", value];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithViewPositionBetween:(int)lowValue and:(int)highValue
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"lineNumber >= %i && lineNumber <= %i", lowValue, highValue];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (int)renumberViewPositionsOfItems:(NSArray *)array startingAt:(int)value
{
	int currentViewPosition = value;
	
	int count = 0;
	
	if( array && ([array count] > 0) )
	{
		for( count = 0; count < [array count]; count++ )
		{
			NSManagedObject *currentObject = [array objectAtIndex:count];
			[currentObject setValue:[NSNumber numberWithInt:currentViewPosition] forKey:@"lineNumber"];
			currentViewPosition++;
		}
	}
	
	return currentViewPosition;
}


#pragma mark reorder
- (void)renumberViewPositions
{
	NSArray *startItems = [self itemsWithViewPosition:startLinePosition];
	
	NSArray *existingItems = [self itemsWithNonTemporaryViewPosition];
	
	NSArray *endItems = [self itemsWithViewPosition:endLinePosition];
	
	int currentViewPosition = 0;
	
	if( startItems && ([startItems count] > 0) )
		currentViewPosition = [self renumberViewPositionsOfItems:startItems startingAt:currentViewPosition];
	
	if( existingItems && ([existingItems count] > 0) )
		currentViewPosition = [self renumberViewPositionsOfItems:existingItems startingAt:currentViewPosition];
	
	if( endItems && ([endItems count] > 0) )
		[self renumberViewPositionsOfItems:endItems startingAt:currentViewPosition];
}


#pragma mark TableController
-(CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
	return 20;	
}
-(void) tableView:(NSTableView *)tableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row{
	if([[aTableColumn identifier] isEqualToString:@"image"]){
		
	} else {
		if ([[aTableColumn identifier] isEqualToString:@"preWait"] || [[aTableColumn identifier] isEqualToString:@"postWait"] || [[aTableColumn identifier] isEqualToString:@"fadeTime"] || [[aTableColumn identifier] isEqualToString:@"fadeDownTime"]) {
			
//			if([[aTableColumn identifier] isEqualToString:@"preWait"])
			{
				CueModel * cue = [[cueArrayController arrangedObjects] objectAtIndex:row];
				[aCell setRunning:([[cue valueForKey:[NSString stringWithFormat:@"%@RunningTime",[aTableColumn identifier]]] doubleValue] > 0)?YES:NO];
				[aCell setRunningTime:[[cue valueForKey:[NSString stringWithFormat:@"%@RunningTime",[aTableColumn identifier]]] doubleValue]];
				[aCell setTotalTime:[[cue valueForKey:[aTableColumn identifier]] doubleValue]];
			}
			
			if ([[aCell objectValue] floatValue] > 0) { // if it is YES
				[aCell setTextColor:[NSColor whiteColor]];			
			} else {
				[aCell setTextColor:[[NSColor whiteColor] colorWithAlphaComponent:0.6]];
			}
		} else {
			[aCell setTextColor:[NSColor whiteColor]];
		}
		
		if([aCell isHighlighted]){
			[aCell setTextColor:[NSColor blackColor]];	
		}
	}
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pasteboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pasteboard declareTypes:[NSArray arrayWithObject:DemoItemsDropType] owner:self];
	[pasteboard setData:data forType:DemoItemsDropType];
	return YES;
}

-(NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	if( [info draggingSource] == cueTable )
	{
		if( operation == NSTableViewDropOn )
			[tv setDropRow:row dropOperation:NSTableViewDropAbove];
		
		return NSDragOperationMove;
	}
	else
	{
		return NSDragOperationNone;
	}
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSData *rowData = [pasteboard dataForType:DemoItemsDropType];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	
	NSArray *allItemsArray = [cueArrayController arrangedObjects];
	NSMutableArray *draggedItemsArray = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	
	NSUInteger currentItemIndex;
	NSRange range = NSMakeRange( 0, [rowIndexes lastIndex] + 1 );
	while([rowIndexes getIndexes:&currentItemIndex maxCount:1 inIndexRange:&range] > 0)
	{
		NSManagedObject *thisItem = [allItemsArray objectAtIndex:currentItemIndex];
		
		[draggedItemsArray addObject:thisItem];
	}
	
	int count;
	for( count = 0; count < [draggedItemsArray count]; count++ )
	{
		NSManagedObject *currentItemToMove = [draggedItemsArray objectAtIndex:count];
		[currentItemToMove setValue:[NSNumber numberWithInt:-1] forKey:@"lineNumber"];
	}
	
	int tempRow;
	if( row == 0 )
		tempRow = -1;
	else
		tempRow = row;
	
	NSArray *startItemsArray = [self itemsWithViewPositionBetween:0 and:tempRow-1];
	NSArray *endItemsArray = [self itemsWithViewPositionGreaterThanOrEqualTo:row];
	
	/*NSLog(@"\n before 0-%i  >= %i",tempRow,row);
	 for(NSManagedObject * cue in startItemsArray){
	 NSLog(@"Start item: %@, %@",[cue valueForKey:@"name"],[cue valueForKey:@"lineNumber"]);
	 }
	 for(NSManagedObject * cue in endItemsArray){
	 NSLog(@"End item: %@, %@",[cue valueForKey:@"name"],[cue valueForKey:@"lineNumber"]);
	 }
	 
	 for(NSManagedObject * cue in draggedItemsArray){
	 NSLog(@"Drag item: %@, %@",[cue valueForKey:@"name"],[cue valueForKey:@"lineNumber"]);
	 }
	 */
	
	int currentViewPosition;
	
	currentViewPosition = [self renumberViewPositionsOfItems:startItemsArray startingAt:0];
	
	currentViewPosition = [self renumberViewPositionsOfItems:draggedItemsArray startingAt:currentViewPosition];
	
	/*currentViewPosition = */ [self renumberViewPositionsOfItems:endItemsArray startingAt:currentViewPosition];
	
	/*NSLog(@"\n after");
	 for(NSManagedObject * cue in startItemsArray){
	 NSLog(@"Start item: %@, %@",[cue valueForKey:@"name"],[cue valueForKey:@"lineNumber"]);
	 }
	 for(NSManagedObject * cue in endItemsArray){
	 NSLog(@"End item: %@, %@",[cue valueForKey:@"name"],[cue valueForKey:@"lineNumber"]);
	 }
	 
	 for(NSManagedObject * cue in draggedItemsArray){
	 NSLog(@"Drag item: %@, %@",[cue valueForKey:@"name"],[cue valueForKey:@"lineNumber"]);
	 }
	 */
	
	
	return YES;
}

@end