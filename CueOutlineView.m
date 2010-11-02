//
//  CueOutlineView.m
//  LightCue
//
//  Created by Jonas Jongejan on 01/08/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueOutlineView.h"


@implementation NSColor (alt)

+(NSArray *)controlAlternatingRowBackgroundColors {
	return [NSArray arrayWithObjects:
			[NSColor colorWithDeviceRed:73.0/255.0 green:73.0/255.0 blue:73.0/255.0 alpha:1.0],
			[NSColor colorWithDeviceRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0], nil];
}	

@end


@implementation CueOutlineView

-(NSUInteger)rowsForItem:(id)item{
	NSUInteger res = 1;
	int i = [self rowForItem:item];
	int indention = [self levelForItem:item];
	for(int row=i+1;row<[self numberOfRows];row++){
		if (indention >= [self levelForRow:row]) { 
			break;
		}
		res ++;
	}
	
	return res;
}


-(void) drawRect:(NSRect)dirtyRect{
	[super drawRect:dirtyRect];
	
		
	for(int row=0;row<[self numberOfRows];row++){
		NSTreeNode * node = [self itemAtRow:row];
		if(![node isLeaf]){
			NSRect cellFrame = [self frameOfCellAtColumn:3 row:row];
			cellFrame.size.height += 2;
			if([self isItemExpanded:node]){
				cellFrame.size.height *= [self rowsForItem:node];
			}
			cellFrame.origin.x -= 17.5;
			cellFrame.size.width += 17;
			cellFrame.origin.y += 0.5;
			
			[NSGraphicsContext saveGraphicsState];
			
			NSBezierPath* groupPath = [NSBezierPath bezierPath];			
			[groupPath appendBezierPathWithRoundedRect:cellFrame xRadius:5 yRadius:5];
			[groupPath setLineWidth:1.5];		
			[[[NSColor whiteColor]colorWithAlphaComponent:1.0] set];	
			[groupPath stroke];
			
			[NSGraphicsContext restoreGraphicsState];
		}
		
		
		/*
		 BOOL previousHasFollow = NO;
		 int lastFollowIndent = 0;
		 BOOL follow = [[[node representedObject] valueForKey:@"follow"] boolValue];
		

		if(follow && (!previousHasFollow || lastFollowIndent != [self levelForRow:row])){
			previousHasFollow = YES;
			lastFollowIndent = 	[self levelForRow:row];
			
			int followsCount = 0;
			for(int i = row+1;i< [self numberOfRows];i++){
				followsCount ++;	

				if([self levelForRow:i] == lastFollowIndent){
					if([[[[self itemAtRow:i] representedObject] valueForKey:@"follow"] boolValue]){
					} else {
						if([self isItemExpanded:[self itemAtRow:i]]){
							followsCount += [self rowsForItem:[self itemAtRow:i]]-1;
						}
						break;	
					}
				}

			}
			
			
			NSRect cellFrame = [self frameOfCellAtColumn:2 row:row];
			cellFrame.size.height+= 2;
			cellFrame.size.height *= followsCount+1;
			
			
			cellFrame.origin.x -= 20.5;
			cellFrame.size.width += 23;
			cellFrame.size.width -= [self levelForRow:row]*6;
			cellFrame.origin.y += 0.5;
			
			[NSGraphicsContext saveGraphicsState];
			
			NSBezierPath* groupPath = [NSBezierPath bezierPath];			
			[groupPath appendBezierPathWithRoundedRect:cellFrame xRadius:5 yRadius:5];
			[groupPath setLineWidth:1.5];		
			[[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0] set];	
			//[groupPath stroke];
			
			[NSGraphicsContext restoreGraphicsState];

			
		} else if(!follow) {
			previousHasFollow = NO;	
		}*/
		
	}
	
}

@end
