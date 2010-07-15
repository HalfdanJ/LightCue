//
//  DeviceViewItem.m
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DeviceView.h"

#define VIEW_SIZE 50
#define PADDING 4
//------------------------------------------------------------
//	DeviceView
//------------------------------------------------------------


@implementation DeviceView

@synthesize dimmerValue, dimmerOutputValue, deviceName, selectedCue, inSelectedCue;

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
	
	NSColor * dimColor = [NSColor colorWithDeviceRed:61.2/255.0 green:144.0/255.0 blue:230.0/255.0 alpha:0.5];
	
	[NSGraphicsContext saveGraphicsState];
	
	
	
	NSShadow* theShadow = [[NSShadow alloc] init];
	[theShadow setShadowOffset:NSMakeSize(0.0, 0.0)];
	[theShadow setShadowBlurRadius:15];	
	if(selected){
		[theShadow setShadowColor:[[NSColor whiteColor]
								   colorWithAlphaComponent:1.0]];	
	} else {
		[theShadow setShadowColor:[[NSColor blackColor]
								   colorWithAlphaComponent:0.9]];	
		
	}
	[theShadow set];
	
	
	NSBezierPath* thePath = [NSBezierPath bezierPath];	
    [thePath appendBezierPathWithRoundedRect:NSMakeRect(PADDING, PADDING, VIEW_SIZE-PADDING*2, VIEW_SIZE-PADDING*2) xRadius:5 yRadius:5];
	[thePath setLineWidth:1.5];
	
	//Fill
	[[NSColor colorWithCalibratedWhite:0.2 alpha:1.0] set];	
	//	NSColor * barColor = [NSColor colorWithDeviceRed:112/255.0 green:121/255.0 blue:131/255.0 alpha:1.0];
	//	[barColor set];
	[thePath fill];
	[NSGraphicsContext restoreGraphicsState];
	
	
	
	//
	//Device dim
	//
	
	if(dimmerOutputValue != nil){
		NSBezierPath* dimPath = [NSBezierPath bezierPath];	
		[dimPath appendBezierPathWithRoundedRect:NSMakeRect(PADDING, PADDING, VIEW_SIZE-PADDING*2, (VIEW_SIZE-PADDING*2)*[dimmerOutputValue floatValue]/255) xRadius:5 yRadius:5];
		[dimPath setLineWidth:2.0];
		
		//Fill
		[[[NSColor whiteColor]colorWithAlphaComponent:0.3] set];	
		//		NSColor * barColor = [NSColor colorWithDeviceRed:112/255.0 green:121/255.0 blue:131/255.0 alpha:1.0];
		//		[barColor set];
		[dimPath fill];
	}
	
	
	if(dimmerValue != nil){
		NSBezierPath* dimPath = [NSBezierPath bezierPath];	
		[dimPath appendBezierPathWithRoundedRect:NSMakeRect(PADDING, PADDING, VIEW_SIZE-PADDING*2, (VIEW_SIZE-PADDING*2)*[dimmerValue floatValue]/255) xRadius:5 yRadius:5];
		[dimPath setLineWidth:1.0];
		
		//Stroke
		[[[NSColor whiteColor]colorWithAlphaComponent:0.8] set];	
		//		NSColor * barColor = [NSColor colorWithDeviceRed:112/255.0 green:121/255.0 blue:131/255.0 alpha:1.0];
		//		[barColor set];
		[dimPath stroke];
		
		
		//Fill
		if(inSelectedCue)
			[[dimColor colorWithAlphaComponent:0.7] set];	
		else {
			[[[NSColor whiteColor]colorWithAlphaComponent:0.2] set];	
		}

		[dimPath fill];
	}
	
	
	//Stroke
	NSColor * strokeColor = [NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2];
	float baseAlpha = 0.2;
	float overAlpa = 0.5;
	float selectedAlpha = 0.5;
	
	if(inSelectedCue){
		strokeColor = dimColor;
		baseAlpha = 0.8;
		overAlpa = 0.9;
		selectedAlpha = 1.0;
	}
	[[strokeColor colorWithAlphaComponent:baseAlpha] set];		
	if(selected){
		//		[[NSColor colorWithCalibratedRed:29/255.0 green:89/255.0 blue:180/255.0 alpha:1.0] set];
		
		[[strokeColor colorWithAlphaComponent:selectedAlpha] set];		
		
		//		NSColor * barColor = [NSColor colorWithDeviceRed:61.2/255.0 green:144.0/255.0 blue:230.0/255.0 alpha:1.0];
		//		[barColor set];
	} else if(mouseOver){
		[[strokeColor colorWithAlphaComponent:overAlpa] set];		
 	} 
	[thePath setLineWidth:2.0];
	
	[thePath stroke];
	
	
	//Selection Stroke
	if(selected){
		NSBezierPath* selectionPath = [NSBezierPath bezierPath];	
		[selectionPath appendBezierPathWithRoundedRect:NSMakeRect(PADDING-1, PADDING-1, VIEW_SIZE-(PADDING-1)*2, VIEW_SIZE-(PADDING-1)*2) xRadius:5 yRadius:5];
		[selectionPath setLineWidth:1];
		
		NSColor * strokeColor = [NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
		[strokeColor set];
		[selectionPath stroke];
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


-(void) setDimmerOutputValue:(NSNumber *)v{
	dimmerOutputValue = v ;
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

-(void) setInSelectedCue:(BOOL)b{
	inSelectedCue = b;
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
		return;
	[super setRepresentedObject:representedObject];
	
	DeviceView * devview = (DeviceView*)[self view];
	
	[devview bind:@"deviceNumber" toObject:representedObject withKeyPath:@"deviceNumber" options:nil];
	[devview bind:@"dimmerValue" toObject:representedObject withKeyPath:@"dimmer.valueInSelectedCue" options:nil];
	[devview bind:@"dimmerOutputValue" toObject:representedObject withKeyPath:@"dimmer.outputValue" options:nil];
	[devview bind:@"deviceName" toObject:representedObject withKeyPath:@"name" options:nil];
	[devview bind:@"selectedCue" toObject:representedObject withKeyPath:@"selectedCue" options:nil];
	[devview bind:@"inSelectedCue" toObject:representedObject withKeyPath:@"propertySetInSelectedCue" options:nil];
	
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
