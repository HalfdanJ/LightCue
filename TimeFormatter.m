//
//  TimeFormatter.m
//
//  Created by Jonas Jongejan on 18/06/10.
//  Copyright 2010 HalfdanJ. All rights reserved.
//

#import "TimeFormatter.h"

@implementation TimeFormatter

-(NSString *) stringForObjectValue:(id)obj{
	double val = [obj doubleValue];
	
	//val = 3;
	
	
	int minutes = floor(val/60.0);
	int seconds = floor(val) - minutes*60;
	double dmillis = (val - seconds - minutes*60)*100;
	int millis = round(dmillis);
	//NSLog(@"%i %i %f = %i %f",minutes,seconds,dmillis,millis,(val - seconds - minutes*60));	
	NSString * min;
	if(minutes > 9){
		min = [NSString stringWithFormat:@"%i:",minutes];
	} else if(minutes > 0){
		min = [NSString stringWithFormat:@"0%i:",minutes];
	} else {
		min = [NSString stringWithFormat:@"00:"];
	}
	
	
	NSString * sec;
	if(seconds > 9){
		sec = [NSString stringWithFormat:@"%i.",seconds];
	} else if(seconds > 0){
		sec = [NSString stringWithFormat:@"0%i.",seconds];
	} else {
		sec = [NSString stringWithFormat:@"00."];
	}
	
	NSString * mil;
	if(millis < 10){
		mil = [NSString stringWithFormat:@"0%i",millis];
	} else if(millis < 100){
		mil = [NSString stringWithFormat:@"%i",millis];
	} else if(millis < 1000){
		mil = [NSString stringWithFormat:@"%i",millis];
	} else {
		mil = [NSString stringWithFormat:@"00"];
	}
	
	
	return [NSString stringWithFormat:@"%@%@%@",min,sec,mil];	
}

-(BOOL) getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error{
	
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	
	
	NSNumber * minutes = [NSNumber numberWithInt:0];
	NSNumber * seconds;
	NSNumber * millis = [NSNumber numberWithInt:0];
	
	NSString * workingString = [NSString stringWithString:string];
	
	seconds = [f numberFromString:workingString];
	if(seconds != nil){		
		*obj = seconds;
		
		return YES;
	}
	
	seconds = [NSNumber numberWithInt:0];
	
	NSRange colon = [workingString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
	BOOL minutesFound = NO;
	if((int)colon.location > 0){
		NSArray * components = [workingString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
		if([components count] > 2){
			return NO;
		}
		
		minutes = [f numberFromString:[components objectAtIndex:0]];
		if(minutes == nil){
			return NO;
		}
		
		workingString = [components objectAtIndex:1];
		minutesFound = YES;
		
	} else if((int)colon.location == 0){
		return NO;
	}
	
	
	NSRange dot = [workingString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
	
	if((int)dot.location > 0){
		NSArray * components = [workingString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
		if([components count] > 2){
			return NO;
		}
		
		seconds = [f numberFromString:[components objectAtIndex:0]];
		if(seconds == nil){
			return NO;
		}
		
		millis = [f numberFromString:[NSString stringWithFormat:@",%@",[components objectAtIndex:1]]];
		if(millis == nil || [millis doubleValue] >= 1){
			return NO;
		}
		
		millis = [NSNumber numberWithDouble:[millis doubleValue]*100];
		
		
	} else if((int)dot.location == 0 && minutesFound){
		return NO;
	} else if((int)dot.location == 0 && !minutesFound){		
		NSArray * components = [workingString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
		if([components count] == 2){			
			millis = [f numberFromString:[NSString stringWithFormat:@",%@",[components objectAtIndex:1]]];
			if(millis == nil || [millis doubleValue] >= 1){
				return NO;
			}
			
			millis = [NSNumber numberWithDouble:[millis doubleValue]*100];
		}
		
	}  else if((int)dot.location == -1){
		seconds = [f numberFromString:workingString];
		if(seconds == nil){
			return NO;
		}
		
	} else {
		return NO;	
	}
	
	
	
	
	*obj = [NSNumber numberWithDouble:([millis doubleValue]/100.0 + [seconds doubleValue] + [minutes doubleValue] * 60.0)];
	
	//NSLog(@"Result %@ (%@:%@.%@)",*obj,minutes,seconds,millis);
	
	return YES;
}
@end
