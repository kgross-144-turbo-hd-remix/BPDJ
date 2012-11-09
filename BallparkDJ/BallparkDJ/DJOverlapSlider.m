//
//  DJOverlapSlider.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 7/6/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJOverlapSlider.h"
//#define sliderCenter = 189

@interface DJOverlapSlider () {
    NSNotification* _valueDidChangeNotification;
}
@end

@implementation DJOverlapSlider
@synthesize objectTop;
@synthesize objectBottom;
@synthesize sliderLabel;
@synthesize keyFirst;
@synthesize keyLast;
@synthesize delayLabel;
@synthesize trailingDelay = _delay;
@synthesize topFirst = _topFirst;
@synthesize maxValueTop = _maxValueTop;
@synthesize maxValueBottom = _maxValueBottom;
@synthesize touchPos;
float const _sliderCenter = 151.5f;

-(void)setTrailingDelay:(float)trailingDelay{
    
    if (_topFirst) {
        if (trailingDelay <= _maxValueTop) {
            _delay = trailingDelay;
        } else {
            _delay = _maxValueTop;
        }
    } else {
        if (trailingDelay <= _maxValueBottom) {
            _delay = trailingDelay;
        } else {
            _delay = _maxValueBottom;
        }
    }
    //[self setMaxValueTop:self.maxValueTop];
    //[self setMaxValueBottom:self.maxValueBottom];
    /*[self.objectTop setFrame:CGRectMake(_sliderCenter - self.maxValueTop + self.trailingDelay*5, 
                                        self.objectTop.frame.origin.y, self.maxValueTop*10, 
                                        self.objectTop.frame.size.height)];
    [self.objectBottom setFrame:CGRectMake(_sliderCenter - self.trailingDelay*5,                                            
                                           self.objectBottom.frame.origin.y, 
                                           self.maxValueBottom*10, 
                                           self.objectBottom.frame.size.height)];*/
}

-(void)setMaxValueTop:(float)maxValueTop{
    if (maxValueTop > 20) {
        maxValueTop = 20;
    }
    _maxValueTop = maxValueTop;
    /*[self.objectTop setFrame:CGRectMake(self.objectTop.frame.origin.x - maxValueTop/2, 
                                        self.objectTop.frame.origin.y, maxValueTop*10, 
                                        self.objectTop.frame.size.height)];*/
    [self.objectTop setFrame:CGRectMake(_sliderCenter - maxValueTop*10 + self.trailingDelay*5, 
                                        self.objectTop.frame.origin.y, maxValueTop*10, 
                                        self.objectTop.frame.size.height)];
    NSString* overLapDisplay = nil;
    if (_topFirst) {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
    } else {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
    }
    self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
}

-(void)setMaxValueBottom:(float)maxValueBottom{
    if (maxValueBottom > 20) {
        maxValueBottom = 20;
    }
    _maxValueBottom = maxValueBottom;
    /*[self.objectBottom setFrame:CGRectMake(self.objectTop.frame.origin.x + _delay*10,                                            
                                           self.objectBottom.frame.origin.y, 
                                           maxValueBottom*10, 
                                           self.objectBottom.frame.size.height)];*/
    [self.objectBottom setFrame:CGRectMake(_sliderCenter - self.trailingDelay*5,                                            
                                           self.objectBottom.frame.origin.y, 
                                           maxValueBottom*10, 
                                           self.objectBottom.frame.size.height)];
    NSString* overLapDisplay = nil;
    if (_topFirst) {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
    } else {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
    }
    self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray* xib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DJOverlapSlider class]) owner:self options:nil];
        self = [xib objectAtIndex:0];
        UIGestureRecognizer* slidr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlide:)];
        [self addGestureRecognizer:slidr];
        [slidr release];
        _maxValueBottom = 10.0f;
        _maxValueTop = 10.0f;
        self.keyFirst.backgroundColor = [UIColor colorWithRed:1 
                                                        green:1 
                                                         blue:0.4
                                                        alpha:0.5];
        [self.keyFirst setNeedsLayout];
        self.keyLast.backgroundColor = [UIColor colorWithRed:0.7
                                                       green:0.8
                                                        blue:1
                                                       alpha:0.5];
        NSString* overLapDisplay = nil;
        if (_topFirst) {
            overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
        } else {
            overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
        }
        self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
    }
    [self retain];
    return self;
}

-(void)handleSlide:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.touchPos = [gestureRecognizer translationInView:self];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged || 
        gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        float translation = self.touchPos.x - [gestureRecognizer translationInView:self].x;
         self.touchPos = [gestureRecognizer translationInView:self];

        
        if ((self.objectTop.frame.origin.x + translation >= 
             (self.objectBottom.frame.origin.x - self.objectTop.frame.size.width - translation)) 
            && 
            (self.objectTop.frame.origin.x + translation <= 
             (self.objectBottom.frame.origin.x + self.objectBottom.frame.size.width - translation))) {
            
            [self.objectTop setFrame:
             CGRectMake(self.objectTop.frame.origin.x + translation, 
                        self.objectTop.frame.origin.y, 
                        self.objectTop.frame.size.width, 
                        self.objectTop.frame.size.height)];
            [self.objectBottom setFrame:
             CGRectMake(self.objectBottom.frame.origin.x - translation, 
                        self.objectBottom.frame.origin.y, 
                        self.objectBottom.frame.size.width, 
                        self.objectBottom.frame.size.height)];
            if (self.objectTop.frame.origin.x  > self.objectBottom.frame.origin.x + self.objectBottom.frame.size.width) {
                [self.objectTop setFrame:
                 CGRectMake(self.objectBottom.frame.origin.x+ self.objectBottom.frame.size.width, 
                            self.objectTop.frame.origin.y, 
                            self.objectTop.frame.size.width, 
                            self.objectTop.frame.size.height)];
            }
        }
        

        

        if (self.objectTop.frame.origin.x <= self.objectBottom.frame.origin.x) {
            self.topFirst = YES;
            self.keyFirst.backgroundColor = [UIColor colorWithRed:1 
                                                            green:1 
                                                             blue:0.4
                                                            alpha:0.5];
            [self.keyFirst setNeedsLayout];
            self.keyLast.backgroundColor = [UIColor colorWithRed:0.7
                                                           green:0.8
                                                            blue:1
                                                           alpha:0.5];
            [self.keyLast setNeedsLayout];
            self.trailingDelay = -(self.objectTop.frame.origin.x - 
                                  self.objectBottom.frame.origin.x)/10;
            NSString* overLapDisplay = nil;
            if (_topFirst) {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
            } else {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
            }
            self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
        } else {
            self.topFirst = NO;
            self.keyLast.backgroundColor = [UIColor colorWithRed:1 
                                                            green:1 
                                                             blue:0.4 
                                                            alpha:0.5];
            self.keyFirst.backgroundColor = [UIColor colorWithRed:0.7 
                                                           green:0.8 
                                                            blue:1
                                                           alpha:0.5];
            self.trailingDelay = -(self.objectBottom.frame.origin.x - 
                                  self.objectTop.frame.origin.x)/10;
            NSString* overLapDisplay = nil;
            if (_topFirst) {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
            } else {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
            }
            self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _valueDidChangeNotification = [NSNotification notificationWithName:@"DJSliderValueDidChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:_valueDidChangeNotification];
    }
   
}

- (void)dealloc {
    [objectTop release];
    [objectBottom release];
    [sliderLabel release];
    [keyFirst release];
    [keyLast release];
    [delayLabel release];
    [super dealloc];
}
@end
