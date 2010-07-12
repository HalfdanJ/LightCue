//
//  DimmerView.m
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "DimmerView.h"
#include "DeviceModel.h"

@implementation DimmerView

-(void) drawRect:(NSRect)frame{

	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
	
	CGFloat roundedRadius = 5.0f;
	
	// Outer stroke (drawn as gradient)
	
	[ctx saveGraphicsState];
	NSBezierPath *outerClip = [NSBezierPath bezierPathWithRoundedRect:frame 
															  xRadius:roundedRadius 
															  yRadius:roundedRadius];
	[outerClip setClip];
	
	NSGradient *outerGradient = [[NSGradient alloc] initWithColorsAndLocations:
								 [NSColor colorWithDeviceWhite:0.20f alpha:1.0f], 0.0f, 
								 [NSColor colorWithDeviceWhite:0.21f alpha:1.0f], 1.0f, 
								 nil];
	
	[outerGradient drawInRect:[outerClip bounds] angle:0.0f];
	[outerGradient release];
	[ctx restoreGraphicsState];
	
	
	
	// Background gradient
	
	[ctx saveGraphicsState];
	NSBezierPath *backgroundPath = 
    [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.0f, 1.0f) 
                                    xRadius:roundedRadius 
                                    yRadius:roundedRadius];
	[backgroundPath setClip];
	
	NSGradient *backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
									  [NSColor colorWithDeviceWhite:0.17f alpha:1.0f], 0.0f, 
									  [NSColor colorWithDeviceWhite:0.20f alpha:1.0f], 0.12f, 
									  [NSColor colorWithDeviceWhite:0.27f alpha:1.0f], 0.5f, 
									  [NSColor colorWithDeviceWhite:0.30f alpha:1.0f], 0.5f, 
									  [NSColor colorWithDeviceWhite:0.42f alpha:1.0f], 0.98f, 
									  [NSColor colorWithDeviceWhite:0.50f alpha:1.0f], 1.0f, 
									  nil];
	
	[backgroundGradient drawInRect:[backgroundPath bounds] angle:180.0f];
	[backgroundGradient release];
	[ctx restoreGraphicsState];
	
	
	
	//
	//Dimmer levels
	//
	
	float highestDim = 0;
	for(DeviceModel* device in selection){
		DevicePropertyModel * dimmerProperty = [device dimmer];
		if (dimmerProperty != nil) {
			float dimValue = [[dimmerProperty valueForKey:@"value"] floatValue]/255.0;
			if(dimValue > highestDim){
				highestDim = dimValue;
			}
		}
	}
	
	if(highestDim > 0.01){
		[ctx saveGraphicsState];
		NSBezierPath *backgroundPath = 
		[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.0f, 1.0f) 
										xRadius:roundedRadius 
										yRadius:roundedRadius];
		[backgroundPath setClip];

		NSColor * barColor = [NSColor colorWithDeviceRed:61.2/255.0 green:144.0/255.0 blue:230.0/255.0 alpha:0.5];
		NSGradient *backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
										  [barColor colorWithAlphaComponent:0.5f] , 0.0f, 
										  [barColor colorWithAlphaComponent:0.5f], highestDim-0.005, 												  
										  [barColor colorWithAlphaComponent:0.0f], highestDim, 
										  [barColor colorWithAlphaComponent:0.0f], 1.0, 
										  nil];
		
		[backgroundGradient drawInRect:[backgroundPath bounds] angle:90.0f];
		[backgroundGradient release];
		[ctx restoreGraphicsState];
	}
	
	
	
	for(DeviceModel* device in selection){
		DevicePropertyModel * dimmerProperty = [device dimmer];
		if (dimmerProperty != nil) {
			float dimValue = [[dimmerProperty valueForKey:@"value"] floatValue]/255.0;
			if(dimValue > 0.02){
				
				
				[ctx saveGraphicsState];
				NSBezierPath *backgroundPath = 
				[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.0f, 1.0f) 
												xRadius:roundedRadius 
												yRadius:roundedRadius];
				[backgroundPath setClip];
				
				NSGradient *backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
												  [NSColor colorWithDeviceWhite:1.0f alpha:0.0f], 0.0f, 
												  [NSColor colorWithDeviceWhite:0.8f alpha:0.0f], dimValue-0.005, 												  
												  [NSColor colorWithDeviceWhite:0.8f alpha:1.0f], dimValue-0.004, 
												  [NSColor colorWithDeviceWhite:0.8f alpha:1.0f], dimValue+0.004, 
												  [NSColor colorWithDeviceWhite:0.8f alpha:0.0f], dimValue+0.005, 
												  [NSColor colorWithDeviceWhite:1.0f alpha:0.0f], 1.0, 
												  nil];
				
				[backgroundGradient drawInRect:[backgroundPath bounds] angle:90.0f];
				[backgroundGradient release];
				[ctx restoreGraphicsState];
				
			}
		}
	}
	/*
	 NSBezierPath* aPath = [NSBezierPath bezierPath];
	 for(DeviceModel* device in selection){
	 DevicePropertyModel * dimmerProperty = [device getProperty:@"DIM"];
	 if (dimmerProperty != nil) {
	 float dimValue = [[dimmerProperty valueForKey:@"value"] floatValue];
	 
	 [aPath moveToPoint:NSMakePoint(0.0, height*dimValue/255.0 )];
	 [aPath lineToPoint:NSMakePoint(width, height*dimValue/255.0)];
	 [aPath setLineJoinStyle:NSRoundLineJoinStyle];
	 
	 }
	 }
	 
	 [[[NSColor whiteColor]colorWithAlphaComponent:1.0] set];	
	 [aPath stroke];
	 */
	
	
	
	
	
	// Dark stroke
	
	[ctx saveGraphicsState];
	[[NSColor colorWithDeviceWhite:0.12f alpha:1.0f] setStroke];
	[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 1.5f, 1.5f) 
									 xRadius:roundedRadius 
									 yRadius:roundedRadius] stroke];
	[ctx restoreGraphicsState];
	
	// Inner light stroke
	
	[ctx saveGraphicsState];
	[[NSColor colorWithDeviceWhite:1.0f alpha:0.05f] setStroke];
	[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.5f, 2.5f) 
									 xRadius:roundedRadius 
									 yRadius:roundedRadius] stroke];
	[ctx restoreGraphicsState];   
	/*
	 [NSGraphicsContext saveGraphicsState];	
	 
	 NSShadow* theShadow = [[NSShadow alloc] init];
	 [theShadow setShadowOffset:NSMakeSize(1.0, -1.0)];
	 [theShadow setShadowBlurRadius:3.0];	
	 [theShadow setShadowColor:[[NSColor blackColor]
	 colorWithAlphaComponent:0.9]];	
	 //	[theShadow set];
	 
	 
	 NSBezierPath* thePath = [NSBezierPath bezierPath];	
	 [thePath appendBezierPathWithRoundedRect:[self bounds] xRadius:5 yRadius:5];
	 //	[thePath setLineWidth:2.0];
	 
	 //Fill
	 [[NSColor blackColor] set];	
	 [thePath fill];
	 [NSGraphicsContext restoreGraphicsState];
	 
	 
	 
	 //
	 //Dimmer levels
	 //
	 
	 NSBezierPath* aPath = [NSBezierPath bezierPath];
	 for(DeviceModel* device in selection){
	 DevicePropertyModel * dimmerProperty = [device getProperty:@"DIM"];
	 if (dimmerProperty != nil) {
	 float dimValue = [[dimmerProperty valueForKey:@"value"] floatValue];
	 
	 [aPath moveToPoint:NSMakePoint(0.0, height*dimValue/255.0 )];
	 [aPath lineToPoint:NSMakePoint(width, height*dimValue/255.0)];
	 [aPath setLineJoinStyle:NSRoundLineJoinStyle];
	 
	 }
	 }
	 
	 [[[NSColor whiteColor]colorWithAlphaComponent:1.0] set];	
	 [aPath stroke];
	 
	 
	 
	 //
	 //Gloss
	 //
	 
	 NSGradient* aGradient = [[[NSGradient alloc]
	 initWithColorsAndLocations:
	 [[NSColor whiteColor] colorWithAlphaComponent:0.0], (CGFloat)0.0,
	 [[NSColor whiteColor] colorWithAlphaComponent:0.3], (CGFloat)0.7,
	 [[NSColor whiteColor] colorWithAlphaComponent:0.5], (CGFloat)1.0,
	 nil] autorelease];
	 
	 [aGradient drawInBezierPath:thePath angle:0.0];
	 
	 
	 //
	 //Black stroke
	 //
	 [[NSColor blackColor] set];	
	 [thePath stroke];*/
	
	
}

