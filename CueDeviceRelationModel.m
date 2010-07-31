//
//  CueDeviceRelationModel.m
//  LightCue
//
//  Created by Jonas Jongejan on 16/07/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "CueDeviceRelationModel.h"


@implementation CueDeviceRelationModel

-(void) awakeFromFetch{
	[super awakeFromFetch];
	for(CueDevicePropertyRelationModel* rel in [self valueForKey:@"devicePropertyRelations"]){
		[rel addObserver:[self cue] forKeyPath:@"isLive" options:0 context:@"isLive"];
	}
}

- (CueModel *)cue 
{
    id tmpObject;
    
    [self willAccessValueForKey:@"cue"];
    tmpObject = [self primitiveValueForKey:@"cue"];
    [self didAccessValueForKey:@"cue"];
    
    return tmpObject;
}


- (void)addDevicePropertyRelationsObject:(CueDevicePropertyRelationModel *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"devicePropertyRelations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"devicePropertyRelations"] addObject:value];
    [self didChangeValueForKey:@"devicePropertyRelations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	
	[value addObserver:[self cue] forKeyPath:@"isLive" options:0 context:@"isLive"];
}

- (void)removeDevicePropertyRelationsObject:(CueDevicePropertyRelationModel *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"devicePropertyRelations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"devicePropertyRelations"] removeObject:value];
    [self didChangeValueForKey:@"devicePropertyRelations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	
	//[value removeObserver:[self cue] forKeyPath:@"isLive"];
}


@end
