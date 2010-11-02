//
//  CueTableTextCell.m
//  LightCue
//
//  Created by Jonas Jongejan on 17/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueTableTextCell.h"


@implementation CueTableTextCell
/*
-(void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	if(followBoxSegment > 0){
		NSRect drawSquare = cellFrame;
		NSRect square = cellFrame;

		switch (followBoxSegment) {
			case 1:
				drawSquare = NSMakeRect(cellFrame.origin.x+5, cellFrame.origin.y, cellFrame.size.width-5, cellFrame.size.height);
				square = NSMakeRect(cellFrame.origin.x+0.5, cellFrame.origin.y+0.5, cellFrame.size.width-1, cellFrame.size.height+10);
				break;
			case 2:
				drawSquare = NSMakeRect(cellFrame.origin.x+5, cellFrame.origin.y, cellFrame.size.width-5, cellFrame.size.height);
				square = NSMakeRect(cellFrame.origin.x+0.5, cellFrame.origin.y+0.5-5, cellFrame.size.width-1, cellFrame.size.height+10);
				break;
			case 3:
				drawSquare = NSMakeRect(cellFrame.origin.x+5, cellFrame.origin.y, cellFrame.size.width-5, cellFrame.size.height);
				square = NSMakeRect(cellFrame.origin.x+0.5, cellFrame.origin.y+0.5-10, cellFrame.size.width-1, cellFrame.size.height+10);
				break;
			default:
				break;
		}
		
		[super drawWithFrame:drawSquare inView:controlView];
		
		[NSGraphicsContext saveGraphicsState];
		
		NSBezierPath* clipPath = [NSBezierPath bezierPath];	
		NSRect clipSquare = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y-1, cellFrame.size.width, cellFrame.size.height+2);
		[clipPath appendBezierPathWithRoundedRect:clipSquare xRadius:0 yRadius:0];
		[clipPath setClip];
		
		NSBezierPath* dimPath = [NSBezierPath bezierPath];	
		
		
		
		[dimPath appendBezierPathWithRoundedRect:square xRadius:5 yRadius:5];
		[dimPath setLineWidth:1.5];
		
		//Stroke
		[[[NSColor whiteColor]colorWithAlphaComponent:1.0] set];	
		[dimPath stroke];
		[NSGraphicsContext restoreGraphicsState];
	} else {
		[super drawWithFrame:cellFrame inView:controlView];
	}
	
}
*/
@end
