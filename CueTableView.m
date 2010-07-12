//
//  CueTableView.m
//  LightCue
//
//  Created by Jonas Jongejan on 13/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueTableView.h"

@implementation NSColor (alt)

+(NSArray *)controlAlternatingRowBackgroundColors {
	return [NSArray arrayWithObjects:
			[NSColor colorWithDeviceRed:73.0/255.0 green:73.0/255.0 blue:73.0/255.0 alpha:1.0],
			[NSColor colorWithDeviceRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0], nil];
}	

@end


@implementation CueTableView
/*-(void) drawBackgroundInClipRect:(NSRect)clipRect{
	NSRange rows = [self rowsInRect:clipRect];
	NSLog(@"Row %i %i",rows.location,clipRect.size.height);
	
}*/
@end
