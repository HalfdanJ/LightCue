//
//  CueTableView.h
//  LightCue
//
//  Created by Jonas Jongejan on 13/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CueController.h"
#import "CueModel.h"

NSString *CuePBoardType = @"CueBoardType";


@interface CueTableView : NSTableView {
	IBOutlet CueController * cueController;
}

@end
