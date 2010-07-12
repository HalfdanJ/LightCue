//
//  GroupsCollectionView.m
//
//  Created by Jonas Jongejan on 10/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "GroupsCollectionView.h"
#import "GroupView.h"
#import "DeviceGroupModel.h"

@implementation NSView (viewAtPointExcludingView)

- (id)viewAtPoint:(NSPoint)pt excludingView:(id)eView {
	for( NSView * view in [self subviews] ) {
		if( view != eView && [self mouse:pt inRect:[view frame]] ) {
			return (view);
		}
	}
	
	return nil;
}


@end






@implementation GroupsCollectionView
- (void)awakeFromNib {
	[self registerForDraggedTypes:[NSArray arrayWithObject:@"DevicesDataType"]];
}

- (id)viewAtPoint:(NSPoint)pt excludingView:(id)eView {
	for( NSView * view in [self subviews] ) {
		if( view != eView && [self mouse:pt inRect:[view frame]] ) {
			return (view);
		}
	}
	
	return nil;
}



- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	NSUInteger destination = [self indexOfPoint:[sender draggedImageLocation]];
	if( destination != NSNotFound ) {
		
		if( [sender draggingSource] != self &&
		   [[[sender draggingPasteboard] types] containsObject:@"DevicesDataType"]) {
			return NSDragOperationCopy | NSDragOperationLink | NSDragOperationGeneric;
		}
	}
	return NO;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
	for(GroupView *groupView  in [self subviews]){
		[groupView setEditHighlight:NO];
		
	};
	
	
	NSUInteger destination = [self indexOfPoint:[sender draggingLocation]];
	if( destination != NSNotFound ) {		
		if( [sender draggingSource] != self &&
		   [[[sender draggingPasteboard] types] containsObject:@"DevicesDataType"]) {
			GroupView * groupView = [[self subviews] objectAtIndex:destination];
			[groupView setEditHighlight:YES];
			
			
			return NSDragOperationCopy;
		}
	}
	return NO;
}

-(void) draggingExited:(id <NSDraggingInfo>)sender{
	for(GroupView *groupView  in [self subviews]){
		[groupView setEditHighlight:NO];
		
	};
	
}


-(void) draggingEnded:(id <NSDraggingInfo>)sender{
	for(GroupView *groupView  in [self subviews]){
		[groupView setEditHighlight:NO];
		
	};
	
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSUInteger destination = [self indexOfPoint:[sender draggingLocation]];
	if( destination != NSNotFound ) {		
		if( [sender draggingSource] != self &&
		   [[[sender draggingPasteboard] types] containsObject:@"DevicesDataType"]) {
//			GroupView * groupView = [[self subviews] objectAtIndex:destination];
			DeviceGroupModel * group = [[self content] objectAtIndex:destination];
			NSArray * dataArray = [[sender draggingPasteboard] propertyListForType:@"DevicesDataType"];
			
			for(NSNumber * index in dataArray){
				[group addDevicesObject:[[devicesArrayController content] objectAtIndex:[index intValue]]];
//				[newGroupDeviceSet addObject:[[devicesArrayController content] objectAtIndex:[index intValue]]];
			}
			
//			[group setDevices:newGroupDeviceSet];
//			[groupsArrayController addSelectedObjects:[NSArray arrayWithObject:group]];
			return YES;	
		}
	}
			
	return NO;

}


- (NSUInteger)indexOfPoint:(NSPoint)aPoint {
	NSView *	target		= [self viewAtPoint:[self convertPoint:aPoint fromView:nil] excludingView:nil];
	NSUInteger	position	= 0;
	
	if( !target ) { // we're over empty space here
		position = NSNotFound;
	} else { // we're on somebody's turf
		position = [[self subviews]  indexOfObject:target];
	}
	
	return position;
}


@end
