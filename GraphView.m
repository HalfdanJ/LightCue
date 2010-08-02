//
//  GraphView.m
//
//  Created by Jonas Jongejan on 25/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView
@synthesize cueSelection, graphStartTime,graphTimePosition;

-(id) initWithFrame:(NSRect)frameRect{		
	[super initWithFrame:frameRect];
	areaViewHolder = [[NSView alloc] initWithFrame:frameRect];
	[areaViewHolder setAutoresizingMask:NSViewWidthSizable];
	[areaViewHolder setAutoresizesSubviews:YES];
	[self addSubview:areaViewHolder];
	[self setAutoresizesSubviews:YES];
	
	
	return self;
}

-(void) awakeFromNib{
	drawingDict = [NSMutableDictionary dictionary];
	timelineEvents = [NSMutableArray array];
	deviceKeypoints = [NSMutableArray array];
	timeScale = 40;
	
	[drawingDict setObject:[NSNumber numberWithDouble:timeScale] forKey:@"timeScale"];
	
	[super awakeFromNib];
}
-(double) firetimeForDict:(NSDictionary*)dict{
	if([dict objectForKey:@"actualFireTime"] != nil){
		return [[dict objectForKey:@"actualFireTime"] doubleValue];
	} else {
		return [[dict objectForKey:@"expectedFireTime"] doubleValue];		
	}
}

