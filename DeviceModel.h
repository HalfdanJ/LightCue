//
//  DeviceModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LightCueModel;
@class CueModel;
@class DevicePropertyModel;

@interface DeviceModel : NSManagedObject {
	DevicePropertyModel * _dimmerStore;
	
	//For easy binding, simply a link to the selected cue in the cue list
	CueModel * selectedCue;
}

@property (nonatomic, retain) NSSet* properties;
@property (nonatomic, retain) NSNumber * deviceNumber;
@property (readonly, retain) DevicePropertyModel * dimmer;
@property (nonatomic, retain) NSSet* addresses;
@property (retain) NSArray * addressesToken;
@property (readonly, retain) NSString * fullName;
@property (readwrite, retain) CueModel * selectedCue;

@property (readonly) BOOL propertySetInSelectedCue;
@property (readonly) BOOL isRunning;
@property (readonly) float percentageLiveInSelectedCue;

-(DevicePropertyModel*) getProperty:(NSString*)name;
-(NSString*) fullName;
-(DevicePropertyModel *) dimmer;
-(void) clearDimmer;
-(void) storeProperties;


- (BOOL) propertySetInCue:(CueModel*)cue;

@end




@interface DeviceModel (CoreDataGeneratedAccessors)
- (void)addPropertiesObject:(NSManagedObject *)value;
- (void)removePropertiesObject:(NSManagedObject *)value;
- (void)addProperties:(NSSet *)value;
- (void)removeProperties:(NSSet *)value;

- (void)addAddressesObject:(NSManagedObject *)value;
- (void)removeAddressesObject:(NSManagedObject *)value;
- (void)addAddresses:(NSSet *)value;
- (void)removeAddresses:(NSSet *)value;
@end


