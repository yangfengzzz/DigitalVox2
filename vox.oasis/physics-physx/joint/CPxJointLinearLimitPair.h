//
//  CPxJointLinearLimitPair.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLinearLimitPair_h
#define CPxJointLinearLimitPair_h

#import <Foundation/Foundation.h>
#import "CPxSpring.h"

struct CPxTolerancesScale {
    float length = 1.0;
    float speed = 10.0;
};

@interface CPxJointLinearLimitPair : NSObject

- (instancetype)initWithHardLimit:(CPxTolerancesScale)scale :(float)lowerLimit :(float)upperLimit :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)lowerLimit :(float)upperLimit :(struct CPxSpring)spring;

@end

#endif /* CPxJointLinearLimitPair_h */
