//
//  SerialDeviceController.m
//  LightCue
//
//  Created by Jonas Jongejan on 19/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//


#import "SerialDeviceController.h"
DMXUSBPROParamsType PRO_Params;
#define DMX_DATA_LENGTH 513 // Includes the start code 

int FTDI_SendData(int label, unsigned char *data, int length)
{
	unsigned char end_code = DMX_END_CODE;
	int res = 0;
	int bytes_written = 0;
	
	int size=0;
	// Form Packet Header
	unsigned char header[DMX_HEADER_LENGTH];
	header[0] = DMX_START_CODE;
	header[1] = label;
	header[2] = length & OFFSET;
	header[3] = length >> BYTE_LENGTH;
	// Write The Header
	res = write(	serialFileDescriptor,(unsigned char *)header,DMX_HEADER_LENGTH);
	if (res != DMX_HEADER_LENGTH) return  NO_RESPONSE;
	// Write The Data
	res = write(	serialFileDescriptor,(unsigned char *)data,length);
	if (res != length) return  NO_RESPONSE;
	// Write End Code
	res = write(	serialFileDescriptor,(unsigned char *)&end_code,ONE_BYTE);
	if (res != ONE_BYTE) return  NO_RESPONSE;
	
	
	return TRUE;
}

int FTDI_ReceiveData(int label, unsigned char *data, unsigned int expected_length)
{
	
	int res = 0;
	int length = 0;
	int bytes_to_read = 1;
	int bytes_read =0;
	unsigned char byte = 0;
	
	char buffer[600];
	// Check for Start Code and matching Label
	while (byte != label)
	{
		while (byte != DMX_START_CODE)
		{
			res = read(serialFileDescriptor,(unsigned char *)&byte,ONE_BYTE);
			if(res == -1) return  NO_RESPONSE;
		}
		res = read(serialFileDescriptor,(unsigned char *)&byte,ONE_BYTE);
		if (res == -1) return  NO_RESPONSE;
	}
	// Read the rest of the Header Byte by Byte -- Get Length
	res = read(serialFileDescriptor,(unsigned char *)&byte,ONE_BYTE);
	if (res == -1) return  NO_RESPONSE;
	length = byte;
	read(serialFileDescriptor,(unsigned char *)&byte,ONE_BYTE);
	
	length += ((uint32_t)byte)<<BYTE_LENGTH;	
	// Check Length is not greater than allowed
	if (length > DMX_PACKET_SIZE)
		return  NO_RESPONSE;
	// Read the actual Response Data
	res = read(serialFileDescriptor,buffer,length);
	if(res != length) return  NO_RESPONSE;
	// Check The End Code
	res = read(serialFileDescriptor,(unsigned char *)&byte,ONE_BYTE);
	if(res == -1) return  NO_RESPONSE;
	if (byte != DMX_END_CODE) return  NO_RESPONSE;
	// Copy The Data read to the buffer passed
	memcpy(data,buffer,expected_length);
	return TRUE;
}


@implementation SerialDeviceController
-(void) awakeFromNib{
	serialFileDescriptor = -1;
	readThreadRunning = FALSE;
	hasConnected = NO;
	
	thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadRunner) object:nil];
	[thread start];
	
	
}

- (void) threadRunner{
	while(1){
		if(!hasConnected){
			[self refreshSerialList];
			hasConnected = YES;
		} else if(serialFileDescriptor != -1) {
			__block unsigned char myDmx[DMX_DATA_LENGTH];
			// initialize with data to send
			memset(myDmx,0,DMX_DATA_LENGTH); 
			dispatch_sync(dispatch_get_main_queue(), ^{
				int i=1;

				for(NSManagedObject * device in [devices arrangedObjects]){
					for(NSManagedObject * property in [device valueForKey:@"properties"]){
					//	myDmx+i = [[property valueForKey:@"outputValue"] intValue]; 
						//NSLog(@"%i %i",i,myDmx[i]);
						i++;
					}
				}
				

			});

			

				// Start Code = 0
				myDmx[0] = 0;
				// actual send function called 
				int res = FTDI_SendData(SET_DMX_TX_MODE, myDmx, DMX_DATA_LENGTH);
				// check response from Send function
				if (res < 0)
				{
					printf("FAILED: Sending DMX to PRO \n");
				}
				// output debug
			
		}
		[NSThread sleepForTimeInterval:0.0081];

	}
}

