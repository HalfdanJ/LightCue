//
//  DimmerView.h
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DimmerView : NSView {
	NSArray * selection;
	NSMutableArray * valueCache;
}

-(void) setSelection:(NSArray *)selection;

@end
