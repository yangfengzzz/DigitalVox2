//
//  CPxPrismaticJoint.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxPrismaticJoint.h"
#import "CPxJoint+Internal.h"
#import "CPxJointLinearLimitPair+Internal.h"

@implementation CPxPrismaticJoint

- (float)getPosition {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getPosition();
}

- (float)getVelocity {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getVelocity();
}

- (void)setLimit:(CPxJointLinearLimitPair *)limit {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setLimit(*limit.c_limit);
}

- (CPxJointLinearLimitPair *)getLimit {
    return [[CPxJointLinearLimitPair alloc] initWithLimit:static_cast<PxPrismaticJoint *>(super.c_joint)->getLimit()];
}

- (void)setPrismaticJointFlag:(CPxPrismaticJointFlag)flag :(bool)value {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setPrismaticJointFlag(PxPrismaticJointFlag::Enum(flag), value);
}

- (void)setProjectionLinearTolerance:(float)tolerance {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setProjectionLinearTolerance(tolerance);
}

- (float)getProjectionLinearTolerance {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getProjectionLinearTolerance();
}

- (void)setProjectionAngularTolerance:(float)tolerance {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setProjectionAngularTolerance(tolerance);
}

- (float)getProjectionAngularTolerance {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getProjectionAngularTolerance();
}


@end
