//
//  CueController.m
//  LightCue
//
//  Created by Jonas Jongejan on 18/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueController.h"
#include "CueTimeCell.h"
#include "LightCueModel.h"
#import "DevicePropertyModel.h"
#import "CueDeviceRelationModel.h"
#import "CueTableTextCell.h"

#import "PasteboardTypes.h"


#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"


#import "NSTreeController-DMExtensions.h"


int temporaryLinePosition = -1;
int startLinePosition = -2;
int endLinePosition = -3;

#define temporaryLinePositionNum [NSNumber numberWithInt:temporaryLinePosition]
#define startLinePositionNum [NSNumber numberWithInt:startLinePosition]
#define endLinePositionNum [NSNumber numberWithInt:endLinePosition]

#pragma mark Categories

@implementation NSManagedObjectContext (FetchedObjectFromURI)
- (NSManagedObject *)objectWithURI:(NSURL *)uri
{
    NSManagedObjectID *objectID =
	[[self persistentStoreCoordinator]
	 managedObjectIDForURIRepresentation:uri];
    
    if (!objectID)
    {
        return nil;
    }
    
    NSManagedObject *objectForID = [self objectWithID:objectID];
    if (![objectForID isFault])
    {
        return objectForID;
    }
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[objectID entity]];
    
    // Equivalent to
    // predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate =
	[NSComparisonPredicate
	 predicateWithLeftExpression:
	 [NSExpression expressionForEvaluatedObject]
	 rightExpression:
	 [NSExpression expressionForConstantValue:objectForID]
	 modifier:NSDirectPredicateModifier
	 type:NSEqualToPredicateOperatorType
	 options:0];
    [request setPredicate:predicate];
	
    NSArray *results = [self executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return [results objectAtIndex:0];
    }
    return nil;
}
@end


@implementation CueController
@synthesize activeCue, sortDescriptors;

#pragma mark Init
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"arrangedObjects.follow"]){
		[cueOutline setNeedsDisplay:YES];
	}
}
-(void) awakeFromNib{
	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"lineNumber" ascending:YES];
	[self setSortDescriptors:[NSArray arrayWithObject:sd]];
	
	//[cueOutline setSortDescriptors:[NSArray arrayWithObject:sd]];
	
	[self setNextResponder:[cueOutline nextResponder]];
	
	[cueOutline setDataSource:self];
	[cueOutline  setNextResponder:self];	
	[cueOutline registerForDraggedTypes:[NSArray arrayWithObjects:CueDropType, nil]];
	
	[cueTreeController addObserver:self forKeyPath:@"arrangedObjects.follow" options:nil context:nil];
	
	
	[graphView bind:@"cueSelection" toObject:cueTreeController withKeyPath:@"selectedObjects" options:nil]; 
	
	[NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyDownMask) handler:^(NSEvent *incomingEvent) {
        NSEvent *result = incomingEvent;
		//		NSLog(@"Events: %@",incomingEvent);
		//Escape
		if([incomingEvent keyCode] == 53){
			[self stop:self];
		}
		return result;
		
	}];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:cueTreeController
											 selector:@selector(rearrangeObjects)
												 name:NSUndoManagerDidUndoChangeNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:cueTreeController
											 selector:@selector(rearrangeObjects)
												 name:NSUndoManagerDidRedoChangeNotification
											   object:nil];
	
}

#pragma mark Actions

-(void) keyDown:(NSEvent *)theEvent{
	if([[theEvent characters] isEqualToString:@"f"]){
		[self follow:self];
	}
}

- (IBAction)go:(id)sender{
	CueModel * selectedCue = [[self selectedCues] lastObject];
	
	[self applyPropertiesForCue:[selectedCue previousCue]];
	
	[selectedCue go];
	
	while(selectedCue != nil && [selectedCue follow] ){
		selectedCue = [selectedCue nextRunCue];
	}
	
	
	[cueTreeController setSelectedObjects:[NSArray arrayWithObject:[selectedCue nextRunCue]]];
	
	[self setActiveCue:selectedCue ];
}




- (IBAction)stop:(id)sender{
	for(LightCueModel * cue in [cueTreeController arrangedObjects]){
		[cue stop];
	}
	
	[self setActiveCue:nil];
}