-(void) calculateDimmerKeypoints{
	[deviceKeypoints removeAllObjects];
	
	NSMutableArray * deviceDimSimulator = [NSMutableArray arrayWithCapacity:[[[devicesController devicesArrayController] arrangedObjects] count]];
	
	for(DeviceModel * device in [[devicesController devicesArrayController] arrangedObjects]){
		[deviceKeypoints addObject:[NSMutableArray array]];
		[deviceDimSimulator addObject:[NSMutableDictionary dictionary]];
	}	
	
	for(NSDictionary * event in timelineEvents){
		//Set the end keypoints for all the lamps in that cue
		for(NSManagedObject * deviceRelation in [event valueForKeyPath:@"cue.cueModel.deviceRelations"]){
			for(CueDeviceRelationModel * propertyRelation in [deviceRelation valueForKey:@"devicePropertyRelations"]){				
				if([[propertyRelation valueForKeyPath:@"deviceProperty.name"] isEqualToString:@"DIM"]){
					DeviceModel * device = [deviceRelation valueForKey:@"device"];					
					
					int index = [[[devicesController devicesArrayController] arrangedObjects] indexOfObjectIdenticalTo:device];
					if(index > -1){
						NSMutableArray * deviceKeyArray = [deviceKeypoints objectAtIndex:index];
						
						//
						//Start
						//
						if([[event objectForKey:@"type"] isEqualToString:@"prewaitEnd"]){						
							CueDeviceRelationModel * lastModifier = [[deviceDimSimulator objectAtIndex:index] valueForKey:@"lastModifier"];
							if(lastModifier == nil || [[[lastModifier cue] lineNumber] intValue] < [[[propertyRelation cue] lineNumber] intValue] ){
								//Take over the device. set keypoint at current level if there is a mutexholder
								CueDeviceRelationModel * mutexHolder = [[deviceDimSimulator objectAtIndex:index] valueForKey:@"mutexHolder"];
								if(mutexHolder != nil){
									//If the time is inside the margin of fade or fadeDown
									double eventTime = [[event valueForKey:@"time"] doubleValue];
									double cueTime = eventTime - [self firetimeForDict:[event valueForKeyPath:@"cue"]];
									LightCueModel * cue = [event valueForKeyPath:@"cue.cueModel"];
									if(cueTime > [[cue valueForKey:@"preWait"] doubleValue] && (cueTime < [[cue valueForKey:@"preWait"] doubleValue] + [[cue valueForKey:@"fadeTime"] doubleValue] || cueTime < [[cue valueForKey:@"preWait"] doubleValue] + [[cue valueForKey:@"fadeDownTime"] doubleValue])){
										double fadePercentage = MIN(1,(cueTime -  [[cue valueForKey:@"preWait"] doubleValue])/[[cue valueForKey:@"fadeTime"] doubleValue]);
										double fadeDownPercentage = MIN(1,(cueTime -  [[cue valueForKey:@"preWait"] doubleValue])/[[cue valueForKey:@"fadeDownTime"] doubleValue]);
										double lastKeyValue = [[[deviceDimSimulator objectAtIndex:index] valueForKeyPath:@"lastKey.value"] doubleValue];
										double goalValue =  [[propertyRelation valueForKey:@"value"] doubleValue];
										double value;
										if(lastKeyValue > goalValue){
											value = lastKeyValue + (goalValue - lastKeyValue)*fadeDownPercentage;
										} else {
											value = lastKeyValue + (goalValue - lastKeyValue)*fadePercentage;
										}
										
										NSMutableDictionary * dict = [NSMutableDictionary dictionary];
										[dict setObject:[NSNumber numberWithDouble:value] forKey:@"value"];
										[dict setObject:event forKey:@"event"];
										[deviceKeyArray addObject:dict];	
										[[deviceDimSimulator objectAtIndex:index] setValue:dict forKey:@"lastKey"];
									}
								}
								
								[[deviceDimSimulator objectAtIndex:index]  setValue:propertyRelation forKey:@"mutexHolder"];
								[[deviceDimSimulator objectAtIndex:index]  setValue:propertyRelation forKey:@"lastModifier"];
							}
						}
						
						//
						//PrewaitEnd
						//
						if([[event objectForKey:@"type"] isEqualToString:@"prewaitEnd"]){						
							double lastKeyValue;
							if([[deviceDimSimulator objectAtIndex:index] valueForKey:@"lastKey"] != nil)
								lastKeyValue = [[[deviceDimSimulator objectAtIndex:index] valueForKeyPath:@"lastKey.value"] doubleValue];
							else {
								//Find the last value in the cuelist
								CueModel * lastCue = [[event valueForKeyPath:@"cue.cueModel"] previousCue];
								DevicePropertyModel * deviceProperty = [propertyRelation valueForKey:@"deviceProperty"];
								lastKeyValue = [[deviceProperty valueInCue:lastCue] doubleValue];
							}
							
							if(propertyRelation == [[deviceDimSimulator objectAtIndex:index] valueForKey:@"mutexHolder"]){
								NSMutableDictionary * dict = [NSMutableDictionary dictionary];
								[dict setObject:[NSNumber numberWithDouble:lastKeyValue] forKey:@"value"];
								[dict setObject:event forKey:@"event"];
								[deviceKeyArray addObject:dict];	
								[[deviceDimSimulator objectAtIndex:index] setValue:dict forKey:@"lastKey"];					
							}
						}
						
						//
						//FadeEnd	
						//
						if([[event objectForKey:@"type"] isEqualToString:@"fadeEnd"]){						
							double lastKeyValue;
							if([[deviceDimSimulator objectAtIndex:index] valueForKey:@"lastKey"] != nil)
								lastKeyValue = [[[deviceDimSimulator objectAtIndex:index] valueForKeyPath:@"lastKey.value"] doubleValue];
							else 
								lastKeyValue = 0;
							
							if(propertyRelation == [[deviceDimSimulator objectAtIndex:index] valueForKey:@"mutexHolder"] && [[propertyRelation valueForKey:@"value"] doubleValue] > lastKeyValue){
								NSMutableDictionary * dict = [NSMutableDictionary dictionary];
								[dict setObject:[propertyRelation valueForKey:@"value"] forKey:@"value"];
								[dict setObject:event forKey:@"event"];
								[deviceKeyArray addObject:dict];	
								[[deviceDimSimulator objectAtIndex:index] setValue:dict forKey:@"lastKey"];					
							}
						}
						
						//
						//FadeDownEnd	
						//
						if([[event objectForKey:@"type"] isEqualToString:@"fadeDownEnd"]){						
							double lastKeyValue;
							if([[deviceDimSimulator objectAtIndex:index] valueForKey:@"lastKey"] != nil)
								lastKeyValue = [[[deviceDimSimulator objectAtIndex:index] valueForKeyPath:@"lastKey.value"] doubleValue];
							else 
								lastKeyValue = 0;
							
							if(propertyRelation == [[deviceDimSimulator objectAtIndex:index] valueForKey:@"mutexHolder"] && [[propertyRelation valueForKey:@"value"] doubleValue] < lastKeyValue){
								NSMutableDictionary * dict = [NSMutableDictionary dictionary];
								[dict setObject:[propertyRelation valueForKey:@"value"] forKey:@"value"];
								[dict setObject:event forKey:@"event"];
								[deviceKeyArray addObject:dict];	
								[[deviceDimSimulator objectAtIndex:index] setValue:dict forKey:@"lastKey"];					
							}
						}
						
						//
						//End	
						//
						if([[event objectForKey:@"type"] isEqualToString:@"fadeDownEnd"]){						
							if(propertyRelation == [[deviceDimSimulator objectAtIndex:index] valueForKey:@"mutexHolder"]){
								[[deviceDimSimulator objectAtIndex:index] removeObjectForKey:@"mutexHolder"];
							}
						}
						
						
						/*
						 if([[event objectForKey:@"type"] isEqualToString:@"fadeEnd"] || [[event objectForKey:@"type"] isEqualToString:@"prewaitEnd"]){						
						 NSMutableArray * deviceKeyArray = [deviceKeypoints objectAtIndex:index];
						 NSMutableDictionary * dict = [NSMutableDictionary dictionary];
						 [dict setObject:[propertyRelation valueForKey:@"value"] forKey:@"value"];
						 [dict setObject:event forKey:@"event"];
						 [deviceKeyArray addObject:dict];
						 }*/
					} else {
						NSLog(@"Error in index %i on device %@ %@",index,[propertyRelation valueForKeyPath:@"deviceProperty.name"], device);	
					}
					
				}
			}
		}
	}
	
	[self setNeedsDisplay:YES];
}

