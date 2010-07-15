//
//  DeviceViewItem.h
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CueModel;

@interface DeviceView : NSView
{
	BOOL selected;	
	BOOL mouseOver;
	int deviceNumber;
	NSNumber * dimmerValue;
	NSNumber * dimmerOuputValue;
	NSTrackingRectTag trackingRect;
	NSString * deviceName;
	
	CueModel * selectedCue;
	
	BOOL inSelectedCue;
}

@property (retain) NSNumber * dimmerValue;
@property (retain) NSNumber * dimmerOutputValue;
@property (retain) NSString * deviceName;
@property (retain) CueModel * selectedCue;

@property (readwrite) BOOL inSelectedCue;

- (void)setSelected:(BOOL)flag;
- (void)setDeviceNumber:(int)number;

@end


@interface DeviceViewItem : NSCollectionViewItem {
	IBOutlet NSArrayController * devicesArrayController;
}


@end
