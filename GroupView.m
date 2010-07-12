//
//  DeviceViewItem.m
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "GroupView.h"

#define VIEW_SIZE 50

//------------------------------------------------------------
//	GroupView
//------------------------------------------------------------


@implementation GroupView

@synthesize numDevices;

-(void) awakeFromNib{
	[self setFrame:NSMakeRect(0, 0, VIEW_SIZE, VIEW_SIZE)];
}



- (void)setFrame:(NSRect)rect
{
	if (trackingRect)
	{
		[self removeTrackingRect:trackingRect];
		trackingRect = [self addTrackingRect:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height) owner:self userData:nil assumeInside:NO];
	}
	else
	{
		trackingRect = [self addTrackingRect:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height) owner:self userData:nil assumeInside:YES];
	}
	
	[super setFrame:rect];
}

-(void) drawRect:(NSRect)dirtyRect{
	//
	//Boundry 
	//
	[NSGraphicsContext saveGraphicsState];
	
	
	
	NSShadow* theShadow = [[NSShadow alloc] init];
	[theShadow setShadowOffset:NSMakeSize(1.0, -1.0)];
	[theShadow setShadowBlurRadius:3.0];	
	[theShadow setShadowColor:[[NSColor blackColor]
							   colorWithAlphaComponent:0.9]];	
	if(numDevices > 0){
		[theShadow set];
	}	
	
	NSBezierPath* thePath = [NSBezierPath bezierPath];	
    [thePath appendBezierPathWithRoundedRect:NSMakeRect(3, 3, VIEW_SIZE-6, VIEW_SIZE-6) xRadius:5 yRadius:5];
	[thePath setLineWidth:2.0];
	
	//Fill
	if(numDevices > 0){
		[[[NSColor whiteColor]colorWithAlphaComponent:0.4] set];	
	}
	if(numDevices == 0){
		[[[NSColor whiteColor]colorWithAlphaComponent:0.1] set];			
	}
	[thePath fill];
	[NSGraphicsContext restoreGraphicsState];
	
	
	//Stroke
	[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0] set];		
	if(editHighlight){
		[[NSColor colorWithCalibratedRed:200/255.0 green:170/255.0 blue:10/255.0 alpha:1.0] set];			
	} else if(selected && numDevices > 0){
		//		[[NSColor colorWithCalibratedRed:29/255.0 green:89/255.0 blue:180/255.0 alpha:1.0] set];
		[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] set];		
	} else if(mouseOver && numDevices > 0){
		[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5] set];			
	}  
	[thePath stroke];
	
	
	
	//Counter
	NSBezierPath* counterPath = [NSBezierPath bezierPath];	
	int x = 0;
	int y = 0;
	for(int i=0;i<numDevices;i++){
		[counterPath appendBezierPathWithRoundedRect:NSMakeRect(x+6, y+6, 3, 3) xRadius:1 yRadius:1];
		x += 7;
		if(x > VIEW_SIZE-12){
			x = 0;
			y += 7;
		}
	}
	[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4] set];		

	[counterPath fill];

	
	
	/*
	 //
	 //Device dim
	 //
	 if(dimmerValue != nil){
	 NSBezierPath* dimPath = [NSBezierPath bezierPath];	
	 [dimPath appendBezierPathWithRoundedRect:NSMakeRect(3, 3, VIEW_SIZE-6, (VIEW_SIZE-6)*[dimmerValue floatValue]) xRadius:5 yRadius:5];
	 [dimPath setLineWidth:2.0];
	 
	 //Fill
	 [[[NSColor whiteColor]colorWithAlphaComponent:0.4] set];	
	 [dimPath fill];
	 }
	 
	 
	 //
	 //Device number
	 //
	 [NSGraphicsContext saveGraphicsState];
	 
	 
	 NSFont * myFont = [NSFont fontWithName:@"Geneva" size:9];
	 
	 NSDictionary * attsDict = [NSDictionary dictionaryWithObjectsAndKeys:
	 [NSColor whiteColor], NSForegroundColorAttributeName,
	 myFont, NSFontAttributeName,
	 [NSNumber numberWithInt:NSNoUnderlineStyle],
	 NSUnderlineStyleAttributeName,
	 nil ];
	 
	 [theShadow setShadowOffset:NSMakeSize(0.0, 0.0)];
	 [theShadow setShadowColor:[[NSColor blackColor]
	 colorWithAlphaComponent:0.9]];	
	 [theShadow set];
	 
	 [[NSString stringWithFormat:@"%i",deviceNumber] drawAtPoint:NSMakePoint(5, VIEW_SIZE-17) withAttributes:attsDict];
	 
	 [NSGraphicsContext restoreGraphicsState];
	 
	 */
	
}

- (void)setSelected:(BOOL)flag{
	if(numDevices == 0){
		flag = NO;
	}
	selected = flag;
	
	[self setNeedsDisplay:YES];
}

- (void)setEditHighlight:(BOOL)flag{
	editHighlight = flag;
	[self setNeedsDisplay:YES];
}

-(void) setNumDevices:(int)i{		
	numDevices = i;
	[self setNeedsDisplay:YES];	
}

-(void) mouseEntered:(NSEvent *)theEvent{
	mouseOver = YES;
	[self setNeedsDisplay:YES];
}

-(void) mouseExited:(NSEvent *)theEvent{
	mouseOver = NO;
	[self setNeedsDisplay:YES];
	
}


@end



//------------------------------------------------------------
//	GroupViewItem
//------------------------------------------------------------


@implementation GroupViewItem

- (void) awakeFromNib {
}

-(void) setRepresentedObject:(id)representedObject{
	if(representedObject == nil)
		return
		[super setRepresentedObject:representedObject];
	
	GroupView * grview = (GroupView*)[self view];
	
	[grview bind:@"numDevices" toObject:representedObject withKeyPath:@"devices.@count" options:nil];
	
	
}

-(id) copyWithZone:(NSZone *)zone{
	id obj = [super copyWithZone:zone];
	[[obj view] addTrackingRect:[[obj view] bounds] owner:obj userData:nil assumeInside:NO];
	
	return obj;
	
	
	
}

- (void)setSelected:(BOOL)flag {
	/*	if([[[self representedObject] devices] count] == 0){
	 flag = NO;
	 }*/
    [super setSelected: flag];
	[((GroupView*)[self view]) setSelected:flag];
	
}


@end
