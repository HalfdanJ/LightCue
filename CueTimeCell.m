//
//  CueTimeCell.m
//  LightCue
//
//  Created by Jonas Jongejan on 08/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueTimeCell.h"


@implementation CueTimeCell

@synthesize running, runningTime, totalTime;
@synthesize hidden;


//-(void) setObjectValue:(id)obj{		
//	NSLog(@"Set obj value %@",obj);
//	if ([obj isKindOfClass:[NSManagedObject class]]) {
//		[self setRepresentedObject:obj];
//	//	[super setObjectValue:[obj valueForKey:@"preWait"]];
//	}
//}
//
//
//
//-(id) initTextCell:(NSString *)aString{
//	NSLog(@"init %@",aString);
//}
//
//
//- (id)copyWithZone:(NSZone *)zone {
//	NSLog(@"copyWithZone");
//
//    CueTimeCell *newCell = [super copyWithZone:zone];
//    [newCell setRepresentedObject:[self representedObject]];
//    return newCell;
//}
//
//-(void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
//	
//}


-(void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	if(!hidden){
		
		[super drawWithFrame:cellFrame inView:controlView];
		
		if([self running]){
			
			NSBezierPath* thePath = [NSBezierPath bezierPath];	
			NSRect frameRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+1, cellFrame.size.width, cellFrame.size.height-4);
			[thePath appendBezierPathWithRect:frameRect];
			
			[thePath setLineWidth:1];
			
			[[NSColor greenColor] set];	
			[thePath stroke];
			
			if([[self objectValue] doubleValue] > 0){
				NSBezierPath* thePath2 = [NSBezierPath bezierPath];	
				NSRect frameRect2 = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+1, cellFrame.size.width*(1-(totalTime-runningTime)/totalTime), cellFrame.size.height-4);
				[thePath2 appendBezierPathWithRect:frameRect2];
				
				
				//Fill
				[[[NSColor greenColor] colorWithAlphaComponent:00.4] set];	
				
				[thePath2 fill];
				
			}
		}
	}
}
@end
