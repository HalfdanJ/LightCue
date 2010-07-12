//
//  DevicePropertyModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DeviceModel;

@interface DevicePropertyModel : NSManagedObject {
	
}

-(float)floatValue;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) DeviceModel * device;

@end

