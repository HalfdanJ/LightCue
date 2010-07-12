//
//  ViewController.m
//
//  Created by Jonas Jongejan on 10/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "ViewController.h"
#import "DeviceModel.h"
#import "DeviceGroupModel.h"



@implementation ViewController
-(void)awakeFromNib{
	[devicesCollectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
	[groupsCollectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
	

}

- (BOOL)collectionView:(NSCollectionView *)cv writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
	if(cv == devicesCollectionView){
		NSArray *devices = [[devicesCollectionView content] objectsAtIndexes:indexes];	
		NSMutableArray * indexArray = [NSMutableArray arrayWithCapacity:[devices count]];
		for(DeviceModel * device in devices){
			[indexArray addObject:[NSNumber numberWithInt:[[devicesCollectionView content] indexOfObject:device]]];
		}
		
		if ([indexes count] > 0) {
			[pasteboard clearContents];
			[pasteboard declareTypes:[NSArray arrayWithObject:@"DevicesDataType"] owner:self];
			return [pasteboard setPropertyList:indexArray forType:@"DevicesDataType"];
		}
		
	}
	
	
	return NO;
}


@end