- (IBAction)follow:(id)sender{
	BOOL first = YES;
	BOOL set;
	for(LightCueModel*cue in [self selectedCues]){
		if([cue isKindOfClass:[LightCueModel class]]){
			if(first){
				set = ![[cue valueForKey:@"follow"] boolValue];
			} 
			[cue setValue:[NSNumber numberWithBool:set] forKey:@"follow"];		
			first = NO;
		}
	}
}

-(IBAction) groupCues:(id)sender{	
	
	BOOL canDo = YES;
	
	NSMutableArray * selectedCues= [NSMutableArray array];
	
	NSLog(@"Selection: %@",[cueTreeController selectedNodes]);
	int lowestIndent = -1;
	int lowestLineNumber = -1;
	for(NSTreeNode * node in [cueTreeController selectedNodes]){
		if(lowestIndent == -1 || lowestIndent > [[node indexPath] length])
			lowestIndent = [[node indexPath] length];
		if(lowestLineNumber == -1 || lowestLineNumber > [[(CueModel*)[node representedObject] lineNumber] intValue])
			lowestLineNumber = [[(CueModel*)[node representedObject] lineNumber] intValue];
		
	}
	
	//Rule 1: Are all in the selection either in the lowest Indent, or has a parents(parent) in that indent that is also in the selection?
	for(NSTreeNode * node in [cueTreeController selectedNodes]){		
		if([[node indexPath] length] > lowestIndent){
			NSTreeNode * parent = [node parentNode];
			while(parent != nil){
				//				NSLog(@"Nodes %@ parent (%@) %i %@",[[node representedObject] lineNumber],[[parent representedObject] lineNumber], [[cueTreeController selectedNodes] containsObject:parent],parent);
				if(![[cueTreeController selectedNodes] containsObject:parent]){
					canDo = NO; 
					break;
				}
				if([[parent indexPath] length] == lowestIndent){
					[cueTreeController removeSelectionIndexPaths:[NSArray arrayWithObject:[node indexPath]]];
					break;
				}	
				parent = [parent parentNode];
			}
		}
	}
	
	//Rule 2: all must have continious linenumber
	for(NSTreeNode * node in [cueTreeController selectedNodes]){		
		int line = [[(CueModel*)[node representedObject] lineNumber] intValue];
		if(line != lowestLineNumber){
			canDo = NO;
			break;
		}
		lowestLineNumber ++;
	}
	
	if(canDo){
		for(CueModel * cue in [self selectedCues]){
			[selectedCues addObject:cue];	
		}
		double lineNumber  = 0;
		if([[cueTreeController selectedObjects] count] > 0){
			lineNumber = [[[[cueTreeController selectedObjects] objectAtIndex:0] valueForKey:@"lineNumber"] doubleValue];
			[[[cueTreeController selectedObjects] objectAtIndex:0] setLineNumber:[NSNumber numberWithFloat:lineNumber+0.1]];
		}		
		CueModel * parent = (CueModel*)[[[cueTreeController selectedObjects] objectAtIndex:0] parent];
		
		CueGroupModel *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"CueGroup" inManagedObjectContext:[cueTreeController managedObjectContext]];
		[newItem setValue:@"" forKey:@"name"];
		[newItem setParent:parent];
		[newItem setValue:[NSNumber numberWithFloat:lineNumber] forKey:@"lineNumber"];
		
	
		for(CueModel * cue in selectedCues){
			[cue setParent:newItem];
		}
		
		
		
		[self renumberViewPositions];
		
		[cueTreeController setSelectedObjects:selectedCues];
	}
	
}

- (IBAction)addNewItem:(id)sender
{
	LightCueModel *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"LightCue" inManagedObjectContext:[cueTreeController managedObjectContext]];
	[newItem setName:@""];
	if([[cueTreeController selectedObjects] count] > 0)
		[newItem setValue:[NSNumber numberWithFloat:[[[[cueTreeController selectedObjects] lastObject] valueForKey:@"lineNumber"] doubleValue]+0.1] forKey:@"lineNumber"];
	else 
		[newItem setValue:[NSNumber numberWithFloat:0] forKey:@"lineNumber"];
	[self renumberViewPositions];
	
}

- (IBAction)removeSelectedItems:(id)sender
{
	for(CueModel * cue in [cueTreeController selectedObjects])
	{
		[[document managedObjectContext] deleteObject:cue];
	}	
	
	[self renumberViewPositions];	
}

