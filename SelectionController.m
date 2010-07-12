//
//  SelectionController.m
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "SelectionController.h"

@implementation SelectionController

-(void) awakeFromNib{
	[self bind:@"selection" toObject:deviceArrayController withKeyPath:@"selectedObjects" options:nil];
	[dimmerView bind:@"selection" toObject:deviceArrayController withKeyPath:@"selectedObjects" options:nil];
}

-(void) setSelection:(NSArray *)selection{	
}	

-(NSArray*) selection {
	return nil;
}

@end
