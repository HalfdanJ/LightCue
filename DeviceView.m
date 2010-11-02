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

@synthesize dimmerOutputValue, dimmerValue, deviceName, selectedCue, inSelectedCue, isRunning, isLive, isChanged, dimmerValueInCue;

-(void) awakeFromNib{
	[self setFrame:NSMakeRect(0, 0, VIEW_SIZE, VIEW_SIZE)];
	deviceNumber = 0;
	dimmerOutputValue = [NSNumber numberWithInt:0];
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
	[NSGraphicsContext saveGraphicsState]; 
	
	
	NSColor * dimColor = [NSColor colorWithDeviceRed:56/255.0 green:117/255.0 blue:215/255.0 alpha:0.5];
	NSColor * greenColor = [NSColor colorWithDeviceRed:15/255.0 green:215/255.0 blue:0/255.0 alpha:1];	
	NSColor * orangeColor = [NSColor colorWithDeviceRed:255/255.0 green:210/255.0 blue:0/255.0 alpha:1];
	
	
	[NSGraphicsContext saveGraphicsState]; 
	
	//
	//Boundry Background 
	//
	
	NSShadow* theShadow = [[NSShadow alloc] init];
	[theShadow setShadowOffset:NSMakeSize(0.0, 0.0)];
	[theShadow setShadowBlurRadius:10];	
	if(selected){
		[theShadow setShadowColor:[[NSColor whiteColor] colorWithAlphaComponent:1.0]];	
	} else {
		[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.9]];	
	}
	
	NSBezierPath* boundryPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(PADDING, PADDING, VIEW_SIZE-PADDING*2, VIEW_SIZE-PADDING*2) xRadius:5 yRadius:5];	
	[boundryPath setLineWidth:1.5];	
	
	[NSGraphicsContext saveGraphicsState];{
		[theShadow set];
		
		//Fill
		[[NSColor colorWithCalibratedWhite:0.2 alpha:1.0] set];	
		[boundryPath fill];
		
	}[NSGraphicsContext restoreGraphicsState];
	
	[boundryPath addClip];
	
	
	//
	// cue value background
	//
	
	NSBezierPath* dimBackgroundPath = [NSBezierPath bezierPathWithRect:NSMakeRect(VIEW_SIZE*(2.0/3.0), PADDING, VIEW_SIZE-PADDING*2, (VIEW_SIZE-PADDING*2))];	
	[[NSColor colorWithCalibratedWhite:0.17 alpha:1.0] set];	
	if(inSelectedCue){
		[[dimColor colorWithAlphaComponent:0.2] set];
	}
	[dimBackgroundPath fill];
	
	
	//
	//Device dim
	//
	
	if(dimmerValue != nil){
		float val = [dimmerValue floatValue];
		if(!isChanged){
			[[[NSColor whiteColor] colorWithAlphaComponent:0.3] set];	
			val = [dimmerOutputValue floatValue];

		}  else {
			[[orangeColor colorWithAlphaComponent:0.4] set];
		} 
		if(isRunning){
			[[greenColor colorWithAlphaComponent:0.85] set];				
		}
		
		NSBezierPath* dimPath = [NSBezierPath bezierPathWithRect:NSMakeRect(PADDING, PADDING, VIEW_SIZE*2.0/3.0-PADDING, (VIEW_SIZE-PADDING*2)*val/255)];	
		
		[dimPath fill];
		
		/*if(inSelectedCue){
			[[dimColor colorWithAlphaComponent:0.4] set];
			[dimPath fill];			
		}*/		
	}
	
	
	//
	//Device cue dim
	//
	
	if(dimmerValueInCue != nil){		
		NSBezierPath* dimPath = [NSBezierPath bezierPathWithRect:NSMakeRect(VIEW_SIZE*(2.0/3.0), PADDING, VIEW_SIZE-PADDING*2, (VIEW_SIZE-PADDING*2)*[dimmerValueInCue floatValue]/255)];	
		if(inSelectedCue){
			[[dimColor colorWithAlphaComponent:0.65] set];
		}
		/*else if(isLive){
			[[orangeColor colorWithAlphaComponent:0.65] set];					
		}*/ else {
			[[NSColor colorWithCalibratedWhite:0.3 alpha:1.0]set];	
		}		
		[dimPath fill];
	}
	
	//
	// Device dim and output value seperator
	//
	
	
	{
		NSBezierPath* dimSeperatorPath = [NSBezierPath bezierPath];	
		[dimSeperatorPath moveToPoint:NSMakePoint(VIEW_SIZE*(2.0/3.0), 0.0)];
		[dimSeperatorPath lineToPoint:NSMakePoint(VIEW_SIZE*(2.0/3.0), (VIEW_SIZE))];
		
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];	
		[dimSeperatorPath stroke];
	}
	
	[NSGraphicsContext restoreGraphicsState];
	
	
	//Boundry Stroke
	NSColor * strokeColor = [NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2];
	float baseAlpha = 0.2;
	float overAlpa = 0.5;
	float selectedAlpha = 0.5;
	[boundryPath setLineWidth:2.0];
	
	/*	if(isRunning){
	 strokeColor = greenColor;
	 baseAlpha = 0.8;
	 overAlpa = 0.9;
	 selectedAlpha = 1.0;
	 }*/
	/*	else if(isLive){
	 strokeColor = orangeColor;
	 baseAlpha = 0.8;
	 overAlpa = 0.9;
	 selectedAlpha = 1.0;
	 
	 }
	 else*/ 
	/*if(inSelectedCue){
		strokeColor = dimColor;
		baseAlpha = 0.8;
		overAlpa = 1.0;
		selectedAlpha = 1.0;
		[boundryPath setLineWidth:3.0];		 
	}*/
	
	if(isChanged){
		strokeColor = orangeColor;
		baseAlpha = 0.6;
		overAlpa = 1.0;
		selectedAlpha = 1.0;
		[boundryPath setLineWidth:2.0];		 
	}
	
	[[strokeColor colorWithAlphaComponent:baseAlpha] set];		
	if(selected){
		[[strokeColor colorWithAlphaComponent:selectedAlpha] set];		
	} else if(mouseOver){
		[[strokeColor colorWithAlphaComponent:overAlpa] set];		
 	} 
	
	[boundryPath stroke];	
	
	
	//
	//Device number
	//
	
	[NSGraphicsContext saveGraphicsState];{		
		NSFont * myFont = [NSFont fontWithName:@"Geneva" size:9];
		
		NSDictionary * attsDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSColor whiteColor], NSForegroundColorAttributeName,
								   myFont, NSFontAttributeName,
								   [NSNumber numberWithInt:NSNoUnderlineStyle],
								   NSUnderlineStyleAttributeName,
								   nil ];
		
		[theShadow setShadowOffset:NSMakeSize(0.0, 0.0)];
		[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.9]];	
		[theShadow set];
		
		[[NSString stringWithFormat:@"%i",deviceNumber] drawAtPoint:NSMakePoint(5, VIEW_SIZE-17) withAttributes:attsDict];
		
		if(deviceName != nil){
			[[NSString stringWithFormat:@"%@",deviceName] drawAtPoint:NSMakePoint(5, 4) withAttributes:attsDict];
		}
		
	}[NSGraphicsContext restoreGraphicsState];
	
	//
	//Selection Stroke
	//
	
	if(selected){
		NSBezierPath* selectionPath = [NSBezierPath bezierPath];	
		[selectionPath appendBezierPathWithRoundedRect:NSMakeRect(PADDING-1, PADDING-1, VIEW_SIZE-(PADDING-1)*2, VIEW_SIZE-(PADDING-1)*2) xRadius:5 yRadius:5];
		[selectionPath setLineWidth:1];
		
		[[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] set];
		[selectionPath stroke];
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

-(void) setDimmerValueInCue:(NSNumber *)v{
	dimmerValueInCue = v;
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

-(void) setIsRunning:(BOOL)b{
	isRunning = b;
	[self setNeedsDisplay:YES];	
}
-(void) setIsLive:(BOOL)b{
	isLive = b;
	[self setNeedsDisplay:YES];	
}

-(void) setIsChanged:(BOOL)b{
	isChanged = b;
	[self setNeedsDisplay:YES];
}

@end



//------------------------------------------------------------
//	DeviceViewItem
//------------------------------------------------------------


@implementation DeviceViewItem

-(void) setRepresentedObject:(id)representedObject{
	if(representedObject == nil)
		return;
	[super setRepresentedObject:representedObject];
	
	DeviceView * devview = (DeviceView*)[self view];
		
	[devview bind:@"deviceNumber" toObject:representedObject withKeyPath:@"deviceNumber" options:nil];
	[devview bind:@"dimmerValue" toObject:representedObject withKeyPath:@"dimmer.value" options:nil];
	[devview bind:@"dimmerValueInCue" toObject:representedObject withKeyPath:@"dimmer.valueInSelectedCue" options:nil];
	[devview bind:@"dimmerOutputValue" toObject:representedObject withKeyPath:@"dimmer.outputValue" options:nil];
	[devview bind:@"deviceName" toObject:representedObject withKeyPath:@"name" options:nil];
	[devview bind:@"selectedCue" toObject:representedObject withKeyPath:@"selectedCue" options:nil];
	[devview bind:@"inSelectedCue" toObject:representedObject withKeyPath:@"propertySetInSelectedCue" options:nil];
	[devview bind:@"isRunning" toObject:representedObject withKeyPath:@"isRunning" options:nil];
	[devview bind:@"isLive" toObject:representedObject withKeyPath:@"dimmer.propertyLiveInSelectedCue" options:nil];
	[devview bind:@"isChanged" toObject:representedObject withKeyPath:@"dimmer.unsavedChanges" options:nil];
	
	
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
