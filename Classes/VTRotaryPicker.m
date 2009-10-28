//
//  VTRotaryPicker.m
//  RotaryPicker
//
//  Created by Vid Tadel on 8/26/09.
//  Copyright 2009 GuerillaCode. All rights reserved.
//

#import "VTRotaryPicker.h"
#define kMAXSLICECOUNT 12
#define kMINSLICECOUNT 4
#define kDEFAULTANGLE 45

#define degToRad( degrees ) ( degrees * M_PI / 180 )
#define radToDeg( radians ) ( radians * 180 / M_PI )

@implementation VTRotaryPicker
@synthesize delegate = _delegate, dataSource = _dataSource;

- (void)updateSlices {
	//update the slices (rotation) as per current orientation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:2.0f];
	for(VTRotaryPickerSliceView *slice in _sliceViews) {
		//rotate according to the selected slice
		//float angle = slice.sliceIndex*_currentSelectedSlice%8*kDEFAULTANGLE*2;
//		NSLog(@"%f, %f",slice.center.x, _rotatingView.center.x);
		if(slice.sliceIndex%8 >= 4 && _currentSelectedSlice < 4) {
			CGAffineTransform transform = CGAffineTransformRotate(slice.transform, degToRad(180));		
			slice.transform = transform;
		}
		else if(slice.sliceIndex%8 < 4 && _currentSelectedSlice > 4) {
			CGAffineTransform transform = CGAffineTransformRotate(slice.transform, degToRad(-180));		
			slice.transform = transform;
		}


		

	}


	[UIView commitAnimations];
}


- (void)reloadData {
	for(UIView *subView in _rotatingView.subviews)
		[subView removeFromSuperview];
	[_sliceViews removeAllObjects];
	int rowCount = [_dataSource numberOfSlicesForRotaryPicker:self];
	int i = 0;
	for(i = 0; i < rowCount; i++) {
		//ask the data source for all slices
		if([_dataSource rotaryPicker:self viewForSlice:i] == nil) {
			//calculate the frame and stuff
			CGRect frame = CGRectMake(_rotatingView.center.x, _rotatingView.center.y -  _rotatingView.frame.size.height/4,
									  _rotatingView.frame.size.width/3 , 60);
			
			//calculate the label angle and center the label
			float angle = kDEFAULTANGLE * i;
			//angle = angle * M_PI / 180.0;
			angle = degToRad(angle);
			
			CGAffineTransform transform = CGAffineTransformMakeRotation(angle);


			float x = cosf(angle) * self.frame.size.width/3;
			float y = sinf(angle) * self.frame.size.width/3;

			CGAffineTransform move = CGAffineTransformMakeTranslation(x , y);
			CGAffineTransform final =  CGAffineTransformConcat(transform, move);
			//let's not do this just yet
//			if(radToDeg(angle) > 180) {
//				CGAffineTransform mirror = CGAffineTransformMakeRotation(degToRad(180));
//				final = CGAffineTransformConcat(mirror, final);
//			}

			
			VTRotaryPickerSliceView *slice = [[VTRotaryPickerSliceView alloc] initWithFrame:frame];
			slice.center = _rotatingView.center;
			slice.textLabel.text = [_dataSource rotaryPicker:self titleForSlice:i];
			[_rotatingView addSubview:slice];
			slice.transform = final;
			slice.sliceIndex = i;
			[_sliceViews addObject:slice];
			[slice release];
			
		}
	}
}


- (void)rotateToIndex:(int)index animated:(BOOL)animated{
	if([_sliceViews count] < index || index < 0) {
		[[NSException exceptionWithName:NSInvalidArgumentException reason:@"index out of bounds" userInfo:nil] raise];
	}
	_currentSelectedSlice =index;
	float angle = kDEFAULTANGLE * (index%8);
	if(angle < 0)
		angle = -angle;
	angle = - degToRad(angle);
	
	if(animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.6f];
	}
	_rotatingView.transform = CGAffineTransformMakeRotation(angle);
	
	if(animated) {
		[UIView commitAnimations];
	}
	//[self updateSlices];
}

//Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:_rotatingView];
	
	// not touching on the right side! :)
	if(!CGRectContainsPoint(_touchFrame, [touch locationInView:self])) {
		return;
	}
		
	float x = (point.x - _rotatingView.center.x);
	float y = (point.y - _rotatingView.center.y);
	float tang = x >= 0 ? atanf(y/x) - M_PI_2 : atanf(y/x) + M_PI_2;
	diffAngle = tang;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touches canceled");	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//	NSLog(@"touches");	
	//calculate the angle and all
	_rotating = YES;
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:_rotatingView];
	float x = (point.x - _rotatingView.center.y);
	float y = (point.y - _rotatingView.center.y);
	float tang = x >= 0 ? atanf(y/x) - M_PI_2 : atanf(y/x) + M_PI_2;
	
	//rotate the view accordingly
	_rotatingView.transform = CGAffineTransformRotate(_rotatingView.transform, tang - diffAngle);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:_rotatingView];
	
	// not touching on the right side! :)
	if(!CGRectContainsPoint(_touchFrame, [touch locationInView:self]))
		return;
	//find out which slice was selected
	int selectedSlice = 0;
	if(_rotating) {
		_rotating = NO;
//		//maybe the user is rotating to a different slice?
//		CGPoint selectionPoint = CGPointMake(3*self.frame.size.width/4,2*self.frame.size.height/3);
		CGRect selectionRect = CGRectMake(self.center.x, 100, 160 , 20);
		NSLog(@"%@", NSStringFromCGRect(selectionRect));
		for(VTRotaryPickerSliceView *slice in _sliceViews) {
			NSLog(@"%@", NSStringFromCGRect(slice.frame));
			if(CGRectContainsPoint(selectionRect, slice.center)) {
				selectedSlice = slice.sliceIndex;
				break;
			}
		}
	}
	else {
		for(VTRotaryPickerSliceView *slice in _sliceViews) {
			if(CGRectContainsPoint(slice.frame, point)) {
				selectedSlice = slice.sliceIndex;
				break;
			}
			
		}
	}


	
	NSLog(@"selected slice: %d", selectedSlice);

	[self rotateToIndex:selectedSlice animated:YES];
}

//UIView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		//self.clearsContextBeforeDrawing = NO;
		self.backgroundColor = [UIColor clearColor];
		_sliceViews = [NSMutableArray new];
//		_rotatingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//		_rotatingView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.4];
		//_rotatingView.backgroundColor = [UIColor clearColor];
//		[_rotatingView addSubview:circleImage];
//		[circleImage release];
		_rotatingView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"circle" ofType:@"png"]]];
		[self addSubview:_rotatingView];
		[_rotatingView release];

		_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pokrov1.png"]];
		_backgroundView.transform = CGAffineTransformMakeRotation(degToRad(90));
		_backgroundView.transform = CGAffineTransformTranslate(_backgroundView.transform, 0, 15);
		[self addSubview:_backgroundView];
		[_backgroundView release];
		_touchFrame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	//CGContextRef context = UIGraphicsGetCurrentContext();
	//[[UIColor whiteColor] set];
	//CGContextFillEllipseInRect(context, rect);
	//[_rotatingView drawRect:rect];
	[self reloadData];
}


- (void)dealloc {
    [super dealloc];
}


@end

@implementation VTRotaryPickerSliceView

@synthesize textLabel, sliceIndex = _sliceIndex;
//UIView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-20, frame.size.height)];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.textColor = [UIColor blackColor];
		textLabel.font = [UIFont boldSystemFontOfSize:17.0];
		textLabel.textAlignment = UITextAlignmentRight;
		textLabel.numberOfLines = 0;
		[self addSubview:textLabel];
		[textLabel release];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	//CGContextStrokeRect(UIGraphicsGetCurrentContext(), self.frame);
}



- (void)dealloc {
    [super dealloc];
}

@end

