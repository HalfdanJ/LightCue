//
//  GraphCueAreaView.m
//  LightCue
//
//  Created by Jonas Jongejan on 26/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "GraphCueAreaView.h"


@implementation GraphCueAreaView
@synthesize drawDict, drawSettingsDict;

- (id)initWithFrame:(NSRect)frame  {
    self = [super initWithFrame:NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
		backgroundColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.3];	
		activeBackgroundColor = [NSColor colorWithDeviceRed:56.0/255 green:117/255.0 blue:215/255.0 alpha:0.33];
		lastRunningTimeCache = 0;
    }
    return self;
}

-(void) setDrawSettingsDict:(NSDictionary *)d{
	drawSettingsDict = d;
	[drawSettingsDict addObserver:self forKeyPath:@"graphStartTime" options:0 context:nil];
	
	timeScale = [[drawSettingsDict objectForKey:@"timeScale"] doubleValue];
}


-(void) setDrawDict:(NSDictionary *)dict{
	[self willChangeValueForKey:@"drawDict"];
	drawDict = dict;
	[self didChangeValueForKey:@"drawDict"];
	
	active = [[dict valueForKey:@"selected"] boolValue];
	
	[drawDict addObserver:self forKeyPath:@"expectedFireTime" options:0 context:nil];
	[drawDict addObserver:self forKeyPath:@"actualFireTime" options:0 context:nil];
	
	[drawDict addObserver:self forKeyPath:@"cueModel.runningTime" options:0 context:nil];
	[drawDict addObserver:self forKeyPath:@"cueModel.running" options:0 context:nil];
	
}

- (void) setCueController:(CueController *) _cueController{
	cueController = _cueController;
}



-(void) updateFrame{
	double startTime;
	if([drawDict objectForKey:@"actualFireTime"] != nil){
		startTime = [[drawDict objectForKey:@"actualFireTime"] doubleValue];
	} else {
		startTime = [[drawDict objectForKey:@"expectedFireTime"] doubleValue];		
	}
	
	NSRect frame = NSMakeRect(startTime* timeScale, 
							  [self frame].origin.y, 
							  [[drawDict valueForKey:@"cueModel"] duration]*timeScale , 
							  [self frame].size.height);
	[self setFrame:frame];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"expectedFireTime"] || [keyPath isEqualToString:@"actualFireTime"]){
		[self updateFrame];
	}

	if([keyPath isEqualToString:@"cueModel.runningTime"]){
		[self setNeedsDisplayInRect:NSMakeRect(lastRunningTimeCache*timeScale-1, 0, 2, [self frame].size.height)];
		[self setNeedsDisplayInRect:NSMakeRect([[drawDict valueForKey:@"cueModel"] runningTime]*timeScale-1, 0, 2, [self frame].size.height)];
		lastRunningTimeCache = [[drawDict valueForKey:@"cueModel"] runningTime];
	}
	
	if([keyPath isEqualToString:@"cueModel.running"]){
		[self setNeedsDisplay:YES];
		running = [[drawDict valueForKey:@"cueModel"] running];
	}
	
}


-(BOOL) isFlipped{
	return YES;	
}


