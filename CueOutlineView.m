//
//  CueOutlineView.m
//  LightCue
//
//  Created by Jonas Jongejan on 01/08/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueOutlineView.h"


@implementation CueOutlineView

- (void)reloadData;
{
	[super reloadData];
	NSUInteger row;
	for (row = 0 ; row < [self numberOfRows] ; row++) {
		NSTreeNode *item = [self itemAtRow:row];
		if (![item isLeaf] && [[[item representedObject] valueForKey:@"isExpanded"] boolValue])
			[self expandItem:item];
	}
}
@end