- (BOOL) openSerialPort: (NSString *)serialPortFile baud: (speed_t)baudRate {
	int success;
	
	// close the port if it is already open
	if (serialFileDescriptor != -1) {
		close(serialFileDescriptor);		
		
		serialFileDescriptor = -1;
		
		// wait for the reading thread to die
		while(readThreadRunning);
		
		// re-opening the same port REALLY fast will fail spectacularly... better to sleep a sec
		sleep(0.5);
	}
	
	// c-string path to serial-port file
	const char *bsdPath = [serialPortFile cStringUsingEncoding:NSUTF8StringEncoding];
	
	// Hold the original termios attributes we are setting
	struct termios options;
	
	// receive latency ( in microseconds )
	unsigned long mics = 3;
	
	// error message string
	NSString *errorMessage = nil;
	
	// open the port
	//     O_NONBLOCK causes the port to open without any delay (we'll block with another call)
	serialFileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK );
	
	if (serialFileDescriptor == -1) { 
		// check if the port opened correctly
		errorMessage = @"Error: couldn't open serial port";
	} else {
		// TIOCEXCL causes blocking of non-root processes on this serial-port
		success = ioctl(serialFileDescriptor, TIOCEXCL);
		if ( success == -1) { 
			errorMessage = @"Error: couldn't obtain lock on serial port";
		} else {
			success = fcntl(serialFileDescriptor, F_SETFL, 0);
			if ( success == -1) { 
				// clear the O_NONBLOCK flag; all calls from here on out are blocking for non-root processes
				errorMessage = @"Error: couldn't obtain lock on serial port";
			} else {
				// Get the current options and save them so we can restore the default settings later.
				success = tcgetattr(serialFileDescriptor, &gOriginalTTYAttrs);
				if ( success == -1) { 
					errorMessage = @"Error: couldn't get serial attributes";
				} else {
					// copy the old termios settings into the current
					//   you want to do this so that you get all the control characters assigned
					options = gOriginalTTYAttrs;
					
					/*
					 cfmakeraw(&options) is equivilent to:
					 options->c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
					 options->c_oflag &= ~OPOST;
					 options->c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
					 options->c_cflag &= ~(CSIZE | PARENB);
					 options->c_cflag |= CS8;
					 */
					cfmakeraw(&options);
					
					// set tty attributes (raw-mode in this case)
					success = tcsetattr(serialFileDescriptor, TCSANOW, &options);
					if ( success == -1) {
						errorMessage = @"Error: coudln't set serial attributes";
					} else {
						// Set baud rate (any arbitrary baud rate can be set this way)
						success = ioctl(serialFileDescriptor, IOSSIOSPEED, &baudRate);
						if ( success == -1) { 
							errorMessage = @"Error: Baud Rate out of bounds";
						} else {
							// Set the receive latency (a.k.a. don't wait to buffer data)
							success = ioctl(serialFileDescriptor, IOSSDATALAT, &mics);
							if ( success == -1) { 
								errorMessage = @"Error: coudln't set serial latency";
							}
						}
					}
				}
			}
		}
	}
	
	// make sure the port is closed if a problem happens
	if ((serialFileDescriptor != -1) && (errorMessage != nil)) {
		close(serialFileDescriptor);
		serialFileDescriptor = -1;
	}
	
	if(serialFileDescriptor != -1){
		return YES;
	} else {
		NSLog(@"Error message: %@",errorMessage);		
		return NO;
	}
}

