//
//  DJOverlapSlider.h
//  Ballpark DJ
//
//  Created by Timothy Goodson on 7/6/12.
//  Copyright (c) 2012 BallparkDj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJOverlapSlider : UIView{
    float _delay;
    bool _topFirst;
    float _maxValueTop;
    float _maxValueBottom;
}
@property (retain, nonatomic) IBOutlet UIView *objectTop;
@property (retain, nonatomic) IBOutlet UIView *objectBottom;
@property (retain, nonatomic) IBOutlet UILabel *sliderLabel;
@property (retain, nonatomic) IBOutlet UIView *keyFirst;
@property (retain, nonatomic) IBOutlet UIView *keyLast;
@property (retain, nonatomic) IBOutlet UILabel *delayLabel;

@property(assign, nonatomic) float trailingDelay;
@property(assign, nonatomic) bool topFirst;
@property(assign, nonatomic) float maxValueTop;
@property(assign, nonatomic) float maxValueBottom;
@property(assign, nonatomic) CGPoint touchPos;
@end
