//
//  DeviceViewItem.h
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LightCueModel;

@interface DeviceView : NSView
{
	BOOL selected;	
	BOOL mouseOver;
	int deviceNumber;
	NSNumber * dimmerValue;
	NSNumber * dimmerValueInCue;
	NSNumber * dimmerOutputValue;
	NSTrackingRectTag trackingRect;
	NSString * deviceName;
	
	LightCueModel * selectedCue;
	
	BOOL inSelectedCue;
	BOOL isRunning;
	BOOL isLive;
	BOOL isChanged;

}

@property (retain) NSNumber * dimmerValue;
@property (retain) NSNumber * dimmerValueInCue;
@property (retain) NSNumber * dimmerOutputValue;
@property (retain) NSString * deviceName;
@property (retain) LightCueModel * selectedCue;

@property (readwrite) BOOL inSelectedCue;
@property (readwrite) BOOL isRunning;
@property (readwrite) BOOL isLive;
@property (readwrite) BOOL isChanged;

- (void)setSelected:(BOOL)flag;
- (void)setDeviceNumber:(int)number;

@end


@interface DeviceViewItem : NSCollectionViewItem {
	IBOutlet NSArrayController * devicesArrayController;
}


@end