-(void) mouseDragged:(NSEvent *)theEvent {
	float height = [self bounds].size.height;
	
	float deltaDim = -[theEvent deltaY]/height;
	
	for(DeviceModel* device in selection){
		DevicePropertyModel * dimmerProperty = [device dimmer];
		if (dimmerProperty != nil) {
			float dimValue = [[dimmerProperty valueForKey:@"value"] floatValue];
			[[device dimmer] setValue:[NSNumber numberWithFloat:255.0*MIN(1,MAX(0,dimValue/255.0+deltaDim))]];
		}
	}
	
	[self setNeedsDisplay:YES];
	
}

-(void) mouseDown:(NSEvent *)theEvent{
	DeviceModel* device = [selection objectAtIndex:0];
	if(device != nil)
		[[[[device dimmer] managedObjectContext] undoManager] beginUndoGrouping];
	
	
}

-(void) mouseUp:(NSEvent *)theEvent{
	DeviceModel* device = [selection objectAtIndex:0];
	if(device != nil)
		[[[[device dimmer] managedObjectContext] undoManager] endUndoGrouping];	
}


-(void) setSelection:(NSArray *)_selection{
	selection = _selection;
	[self setNeedsDisplay:YES];
}	

-(NSArray*) selection {
	return nil;
}

@end
