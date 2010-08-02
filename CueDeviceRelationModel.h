//
//  CueDeviceRelationModel.h
//  LightCue
//
//  Created by Jonas Jongejan on 16/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CueDevicePropertyRelationModel.h"
#import "LightCueModel.h"

@interface CueDeviceRelationModel : NSManagedObject <NSKeyedArchiverDelegate> {

}

- (LightCueModel *)cue;


// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addDevicePropertyRelationsObject:(CueDevicePropertyRelationModel *)value;
- (void)removeDevicePropertyRelationsObject:(CueDevicePropertyRelationModel *)value;


@end
