//
//  SelectionController.h
//
//  Created by Jonas Jongejan on 09/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DimmerView.h"

@interface SelectionController : NSObject {
	IBOutlet NSArrayController * deviceArrayController;
	IBOutlet DimmerView * dimmerView;
}

-(void) setSelection:(NSArray *)selection;

@end
