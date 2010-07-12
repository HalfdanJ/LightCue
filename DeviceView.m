//
//  DeviceViewItem.m
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DeviceView.h"

#define VIEW_SIZE 50

//------------------------------------------------------------
//	DeviceView
//------------------------------------------------------------


@implementation DeviceView

@synthesize dimmerValue, deviceName;

-(void) awakeFromNib{
	[self setFrame:NSMakeRect(0, 0, VIEW_SIZE, VIEW_SIZE)];
	deviceNumber = 0;
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
	[theShadow set];
	
	
	NSBezierPath* thePath = [NSBezierPath bezierPath];	
    [thePath appendBezierPathWithRoundedRect:NSMakeRect(3, 3, VIEW_SIZE-6, VIEW_SIZE-6) xRadius:5 yRadius:5];
	[thePath setLineWidth:2.0];
	
	//Fill
	[[[NSColor whiteColor]colorWithAlphaComponent:0.4] set];	
//	NSColor * barColor = [NSColor colorWithDeviceRed:112/255.0 green:121/255.0 blue:131/255.0 alpha:1.0];
//	[barColor set];
	[thePath fill];
	[NSGraphicsContext restoreGraphicsState];
	
	//Stroke
	[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0] set];		
	if(selected){
		//		[[NSColor colorWithCalibratedRed:29/255.0 green:89/255.0 blue:180/255.0 alpha:1.0] set];
		[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] set];	
//		NSColor * barColor = [NSColor colorWithDeviceRed:61.2/255.0 green:144.0/255.0 blue:230.0/255.0 alpha:1.0];
//		[barColor set];
	} else if(mouseOver){
		[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5] set];			
	}
	[thePath stroke];

	
	
	//
	//Device dim
	//
	
	if(dimmerValue != nil){
		NSBezierPath* dimPath = [NSBezierPath bezierPath];	
		[dimPath appendBezierPathWithRoundedRect:NSMakeRect(3, 3, VIEW_SIZE-6, (VIEW_SIZE-6)*[dimmerValue floatValue]/255) xRadius:5 yRadius:5];
		[dimPath setLineWidth:2.0];
		
		//Fill
		[[[NSColor whiteColor]colorWithAlphaComponent:0.4] set];	
//		NSColor * barColor = [NSColor colorWithDeviceRed:112/255.0 green:121/255.0 blue:131/255.0 alpha:1.0];
//		[barColor set];
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

	if(deviceName != nil){
		[[NSString stringWithFormat:@"%@",deviceName] drawAtPoint:NSMakePoint(5, 4) withAttributes:attsDict];
	}

	
	[NSGraphicsContext restoreGraphicsState];
	
}

- (void)setSelected:(BOOL)flag{
	selected = flag;
	[self setNeedsDisplay:YES];
}

- (void)setDeviceNumber:(int)number{
	deviceNumber = number;
	[self setNeedsDisplay:YES];
}

-(void) setDimmerValue:(NSNumber *)v{
	dimmerValue = v ;
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

-(void) setDeviceName:(NSString *)_name{
	deviceName = _name;
	[self setNeedsDisplay:YES];
}


@end



//------------------------------------------------------------
//	DeviceViewItem
//------------------------------------------------------------


@implementation DeviceViewItem

- (void) awakeFromNib {
}

-(void) setRepresentedObject:(id)representedObject{
	if(representedObject == nil)
		return
		[super setRepresentedObject:representedObject];
	
	DeviceView * devview = (DeviceView*)[self view];
	
	[devview bind:@"deviceNumber" toObject:representedObject withKeyPath:@"deviceNumber" options:nil];
	[devview bind:@"dimmerValue" toObject:representedObject withKeyPath:@"dimmer.value" options:nil];
	[devview bind:@"deviceName" toObject:representedObject withKeyPath:@"name" options:nil];

	
}

-(id) copyWithZone:(NSZone *)zone{
	id obj = [super copyWithZone:zone];
	[[obj view] addTrackingRect:[[obj view] bounds] owner:obj userData:nil assumeInside:NO];
	return obj;
}

- (void)setSelected:(BOOL)flag {
	
    [super setSelected: flag];
	[((DeviceView*)[self view]) setSelected:flag];
	
	
	
}


@end