-(void) calculateTimelineEvents{
	[timelineEvents removeAllObjects];
	
	for(NSMutableDictionary * dict in [drawingDict objectForKey:@"shownCues"]){		
		[timelineEvents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"start",@"type",
								   dict,@"cue",
								   [NSNumber numberWithDouble:[self firetimeForDict:dict]],@"time",nil]];
		
		[timelineEvents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"prewaitEnd",@"type",
								   dict,@"cue", 
								   [NSNumber numberWithDouble:[self firetimeForDict:dict]+[[dict valueForKeyPath:@"cueModel.preWait"] doubleValue]],@"time",nil]];
		
		[timelineEvents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"fadeEnd",@"type",
								   dict,@"cue",
								   [NSNumber numberWithDouble:[self firetimeForDict:dict]+[[dict valueForKeyPath:@"cueModel.preWait"] doubleValue]+[[dict valueForKeyPath:@"cueModel.fadeTime"] doubleValue]],@"time",nil]];
		
		[timelineEvents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"fadeDownEnd",@"type",
								   dict,@"cue",
								   [NSNumber numberWithDouble:[self firetimeForDict:dict]+[[dict valueForKeyPath:@"cueModel.preWait"] doubleValue]+[[dict valueForKeyPath:@"cueModel.fadeDownTime"] doubleValue]],@"time",nil]];
		
		[timelineEvents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"postWaitEnd",@"type",
								   dict,@"cue",
								   [NSNumber numberWithDouble:[self firetimeForDict:dict]+[[dict valueForKeyPath:@"cueModel.preWait"] doubleValue]+[[dict valueForKeyPath:@"cueModel.postWait"] doubleValue]],@"time",nil]];	
		
		[timelineEvents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"end",@"type",
								   dict,@"cue",
								   [NSNumber numberWithDouble:[self firetimeForDict:dict]+[[dict valueForKeyPath:@"cueModel.preWait"] doubleValue]+MAX([[dict valueForKeyPath:@"cueModel.postWait"] doubleValue],MAX([[dict valueForKeyPath:@"cueModel.fadeDownTime"] doubleValue],[[dict valueForKeyPath:@"cueModel.fadeTime"] doubleValue]))],@"time",nil]];	
		
	}
	
	
	[timelineEvents sortUsingDescriptors:	[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES]]];
	
	//Calculate dimmer values for all lamps
	[self calculateDimmerKeypoints];
	
	
}

