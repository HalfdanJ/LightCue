//
//  GroupView.h
//
//  Created by Jonas Jongejan on 10/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GroupView : NSView
{
	BOOL selected;	
	BOOL mouseOver;
	BOOL editHighlight;

	NSTrackingRectTag trackingRect;
	
	int numDevices;
	
}

@property (readwrite) int numDevices;

- (void)setSelected:(BOOL)flag;
- (void)setEditHighlight:(BOOL)flag;

@end


@interface GroupViewItem : NSCollectionViewItem {
	IBOutlet NSArrayController * groupsArrayController;
}


@end