#pragma mark Setters 

-(void) applyPropertiesForCue:(LightCueModel *)cue{
	NSManagedObjectContext *moc = [document managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"DeviceProperty" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSError *error;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	[moc processPendingChanges];
	[[moc undoManager] disableUndoRegistration];
	
	for(DevicePropertyModel * prop in array){
		NSNumber * val = [prop valueInCue:cue];
		[prop setValue:val forKey:@"outputValue"];
		
		[prop setLastModifier:[prop devicePropertyModifyingCue:cue]];
		
		
	}
	
	[moc processPendingChanges];
	[[moc undoManager] enableUndoRegistration];
	
	
}


#pragma mark Getters 

- (NSArray*) selectedCues{
	return [cueTreeController selectedObjects];
}


- (CueTreeController *) cueTreeController{
	return cueTreeController;
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
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"lineNumber" ascending:YES]]];
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


- (void)renumberViewPositions
{
	NSLog(@"Renumber");
	/*NSArray *startItems = [self itemsWithViewPosition:startLinePosition];
	 
	 NSArray *existingItems = [self itemsWithNonTemporaryViewPosition];
	 
	 NSArray *endItems = [self itemsWithViewPosition:endLinePosition];
	 
	 int currentViewPosition = 0;
	 
	 if( startItems && ([startItems count] > 0) )
	 currentViewPosition = [self renumberViewPositionsOfItems:startItems startingAt:currentViewPosition];
	 
	 if( existingItems && ([existingItems count] > 0) )
	 currentViewPosition = [self renumberViewPositionsOfItems:existingItems startingAt:currentViewPosition];
	 
	 if( endItems && ([endItems count] > 0) )
	 [self renumberViewPositionsOfItems:endItems startingAt:currentViewPosition];
	 
	 [cueTreeController rearrangeObjects];*/
	
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"parent == nil && lineNumber != -1"];	
	NSArray * cues = [self itemsUsingFetchPredicate:fetchPredicate];
	
	int lineNumber = 0;
	for(CueModel * cue in cues){
		[cue setLineNumber:[NSNumber numberWithInt:lineNumber]];
		lineNumber++;
		for(CueModel * child in [cue childrenFlattened]){
			[child setLineNumber:[NSNumber numberWithInt:lineNumber]];
			lineNumber++;
		}
		
	}	
	
	
}

#pragma mark -
#pragma mark OutlineView Delegates

-(CGFloat) outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
	return 20;	
}

-(BOOL) outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)aTableColumn item:(id)item{
	CueModel * cue = [item representedObject];
	if([[aTableColumn identifier] isEqualToString:@"fadeTime"] || [[aTableColumn identifier] isEqualToString:@"fadeDownTime"]){
		if([cue isKindOfClass:[CueGroupModel class]]){
			return NO;
		}
	}	
	
	return YES;
}

