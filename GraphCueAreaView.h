//
//  GraphCueAreaView.h
//  LightCue
//
//  Created by Jonas Jongejan on 26/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CueController.h"

@interface GraphCueAreaView : NSView {
	NSColor * backgroundColor;
	NSColor * activeBackgroundColor;
	
	CueController * cueController;

	
	BOOL active;
	BOOL running;
		
	NSDictionary * drawDict;
	NSDictionary * drawSettingsDict;
	
	double timeScale;
	
	double lastRunningTimeCache;

}

@property (retain) NSDictionary * drawDict;
@property (retain) NSDictionary * drawSettingsDict;

- (void) setCueController:(CueController *) cueController;


@end
