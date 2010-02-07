//
//  RotaryPickerAppDelegate.m
//  RotaryPicker
//
//  Created by Vid Tadel on 8/26/09.
//  Copyright GuerillaCode 2009. All rights reserved.
//

#import "RotaryPickerAppDelegate.h"

#define lolz [NSArray arrayWithObjects:@"one",@"two",@"three",@"four",@"5",@"6",@"7",@"8",nil]//,@"krompir",@"zelje",nil]
//#define lolz [NSArray arrayWithObjects:@"sir",@"pica",@"kaneloni",nil]
@implementation RotaryPickerAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	window.backgroundColor = [UIColor clearColor];
	VTRotaryPicker *picker = [[VTRotaryPicker alloc] initWithFrame:CGRectMake(0, 480-320, 320, 320)];
	picker.transform = CGAffineTransformMakeRotation(-M_PI/2);
	picker.dataSource = self;
	[window addSubview:picker];
	[picker release];
    // Override point for customization after application launch
    [window makeKeyAndVisible];
	[picker reloadData];
	[picker rotateToIndex:2 animated:YES];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

- (int)numberOfSlicesForRotaryPicker:(VTRotaryPicker *)picker {
	return [lolz count];
}
- (UIView *)rotaryPicker:(VTRotaryPicker *)picker viewForSlice:(int)sliceIndex {
	return nil;
}
- (UIView *)rotaryPicker:(VTRotaryPicker *)picker highlightedViewForSlice:(int)sliceIndex {
	return nil;
}

- (NSString *)rotaryPicker:(VTRotaryPicker *)picker titleForSlice:(int)sliceIndex {
	return [lolz objectAtIndex:sliceIndex];
}


@end
