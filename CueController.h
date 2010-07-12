//
//  CueController.h
//  LightCue
//
//  Created by Jonas Jongejan on 18/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CueController : NSObject <NSTableViewDelegate, NSTableViewDataSource> {
	IBOutlet NSArrayController * cueArrayController;
	IBOutlet NSPersistentDocument * document;
	NSArray *_sortDescriptors;
	IBOutlet NSTableView * cueTable;
}


- (NSArray*) selectedCues;
- (IBAction)addNewItem:(id)sender;
- (IBAction)removeSelectedItems:(id)sender;
- (NSArray *)sortDescriptors;
- (void)renumberViewPositions;

@end
