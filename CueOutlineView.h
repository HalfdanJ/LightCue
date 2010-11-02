//
//  CueOutlineView.h
//  LightCue
//
//  Created by Jonas Jongejan on 01/08/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CueController.h"
#import "ESOutlineView.h"

@interface CueOutlineView : ESOutlineView {
	IBOutlet CueController * cueController;

}

@end
