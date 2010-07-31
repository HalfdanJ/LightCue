//
//  SerialDeviceController.h
//  LightCue
//
//  Created by Jonas Jongejan on 19/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// import IOKit headers
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/serial/ioss.h>
#include <sys/ioctl.h>

#include "pro_driver.h"
#import "DevicesController.h"

int serialFileDescriptor; // file handle to the serial port

@interface SerialDeviceController : NSObject {
	struct termios gOriginalTTYAttrs; // Hold the original termios attributes so we can reset them on quit ( best practice )

	bool readThreadRunning;

	NSMutableSet * serialDevices;
	
	NSThread * thread;
	
	BOOL hasConnected;
	IBOutlet NSArrayController * devices;
}

- (void) refreshSerialList;
- (void) threadRunner;

@end
