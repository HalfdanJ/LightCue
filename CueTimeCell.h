//
//  CueTimeCell.h
//  LightCue
//
//  Created by Jonas Jongejan on 08/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CueTimeCell : NSTextFieldCell {
	BOOL running;
	double runningTime;
	double totalTime;
}
@property (readwrite) BOOL running;
@property (readwrite)double runningTime;
@property (readwrite)double totalTime;

@end
