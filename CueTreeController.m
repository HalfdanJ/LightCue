//
//  CueTreeController.m
//  LightCue
//
//  Created by Jonas Jongejan on 01/08/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueTreeController.h"


@implementation CueTreeController

- (NSArray *)rootNodes;
{
	return [[self arrangedObjects] childNodes];
}

// all the NSTreeNodes in the tree, depth-first searching
- (NSArray *)flattenedNodes;
{
	NSMutableArray *mutableArray = [NSMutableArray array];
	for (NSTreeNode *node in [self rootNodes]) {
		[mutableArray addObject:node];
		if (![[node valueForKey:[self leafKeyPath]] boolValue])
			[mutableArray addObjectsFromArray:[node valueForKey:[self childrenKeyPath]]];
	}
	return [[mutableArray copy] autorelease];	
}


- (NSTreeNode *)treeNodeForObject:(id)object;
{
	NSTreeNode *treeNode = nil;
	for (NSTreeNode *node in [self flattenedNodes]) {
		if ([node representedObject] == object) {
			treeNode = node;
			break;
		}
	}
	return treeNode;
}


- (void)setSelectedNode:(NSTreeNode *)node;
{
	[self setSelectionIndexPath:[node indexPath]];
}

- (void)setSelectedObject:(id)object;
{
	[self setSelectedNode:[self treeNodeForObject:object]];
}

- (NSIndexPath *)indexPathToObject:(id)object;
{
	return [[self treeNodeForObject:object] indexPath];
}

@end
