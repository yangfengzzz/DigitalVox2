//
//  CPxJointLimitCone.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLimitCone_h
#define CPxJointLimitCone_h

#import <Foundation/Foundation.h>

struct CPxSpring {
    //!< the spring strength of the drive: that is, the force proportional to the position error
    float stiffness;
    //!< the damping strength of the drive: that is, the force proportional to the velocity error
    float damping;
};

@interface CPxJointLimitCone : NSObject

- (instancetype)initWithHardLimit:(float)yLimitAngle :(float)zLimitAngle :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)yLimitAngle :(float)zLimitAngle :(struct CPxSpring)spring;

@end

#endif /* CPxJointLimitCone_h */
