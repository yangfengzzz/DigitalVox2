//
//  CPxSphericalJoint.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxSphericalJoint_h
#define CPxSphericalJoint_h

#import "CPxJoint.h"
#import "CPxJointLimitCone.h"

enum CPxSphericalJointFlag {
    //!< the cone limit for the spherical joint is enabled
    eLIMIT_ENABLED = 1 << 1
};

@interface CPxSphericalJoint : CPxJoint
- (CPxJointLimitCone *)getLimitCone;

- (void)setLimitCone:(CPxJointLimitCone *)limit;

- (float)getSwingYAngle;

- (float)getSwingZAngle;

- (void)setSphericalJointFlag:(CPxSphericalJointFlag)flag :(bool)value;

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

@end

#endif /* CPxSphericalJoint_h */
