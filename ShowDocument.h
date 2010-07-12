//
//  MyDocument.h
//  LightCue
//
//  Created by Jonas Jongejan on 11/06/10.
//  Copyright HalfdanJ 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>

@interface ShowDocument : NSPersistentDocument {
	IBOutlet NSArrayController * devicesArrayController;
	IBOutlet NSArrayController * groupsArrayController;
}

@end
