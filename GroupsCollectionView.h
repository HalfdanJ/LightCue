//
//  GroupsCollectionView.h
//
//  Created by Jonas Jongejan on 10/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GroupsCollectionView : NSCollectionView {
	IBOutlet NSArrayController * devicesArrayController;
	IBOutlet NSArrayController * groupsArrayController;
}
- (NSUInteger)indexOfPoint:(NSPoint)aPoint;
@end
