//
//  CPxJointAngularLimitPair.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointAngularLimitPair_h
#define CPxJointAngularLimitPair_h

#import <Foundation/Foundation.h>
#import "CPxSpring.h"

@interface CPxJointAngularLimitPair : NSObject

- (instancetype)initWithHardLimit:(float)lowerLimit :(float)upperLimit :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)lowerLimit :(float)upperLimit :(CPxSpring*)spring;

@end

#endif /* CPxJointAngularLimitPair_h */