-(void) calculateFireTimes{
	//
	//Calculate the expected firetimes for each cue
	//
	
	int i=0; 
	double fireTime; // the base time that the first cue in the selection will have
	NSMutableDictionary * lastDict; //The dict before the current buffer
	for(NSMutableDictionary * dict in [drawingDict objectForKey:@"shownCues"]){
		LightCueModel * cue = [dict objectForKey:@"cueModel"];
		
		if(i==0){
			//The first one should have 0 as expected fire time
			fireTime = 0;
		} else {
			LightCueModel * lastCue = [lastDict objectForKey:@"cueModel"];
			
			if([lastCue follow]){
				fireTime += [[lastCue valueForKey:@"preWait"] doubleValue] + [[lastCue valueForKey:@"postWait"] doubleValue];				
			} else {
				//if the last dict is not a follow, this one is expected to fire just after the previous
				fireTime += [lastCue duration];
			}
			
			//If the cue is running, whe should set the actual fire time at the same time
			if([cue running]){
				double intervalBetweenLastCue = -[[lastCue preWaitTimerStartDate] timeIntervalSinceDate:[cue preWaitTimerStartDate]];
				if(intervalBetweenLastCue < [lastCue duration]){
					[dict setObject:[NSNumber numberWithDouble:[self firetimeForDict:lastDict] + intervalBetweenLastCue] forKey:@"actualFireTime"];			
					
					fireTime -= MIN([lastCue duration] - intervalBetweenLastCue, [cue duration]);
				}
			}
		}
		[dict setObject:[NSNumber numberWithDouble:fireTime] forKey:@"expectedFireTime"];			
		
		i++;
		lastDict = dict;
		
		NSLog(@"#%i is expected to fire at: %@        did fire at: %@        duration: %f",i, [dict objectForKey:@"expectedFireTime"],  [dict objectForKey:@"actualFireTime"],[[dict objectForKey:@"cueModel"] duration]);
	}
	
	[self performSelector:@selector(calculateTimelineEvents) withObject:nil afterDelay:0];
	
}

-(void) calculateNewTimelineFromSelection{
	NSArray * cueOberservationKeyPaths = [NSArray arrayWithObjects:@"runningTime",@"running",@"preWait",@"fadeTime",@"fadeDownTime",@"postWait",@"follow",@"deviceRelationsChangeNotifier",nil];
	
	for(NSDictionary * cueDict in [drawingDict objectForKey:@"shownCues"]){
		LightCueModel * cue = [cueDict objectForKey:@"cueModel"];
		for(NSString * s in cueOberservationKeyPaths){
			[cue removeObserver:self forKeyPath:s];
		}
	}
	
	//Calculate the cues that should be shown
	NSMutableArray * shownDictCues = [NSMutableArray array];
	
	if([cueSelection count] == 1 && [[cueSelection lastObject] isKindOfClass:[LightCueModel class]]){		
		LightCueModel * selectedCue = [cueSelection lastObject];		
		
		LightCueModel * prevCue = selectedCue;		
		while (prevCue != nil && [[prevCue previousCue] follow]) {
			prevCue = [prevCue previousCue];	
			NSMutableDictionary * prev = [NSMutableDictionary dictionary];
			[prev setObject:prevCue forKey:@"cueModel"];
			[shownDictCues insertObject:prev atIndex:0];
			
		}
		
		
		
		NSMutableDictionary * selected = [NSMutableDictionary dictionary];
		[selected setObject:selectedCue forKey:@"cueModel"];
		[selected setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
		[shownDictCues addObject:selected];
		
		
		LightCueModel * nextCue = [selectedCue nextCue];
		while (nextCue != nil && [selectedCue follow]) {
			if(nextCue != nil){
				NSMutableDictionary * next = [NSMutableDictionary dictionary];
				[next setObject:nextCue forKey:@"cueModel"];
				[shownDictCues addObject:next];
			}
			selectedCue = nextCue;
			nextCue = [nextCue nextCue];			
		}
		
	}	
	
	NSMutableArray * subViews = [NSMutableArray array];
	int line = 0;
	float height = 30;

	for(NSMutableDictionary * dict in shownDictCues){
		GraphCueAreaView * area = [[GraphCueAreaView alloc] initWithFrame:NSMakeRect(0, line*height, 0, height*2)];
		[area setCueController:cueController];
		[area setDrawDict:dict];
		[area setDrawSettingsDict:drawingDict];
		[dict setObject:area forKey:@"view"];		
		[subViews addObject:area];
		line++;
	}
	[self setSubviews:subViews];
	[self setFrame:NSMakeRect(0, 0, [self frame].size.width,line*height)];
//	[self setFrame:NSMakeRect(0, 0, 400, [self frame].size.width)];

	
	[drawingDict setObject:shownDictCues forKey:@"shownCues"];	
	
	for(NSDictionary * cueDict in [drawingDict objectForKey:@"shownCues"]){
		LightCueModel * cue = [cueDict objectForKey:@"cueModel"];
		for(NSString * s in cueOberservationKeyPaths){
			[cue addObserver:self forKeyPath:s options:0 context:s];
		}
	}
	
	[self calculateFireTimes];
	
}




-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	NSArray * fireTimeChangers = [NSArray arrayWithObjects:@"preWait",@"fadeTime",@"fadeDownTime",@"postWait",@"follow",@"deviceRelationsChangeNotifier",nil];
	
	if([fireTimeChangers containsObject:keyPath] && timelineEvents != nil){
		[self calculateFireTimes];
	}
	
	if([(NSString*)context isEqualToString:@"runningTime"]){
		//		for(NSMutableDictionary * dict in [drawingDict objectForKey:@"shownCues"]){
		//			if([dict objectForKey:@"cueModel"] == object){
		//				[self setGraphTimePosition:[object runningTime]+[[dict objectForKey:@"startTime"] doubleValue]];
		//			}
		//		}
	}
	
	if([(NSString*)context isEqualToString:@"running"]){
		//	[self updateCueStartTimes];
	}
	
	
	
	if([(NSString*)context isEqualToString:@"redraw"]){
		[self setNeedsDisplay:YES];
	}
}



