//
//  VTRotaryPicker.h
//  RotaryPicker
//
//  Created by Vid Tadel on 8/26/09.
//  Copyright 2009 GuerillaCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VTRotaryPickerDataSource;
@protocol VTRotaryPickerDelegate;


@interface VTRotaryPicker : UIView {

	id <VTRotaryPickerDataSource> _dataSource;
	id <VTRotaryPickerDelegate> _delegate;
	CGRect _touchFrame;
	
	UIView *_rotatingView;
	UIImageView *_backgroundView;
	float diffAngle;
	BOOL _rotating;
  BOOL _rotate;
	
	NSMutableArray *_sliceViews;
	int _currentSelectedSlice;
}

@property (nonatomic, assign) id <VTRotaryPickerDataSource> dataSource;
@property (nonatomic, assign) id <VTRotaryPickerDelegate> delegate;

- (void)reloadData;

@end

@protocol VTRotaryPickerDataSource <NSObject>

- (int)numberOfSlicesForRotaryPicker:(VTRotaryPicker *)picker;
- (UIView *)rotaryPicker:(VTRotaryPicker *)picker viewForSlice:(int)sliceIndex;
- (UIView *)rotaryPicker:(VTRotaryPicker *)picker highlightedViewForSlice:(int)sliceIndex;
- (NSString *)rotaryPicker:(VTRotaryPicker *)picker titleForSlice:(int)sliceIndex;

@end

@protocol VTRotaryPickerDelegate <NSObject>

- (void)rotaryPicker:(VTRotaryPicker *)picker willSelectSlice:(int)sliceIndex;
- (void)rotaryPicker:(VTRotaryPicker *)picker didSelectSlice:(int)sliceIndex;

@end

@interface VTRotaryPickerSliceView : UIView
{
	UIImageView *_backgroundView;
	UILabel *textLabel;
	int _sliceIndex;
}
@property (nonatomic, retain) UILabel *textLabel;
@property (assign) int sliceIndex;

@end


