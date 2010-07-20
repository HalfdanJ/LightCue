//
//  CueController.h
//  LightCue
//
//  Created by Jonas Jongejan on 18/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CueModel.h"

@interface CueController : NSObject <NSTableViewDelegate, NSTableViewDataSource> {
	IBOutlet NSArrayController * cueArrayController;
	IBOutlet NSPersistentDocument * document;
	NSArray *_sortDescriptors;
	IBOutlet NSTableView * cueTable;
	
	//The last cue that has been run
	CueModel * activeCue;
}

@property (retain) CueModel * activeCue;

- (NSArrayController *) cueArrayController;

- (CueModel*)cueBeforeCue:(CueModel*)cue;
- (CueModel*)cueAfterCue:(CueModel*)cue;

- (NSArray*) selectedCues;
- (IBAction)go:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)follow:(id)sender;

- (void) applyPropertiesForCue:(CueModel*)cue;


- (IBAction)addNewItem:(id)sender;
- (IBAction)removeSelectedItems:(id)szender;
- (NSArray *)sortDescriptors;
- (void)renumberViewPositions;

@end