-(void) setGraphStartTime:(double)d{
	[self willChangeValueForKey:@"graphStartTime"];
	graphStartTime = d;
	[drawingDict setObject:[NSNumber numberWithDouble:d] forKey:@"graphStartTime"];
	[self didChangeValueForKey:@"graphStartTime"];
}


-(void) setGraphTimePosition:(double)d{
	[self willChangeValueForKey:@"graphTimePosition"];
	graphTimePosition = d;
	[self didChangeValueForKey:@"graphTimePosition"];
	[self setNeedsDisplay:YES];
}




-(void) setCueSelection:(NSArray *)array{
	[self willChangeValueForKey:@"cueSelection"];
	cueSelection = array;
	[self didChangeValueForKey:@"cueSelection"];	
	
	[self calculateNewTimelineFromSelection];
	
}


-(BOOL) isFlipped{
	return YES;	
}

-(double) scaledDimValue:(NSNumber*)val{
	double ret = [val doubleValue];
	ret /= 255.0;
	ret *= [self frame].size.height;
	ret = [self frame].size.height - ret;
	
	return ret;
}


-(void) drawRect:(NSRect)dirtyRect{
	[super drawRect:dirtyRect];
	
	
	float viewWidth = [self bounds].size.width;
	float viewHeight = [self bounds].size.height;
	
	
	float zeroTimePosX = 200.5;
	
	/*int i=0;
	NSMutableArray * paths = [NSMutableArray array];
	for(NSArray * keypoints in deviceKeypoints){
		if([keypoints count] > 0){
			NSBezierPath* path = [NSBezierPath bezierPath];			 
			NSMutableDictionary * firstKeypoint = [keypoints objectAtIndex:0];
			NSMutableDictionary * lastKeypoint = [keypoints lastObject];
			
			[path moveToPoint:NSMakePoint(0, [self scaledDimValue:[firstKeypoint valueForKeyPath:@"value"]])];
			
			for(NSMutableDictionary * keypoint in keypoints){
				[path lineToPoint:NSMakePoint([[keypoint valueForKeyPath:@"event.time"] doubleValue]*timeScale, [self scaledDimValue:[keypoint valueForKeyPath:@"value"]])];
				//				NSLog(@"%i: %f -  %f",i,[[keypoint valueForKeyPath:@"event.time"] doubleValue],[[keypoint valueForKeyPath:@"value"] doubleValue]);
			}
			
			[path lineToPoint:NSMakePoint([self frame].size.width+2, [self scaledDimValue:[lastKeypoint valueForKeyPath:@"value"]])];
			[path lineToPoint:NSMakePoint([self frame].size.width+2, [self frame].size.height+2)];
			[path lineToPoint:NSMakePoint(0, [self frame].size.height+2)];
			[path closePath];
			
			[paths addObject:path];
			
		}
		i++;
	}
	
	for(NSBezierPath * path in paths){
		[[NSColor colorWithCalibratedWhite:0.25 alpha:0.8] set];
		[path fill];		
		
	}
	for(NSBezierPath * path in paths){
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
		[path stroke];
		
	}
	*/
	[NSGraphicsContext saveGraphicsState];{		
		//Top
		{
			NSAffineTransform* yform = [NSAffineTransform transform];
			[yform translateXBy:0 yBy:15.5];
			[yform concat];
		}
		
		
		//Tracks
		/*		{
		 //Define the seperator 
		 NSBezierPath* seperatorPath = [NSBezierPath bezierPath];			 
		 [seperatorPath moveToPoint:NSMakePoint(0,0)];
		 [seperatorPath lineToPoint:NSMakePoint(viewWidth, 0)];
		 
		 //Define trackNameFont
		 NSFont * trackNameFontFont = [NSFont fontWithName:@"Geneva" size:10];		 
		 NSDictionary * trackNameFontDict = [NSDictionary dictionaryWithObjectsAndKeys:
		 [NSColor colorWithCalibratedWhite:1.0 alpha:0.3], NSForegroundColorAttributeName,
		 trackNameFontFont, NSFontAttributeName,
		 [NSNumber numberWithInt:NSNoUnderlineStyle],
		 NSUnderlineStyleAttributeName,
		 nil ];
		 
		 
		 
		 //
		 //Pre Wait Track
		 //
		 [NSGraphicsContext saveGraphicsState];{		
		 [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] set];
		 [seperatorPath stroke];
		 [@"Pre Wait" drawAtPoint:NSMakePoint(5, 5) withAttributes:trackNameFontDict];				
		 
		 NSBezierPath* preWaitArea = [NSBezierPath bezierPathWithRect:NSMakeRect(zeroTimePosX, 0, [preWaitValue floatValue]*timeScale, 25)];			 
		 
		 [[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
		 [preWaitArea fill];
		 
		 
		 
		 }[NSGraphicsContext restoreGraphicsState];
		 
		 {
		 NSAffineTransform* yform = [NSAffineTransform transform];
		 [yform translateXBy:0 yBy:25];
		 [yform concat];
		 }
		 
		 
		 //
		 //Post Wait Track
		 //
		 [NSGraphicsContext saveGraphicsState];{		
		 [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] set];
		 [seperatorPath stroke];
		 [@"Post Wait" drawAtPoint:NSMakePoint(5, 5) withAttributes:trackNameFontDict];				
		 
		 NSBezierPath* preWaitArea = [NSBezierPath bezierPathWithRect:NSMakeRect(zeroTimePosX+ [preWaitValue floatValue]*timeScale, 0, [postWaitValue floatValue]*timeScale, 25)];			 				
		 [[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
		 [preWaitArea fill];
		 
		 
		 
		 }[NSGraphicsContext restoreGraphicsState];
		 
		 {
		 NSAffineTransform* yform = [NSAffineTransform transform];
		 [yform translateXBy:0 yBy:25];
		 [yform concat];
		 }
		 
		 
		 
		 //
		 //Fade Track
		 //
		 [NSGraphicsContext saveGraphicsState];{		
		 [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] set];
		 [seperatorPath stroke];
		 [@"Fade Time" drawAtPoint:NSMakePoint(5, 5) withAttributes:trackNameFontDict];				
		 
		 NSBezierPath* preWaitArea = [NSBezierPath bezierPathWithRect:NSMakeRect(zeroTimePosX+ [preWaitValue floatValue]*timeScale, 0, [fadeValue floatValue]*timeScale, 25)];			 				
		 [[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
		 [preWaitArea fill];
		 
		 
		 
		 }[NSGraphicsContext restoreGraphicsState];
		 
		 {
		 NSAffineTransform* yform = [NSAffineTransform transform];
		 [yform translateXBy:0 yBy:25];
		 [yform concat];
		 }
		 
		 
		 //
		 //FadeDown Track
		 //
		 [NSGraphicsContext saveGraphicsState];{		
		 [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] set];
		 [seperatorPath stroke];
		 [@"Fade Down Time" drawAtPoint:NSMakePoint(5, 5) withAttributes:trackNameFontDict];				
		 
		 NSBezierPath* preWaitArea = [NSBezierPath bezierPathWithRect:NSMakeRect(zeroTimePosX+ [preWaitValue floatValue]*timeScale, 0, [fadeDownValue floatValue]*timeScale, 25)];			 				
		 [[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
		 [preWaitArea fill];
		 
		 
		 {
		 NSAffineTransform* yform = [NSAffineTransform transform];
		 [yform translateXBy:0 yBy:25];
		 [yform concat];
		 }
		 
		 [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] set];
		 [seperatorPath stroke];
		 
		 
		 }[NSGraphicsContext restoreGraphicsState];
		 
		 
		 }
		 */		
		
	}[NSGraphicsContext restoreGraphicsState];
	
	
	
	
	
	
	
	
}

@end