- (void)drawRect:(NSRect)dirtyRect {
	[NSGraphicsContext saveGraphicsState];{		
		
		NSShadow* theShadow = [[NSShadow alloc] init];
		[theShadow setShadowOffset:NSMakeSize(0.0, 0.0)];
		[theShadow setShadowBlurRadius:10];	
		[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:1.0]];	
		
		
		float preWait = [[drawDict valueForKeyPath:@"cueModel.preWait"] floatValue];
		float postWait = [[drawDict valueForKeyPath:@"cueModel.postWait"] floatValue];
		float fadeTime = [[drawDict valueForKeyPath:@"cueModel.fadeTime"] floatValue];
		float fadeDownTime = [[drawDict valueForKeyPath:@"cueModel.fadeDownTime"] floatValue];
		float barHeight = [self frame].size.height/2.0-5;
		LightCueModel * cue = [drawDict valueForKey:@"cueModel"];
		
		[NSGraphicsContext saveGraphicsState];{		
			NSRect frame = [self bounds];
			NSRect backFrame = NSMakeRect(frame.origin.x+0.5+preWait*timeScale, frame.origin.y+0.5, frame.size.width-1-preWait*timeScale, barHeight);
			NSBezierPath* background = [NSBezierPath bezierPathWithRoundedRect:backFrame  xRadius:4 yRadius:4];	
			
			[backgroundColor set];
			
			[background fill];
			if(running)
				[[NSColor colorWithDeviceRed:42/255.0 green:219/255.0 blue:12/255.0 alpha:0.2] set];
			else if(active){
				[activeBackgroundColor set];
				[background fill];
			}
			
			if(active){
				[[NSColor colorWithCalibratedWhite:1.0 alpha:0.4] set];
				[background stroke];
			} else {
				[[NSColor colorWithCalibratedWhite:1.0 alpha:0.4] set];
				[background stroke];			
			}
			[background addClip];
			
			
			NSRect fadeFrame = NSMakeRect(frame.origin.x+0.5+preWait*timeScale, frame.origin.y+0.5, fadeTime*timeScale, barHeight*0.5);
			NSBezierPath* fade = [NSBezierPath bezierPathWithRoundedRect:fadeFrame  xRadius:0 yRadius:0];
			[fade fill];
			
			NSRect fadeDownFrame = NSMakeRect(frame.origin.x+0.5+preWait*timeScale, frame.origin.y+0.5+barHeight*0.5, fadeDownTime*timeScale, barHeight*0.5);
			NSBezierPath* fadeDown = [NSBezierPath bezierPathWithRoundedRect:fadeDownFrame  xRadius:0 yRadius:0];
			[fadeDown fill];
			
			[[NSColor colorWithCalibratedWhite:1.0 alpha:0.6] set];
			NSBezierPath * fadeSeperator = [NSBezierPath bezierPath];
			[fadeSeperator moveToPoint:NSMakePoint(frame.origin.x+0.5+preWait*timeScale, frame.origin.y+barHeight*0.5)];
			[fadeSeperator lineToPoint:NSMakePoint(frame.size.width, frame.origin.y+barHeight*0.5)];
			[fadeSeperator stroke];
			

			
		}[NSGraphicsContext restoreGraphicsState];
		
		//Follow
		if([cue follow] && postWait > 0){
			NSRect rect = NSMakeRect(preWait*timeScale, barHeight*0.5+10.5, postWait*timeScale, barHeight);
			NSDrawThreePartImage(rect, [NSImage imageNamed:@"followArrow1"], [NSImage imageNamed:@"followArrow2"], [NSImage imageNamed:@"followArrow3"], NO, NSCompositeSourceOver, 0.8, YES);
		}
		//Prewait
		if(preWait > 0){
			NSRect rect = NSMakeRect(0, 0, preWait*timeScale, barHeight);
			NSDrawThreePartImage(rect, [NSImage imageNamed:@"prewait_01"], [NSImage imageNamed:@"prewait_02"], nil, NO, NSCompositeSourceOver, 1.0, YES);
		}
		
		//Title
		{
			NSFont * trackNameFontFont = [NSFont fontWithName:@"Geneva" size:10];		 
			NSDictionary * trackNameFontDict = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSColor colorWithCalibratedWhite:1.0 alpha:0.6], NSForegroundColorAttributeName,
												trackNameFontFont, NSFontAttributeName,
												[NSNumber numberWithInt:NSNoUnderlineStyle],
												NSUnderlineStyleAttributeName,
												nil ];
			[[NSString stringWithFormat:@"Cue: %@",[drawDict valueForKeyPath:@"cueModel.lineNumber"]] drawAtPoint:NSMakePoint(5+preWait*timeScale, 0) withAttributes:trackNameFontDict];				
		}
		
		//Fade
		{
		/*	NSBezierPath * fadePath = [NSBezierPath bezierPath];
			[fadePath moveToPoint:NSMakePoint(preWait*timeScale, barHeight)];
			[fadePath lineToPoint:NSMakePoint(preWait*timeScale + fadeTime*timeScale, 0)];
			[fadePath lineToPoint:NSMakePoint(preWait*timeScale + fadeTime*timeScale,barHeight)];
			[fadePath closePath];
			
			NSBezierPath * fadeDownPath = [NSBezierPath bezierPath];
			[fadeDownPath moveToPoint:NSMakePoint(preWait*timeScale, 0)];
			[fadeDownPath lineToPoint:NSMakePoint(preWait*timeScale + fadeDownTime*timeScale, barHeight)];
			[fadeDownPath lineToPoint:NSMakePoint(preWait*timeScale , barHeight)];
			[fadeDownPath closePath];
			
			[[NSColor colorWithCalibratedWhite:1.0 alpha:0.4]set];
			[fadePath stroke];
			[fadeDownPath stroke];
			
			[[NSColor colorWithCalibratedWhite:1.0 alpha:0.4]set];
			[fadeDownPath fill];
			
			[fadePath fill];
		 */
		}
		
		//TimeBar
		if([[drawDict valueForKey:@"cueModel"] running]){
			NSBezierPath* timePath = [NSBezierPath bezierPath];			 
			[timePath moveToPoint:NSMakePoint([[drawDict valueForKey:@"cueModel"] runningTime]*timeScale, 0)];
			[timePath lineToPoint:NSMakePoint([[drawDict valueForKey:@"cueModel"] runningTime]*timeScale, [self frame].size.height)];	
			[[NSColor colorWithCalibratedRed:0 green:1.0 blue:0 alpha:1.0] set];
			[timePath stroke];
		}
	}[NSGraphicsContext restoreGraphicsState];
	
}

-(void) mouseUp:(NSEvent *)theEvent{
	if([theEvent clickCount] == 2 && [theEvent type] == NSLeftMouseUp){
		if(cueController != nil){
			[[cueController cueTreeController] setSelectedObject:[drawDict objectForKey:@"cueModel"]];
		}
	}
}

@end