- (int) openConnection:(NSString *)port{
	int VersionMSB =0;
	int VersionLSB =0;
	uint8_t temp[4];
	int BreakTime;
	int MABTime;
	
	
	BOOL connected = [self openSerialPort:port baud:115200];
	if(connected){
		int size = 0;

		struct timespec interval = {0,100000000}, remainder;		
		ioctl(serialFileDescriptor, TIOCSDTR);
		nanosleep(&interval, &remainder); // wait 0.1 seconds
		ioctl(serialFileDescriptor, TIOCCDTR);
		
		int res = FTDI_SendData(GET_WIDGET_PARAMS,(unsigned char *)&size,2);
		// Check Response
		if (res == NO_RESPONSE){
			res = FTDI_SendData(GET_WIDGET_PARAMS,(unsigned char *)&size,2);
			if (res == NO_RESPONSE)
			{
				//	FTDI_ClosePort();
				return  NO_RESPONSE;
			}
			
		}
		
		printf("\nWaiting for GET_WIDGET_PARAMS_REPLY packet... ");
		res=FTDI_ReceiveData(GET_WIDGET_PARAMS_REPLY,(unsigned char *)&PRO_Params,sizeof(DMXUSBPROParamsType));
		// Check Response
		if (res == NO_RESPONSE)
		{
			// Recive Widget Response packet
			res=FTDI_ReceiveData(GET_WIDGET_PARAMS_REPLY,(unsigned char *)&PRO_Params,sizeof(DMXUSBPROParamsType));
			if (res == NO_RESPONSE)
			{
				return NO_RESPONSE;

			}
		}
		else
			printf("\n GET WIDGET REPLY Received ... ");
		// Firmware  Version
		VersionMSB = PRO_Params.FirmwareMSB;
		VersionLSB = PRO_Params.FirmwareLSB;
		// GET PRO's serial number 
		FTDI_SendData(GET_WIDGET_SN,(unsigned char *)&size,2);
		FTDI_ReceiveData(GET_WIDGET_SN,(unsigned char *)&temp,4);
		// Display All PRO Parametrs & Info avialable
		printf("\n-----------::PRO Connected [Information Follows]::------------");
		printf("\n\t\t  FIRMWARE VERSION: %d.%d",VersionMSB,VersionLSB);
		BreakTime = (int) (PRO_Params.BreakTime * 10.67) + 100;
		printf("\n\t\t  BREAK TIME: %d micro sec ",BreakTime);
		MABTime = (int) (PRO_Params.MaBTime * 10.67);
		printf("\n\t\t  MAB TIME: %d micro sec",MABTime);
		printf("\n\t\t  SEND REFRESH RATE: %d packets/sec",PRO_Params.RefreshRate);
		// return success
		return TRUE;
		
		
	}
	
}

- (void) refreshSerialList {
	serialDevices = [NSMutableSet set];
	
	io_object_t serialPort;
	io_iterator_t serialPortIterator;
	
	IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(kIOSerialBSDServiceValue), &serialPortIterator);
	while (serialPort = IOIteratorNext(serialPortIterator)) {
		CFTypeRef	bsdPathAsCFString;
		
		bsdPathAsCFString = IORegistryEntryCreateCFProperty(serialPort,
                                                            CFSTR(kIOCalloutDeviceKey),
                                                            kCFAllocatorDefault,
                                                            0);
		[serialDevices addObject:(NSString*)bsdPathAsCFString];
		CFRelease(bsdPathAsCFString);
		
		
		
		IOObjectRelease(serialPort);
	}		
	
	for(NSString * port in serialDevices){
		NSLog(@"Found serial device: %@",port);
		if(![port isEqualToString:@"/dev/cu.Bluetooth-PDA-Sync"]){
			if([self openConnection:port]){
				NSLog(@"Connected to: %@",port);			
				break;
			}
		}
		if(serialFileDescriptor != -1)
			close(serialFileDescriptor);		
		
	}	
	
	/*	// remove everything from the pull down list
	 [serialListPullDown removeAllItems];
	 
	 // ask for all the serial ports
	 
	 // loop through all the serial ports and add them to the array
	 while (serialPort = IOIteratorNext(serialPortIterator)) {
	 [serialListPullDown addItemWithTitle:
	 (NSString*)IORegistryEntryCreateCFProperty(serialPort, CFSTR(kIOCalloutDeviceKey),  kCFAllocatorDefault, 0)];
	 IOObjectRelease(serialPort);
	 }
	 
	 // add the selected text to the top
	 [serialListPullDown insertItemWithTitle:selectedText atIndex:0];
	 [serialListPullDown selectItemAtIndex:0];*/
	
	IOObjectRelease(serialPortIterator);
}
@end
