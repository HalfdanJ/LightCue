//
//  DeviceViewItem.h
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DeviceView : NSView
{
	BOOL selected;	
	BOOL mouseOver;
	int deviceNumber;
	NSNumber * dimmerValue;
	NSTrackingRectTag trackingRect;
	NSString * deviceName;
}

@property (retain) NSNumber * dimmerValue;
@property (retain) NSString * deviceName;

- (void)setSelected:(BOOL)flag;
- (void)setDeviceNumber:(int)number;

@end


@interface DeviceViewItem : NSCollectionViewItem {
	IBOutlet NSArrayController * devicesArrayController;
}


@end