-(void) outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn item:(id)item{
	CueModel * cue = [item representedObject];
	
	if([[aTableColumn identifier] isEqualToString:@"fadeTime"] || [[aTableColumn identifier] isEqualToString:@"fadeDownTime"]){
		if([cue isKindOfClass:[CueGroupModel class]]){
			[aCell setHidden:YES];
		} else {
			[aCell setHidden:NO];	
		}
	}	
	if([[aTableColumn identifier] isEqualToString:@"follow"]){
		int state = 0;
		if([cue follow]){
			state = 1;	
		}
		if([[cue previousRunCue] follow]){
			state += 10;
		}
		[aCell setFollowState: state];
		[aCell setIsGroup:[cue isKindOfClass:[CueGroupModel class]]];
	}
	else if([[aTableColumn identifier] isEqualToString:@"image"]){
		
	} else {
		if ([[aTableColumn identifier] isEqualToString:@"preWait"] || [[aTableColumn identifier] isEqualToString:@"postWait"] || [[aTableColumn identifier] isEqualToString:@"fadeTime"] || [[aTableColumn identifier] isEqualToString:@"fadeDownTime"]) {
			
			//			if([[aTableColumn identifier] isEqualToString:@"preWait"])
			
			{
				[aCell setRunning:([[cue valueForKey:[NSString stringWithFormat:@"%@RunningTime",[aTableColumn identifier]]] doubleValue] > 0)?YES:NO];
				[aCell setRunningTime:[[cue valueForKey:[NSString stringWithFormat:@"%@RunningTime",[aTableColumn identifier]]] doubleValue]];
				[aCell setTotalTime:[[cue valueForKey:[aTableColumn identifier]] doubleValue]];
			}
			
			if( [[aTableColumn identifier] isEqualToString:@"fadeDownTime"]){
				if([[aCell objectValue] floatValue] == [[cue valueForKey:@"fadeTime"] floatValue]){
					[aCell setTextColor:[[NSColor whiteColor] colorWithAlphaComponent:0.6]];
				} else {
					[aCell setTextColor:[NSColor whiteColor]];			
				}
			}
			else if ([[aCell objectValue] floatValue] > 0) { // if it is YES
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
	
	[aCell setBackgroundStyle:NSBackgroundStyleDark];
	
}


-(BOOL) outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
	NSMutableArray * objectsURIs = [NSMutableArray arrayWithCapacity:[items count]];
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[items count]];
	[items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[objects addObject:[obj representedObject]];
		[objectsURIs addObject:[[[obj representedObject] objectID] URIRepresentation]];
	}];
	
	NSMutableArray *copyObjectsArray = [NSMutableArray arrayWithCapacity:[objectsURIs count]];
	NSMutableArray *copyStringsArray = [NSMutableArray arrayWithCapacity:[objectsURIs count]];
	
	for (CueModel *cue in objects) {
		[copyObjectsArray addObject:[cue dictionaryRepresentation]];
		[copyStringsArray addObject:[cue stringDescription]];
	}
	
	[pasteboard declareTypes:[NSArray arrayWithObjects:CueDropType,CueCopyType,NSStringPboardType,nil] owner:self];
	
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:CueDropType];	
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:copyObjectsArray] forType:CueCopyType];
	[pasteboard setString:[copyStringsArray componentsJoinedByString:@"\n"] forType:NSStringPboardType];
	
	
	
	return YES;
	
	
	return YES;
}

-(NSDragOperation) outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index 
{
	if(index == -1 && ([[item representedObject] isKindOfClass:[LightCueModel class]] ||  [info draggingSource] == outlineView))	
		return NSDragOperationNone;
	
	NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:CueDropType]];
	BOOL targetIsValid = YES;
	for (NSIndexPath *indexPath in draggedIndexPaths) {
		NSTreeNode *node = [cueTreeController nodeAtIndexPath:indexPath];
		if (!node.isLeaf) {
			if ([item isDescendantOfNode:node] || item == node) { // can't drop a group on one of its descendants
				return NSDragOperationNone;
			}
		}
	}
	
	
	if( [[info draggingSource] isKindOfClass:[outlineView class]]	)
	{
		/*	if( operation == NSTableViewDropOn )
		 [tv setDropRow:row dropOperation:NSTableViewDropAbove];
		 */	
		if([info draggingSource] == outlineView){
			return NSDragOperationMove;
		} else {
			return NSDragOperationCopy;			
		}
	}
	else
	{
		return NSDragOperationNone;
	}
}


