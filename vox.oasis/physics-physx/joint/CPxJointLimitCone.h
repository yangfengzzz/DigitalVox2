//
//  CPxJointLimitCone.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLimitCone_h
#define CPxJointLimitCone_h

#import <Foundation/Foundation.h>
#import "CPxSpring.h"

@interface CPxJointLimitCone : NSObject

- (instancetype)initWithHardLimit:(float)yLimitAngle :(float)zLimitAngle :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)yLimitAngle :(float)zLimitAngle :(CPxSpring*)spring;

@end

#endif /* CPxJointLimitCone_h */
