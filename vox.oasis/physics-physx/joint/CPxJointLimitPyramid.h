//
//  CPxJointLimitPyramid.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLimitPyramid_h
#define CPxJointLimitPyramid_h

#import <Foundation/Foundation.h>
#import "CPxSpring.h"

@interface CPxJointLimitPyramid : NSObject

- (instancetype)initWithHardLimit:(float)yLimitAngleMin :(float)yLimitAngleMax :(float)zLimitAngleMin :(float)zLimitAngleMax :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)yLimitAngleMin :(float)yLimitAngleMax :(float)zLimitAngleMin :(float)zLimitAngleMax :(CPxSpring *)spring;

@end

#endif /* CPxJointLimitPyramid_h */