-(BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
	NSLog(@"childIndex: %i item: %@",index,item);
	NSDragOperation operation;
	if([info draggingSource] == outlineView){
		operation = NSDragOperationMove;
	} else {
		operation = NSDragOperationCopy;			
	}
	
	NSPasteboard *pasteboard = [info draggingPasteboard];
	if (operation == NSDragOperationCopy) {
		NSData *data = [pasteboard dataForType:CueCopyType];
		if (data == nil) {
			return NO;
		}
		
		NSManagedObjectContext *moc = [cueTreeController managedObjectContext];
		NSArray *cuesArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
		for (NSDictionary *cueDictionary in cuesArray) {
			LightCueModel *newCue;
			newCue = (LightCueModel *)[NSEntityDescription insertNewObjectForEntityForName:@"LightCue" inManagedObjectContext:moc];
			[newCue setValuesForKeysWithDictionary:cueDictionary];		
			/*	if([[[self cueTreeController]  selectionIndexes] count] > 0)
			 [newCue setValue:[NSNumber numberWithFloat:[[cueTreeController selectionIndexes] firstIndex]+0.1] forKey:@"lineNumber"];
			 else 
			 [newCue setValue:[NSNumber numberWithFloat:0] forKey:@"lineNumber"];*/
			[self renumberViewPositions];
		}
		
	} else if (operation == NSDragOperationMove){		
		NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:CueDropType]];
		
		NSMutableArray *draggedNodes = [NSMutableArray array];
		for (NSIndexPath *indexPath in droppedIndexPaths)
			[draggedNodes addObject:[cueTreeController nodeAtIndexPath:indexPath]];
		
		NSIndexPath *proposedParentIndexPath;
		if (!item)
			proposedParentIndexPath = [[[NSIndexPath alloc] init] autorelease]; // makes a NSIndexPath with length == 0
		else
			proposedParentIndexPath = [item indexPath];
		
		
	//	NSLog(@"Move to indexPath %@, adding %i",proposedParentIndexPath,index);
		[cueTreeController moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:index]];
		//[self renumberViewPositions];
		
		return YES;
		
		
		
		//NSData *rowData = [pasteboard dataForType:CueDropType];
		//		NSArray * uris = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
		//		
		//		//		NSArray *allItemsArray = [cueArrayController arrangedObjects];
		//		NSMutableArray *draggedItemsArray = [NSMutableArray arrayWithCapacity:[uris count]];
		//		
		//		NSUInteger currentItemIndex;
		//		
		//		for(NSURL* uri in uris){
		//			NSManagedObject *thisItem = [[cueTreeController managedObjectContext] objectWithURI:uri];			
		//			[draggedItemsArray addObject:thisItem];
		//		}
		//		
		//		
		//		for(int count = 0; count < [draggedItemsArray count]; count++ )
		//		{
		//			CueModel *currentItemToMove = [draggedItemsArray objectAtIndex:count];
		//			[currentItemToMove setValue:[NSNumber numberWithInt:-1] forKey:@"lineNumber"];
		//			[currentItemToMove setParent:[item representedObject]];
		//		}
		//		
		//		//	[self renumberViewPositions];
		//		
		//		
		//		int lineNumberOfIndex = 0;
		//		if(item != nil){
		//			lineNumberOfIndex += [[[item representedObject] valueForKey:@"lineNumber"] intValue]+1;
		//		}
		//		
		//		NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"parent == %@ && lineNumber != -1",[[item representedObject] parent]];	
		//		NSArray * itemsWithSameParent = [self itemsUsingFetchPredicate:fetchPredicate];
		//		
		//		int i=0;
		//		for(CueModel * cue in itemsWithSameParent){
		//			if(i < index){
		//				lineNumberOfIndex += [[cue valueForKey:@"children"] count]+1;
		//			}
		//			i++;
		//		}
		//		
		//		/*	
		//		 if(lineNumberOfIndex == 0)
		//		 lineNumberOfIndex = -1;
		//		 */
		//		
		//		NSArray *startItemsArray = [self itemsWithViewPositionBetween:0 and:lineNumberOfIndex-1];
		//		NSArray *endItemsArray = [self itemsWithViewPositionGreaterThanOrEqualTo:lineNumberOfIndex];		
		//		
		//		int currentViewPosition = [self renumberViewPositionsOfItems:startItemsArray startingAt:0];	
		//		currentViewPosition = [self renumberViewPositionsOfItems:draggedItemsArray startingAt:currentViewPosition];		
		//		[self renumberViewPositionsOfItems:endItemsArray startingAt:currentViewPosition];
		//		
		//		[cueTreeController rearrangeObjects];
	}
	
	return YES;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification;
{
	
	NSManagedObjectContext *moc = [cueTreeController managedObjectContext];
	
	[moc processPendingChanges];
	[[moc undoManager] disableUndoRegistration];
	
	CueModel *collapsedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	[collapsedItem setValue:[NSNumber numberWithBool:NO] forKey:@"isExpanded"];
	
	[moc processPendingChanges];
	[[moc undoManager] enableUndoRegistration];
	
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification;
{
	
	NSManagedObjectContext *moc = [cueTreeController managedObjectContext];
	
	[moc processPendingChanges];
	[[moc undoManager] disableUndoRegistration];
	
	CueModel *expandedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	[expandedItem setValue:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
	
	[moc processPendingChanges];
	[[moc undoManager] enableUndoRegistration];
	
}
@end
