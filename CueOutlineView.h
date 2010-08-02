//
//  CueOutlineView.h
//  LightCue
//
//  Created by Jonas Jongejan on 01/08/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CueController.h"

@interface CueOutlineView : NSOutlineView {
	IBOutlet CueController * cueController;

}

@end
