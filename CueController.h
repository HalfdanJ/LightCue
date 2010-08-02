//
//  CueController.h
//  LightCue
//
//  Created by Jonas Jongejan on 18/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LightCueModel.h"
#import "CueTreeController.h"
#import "CueGroupModel.h"

@interface CueController : NSResponder <NSTableViewDelegate, NSTableViewDataSource, NSOutlineViewDelegate, NSOutlineViewDataSource> {
	IBOutlet CueTreeController * cueTreeController;
	IBOutlet NSPersistentDocument * document;
//	IBOutlet NSTableView * cueTable;
	IBOutlet NSOutlineView * cueOutline;
	IBOutlet NSView * graphView;
	
	NSArray * sortDescriptors;
	//The last cue that has been run
	CueModel * activeCue;
}

@property (retain) CueModel * activeCue;
@property (retain) 	NSArray * sortDescriptors;

- (CueTreeController *) cueTreeController;


- (NSArray*) selectedCues;
- (IBAction)go:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)follow:(id)sender;

- (void) applyPropertiesForCue:(CueModel*)cue;


- (IBAction)addNewItem:(id)sender;
- (IBAction)removeSelectedItems:(id)szender;

- (void)renumberViewPositions;

@end
