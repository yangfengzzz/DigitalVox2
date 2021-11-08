//
//  CPxRevoluteJoint.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxRevoluteJoint.h"
#import "CPxJoint+Internal.h"
#import "CPxJointAngularLimitPair+Internal.h"

@implementation CPxRevoluteJoint

- (float)getAngle {
    return static_cast<PxRevoluteJoint *>(super.c_joint)->getAngle();
}

- (float)getVelocity {
    return static_cast<PxRevoluteJoint *>(super.c_joint)->getVelocity();
}

- (void)setLimit:(CPxJointAngularLimitPair *)limits {
    static_cast<PxRevoluteJoint *>(super.c_joint)->setLimit(*limits.c_limit);
}

- (CPxJointAngularLimitPair *)getLimit {
    return [[CPxJointAngularLimitPair alloc] initWithLimit:static_cast<PxRevoluteJoint *>(super.c_joint)->getLimit()];
}

- (void)setDriveVelocity:(float)velocity {
    static_cast<PxRevoluteJoint *>(super.c_joint)->setDriveVelocity(velocity);
}

- (float)getDriveVelocity {
    return static_cast<PxRevoluteJoint *>(super.c_joint)->getDriveVelocity();
}

- (void)setDriveForceLimit:(float)limit {
    static_cast<PxRevoluteJoint *>(super.c_joint)->setDriveForceLimit(limit);
}

- (float)getDriveForceLimit {
    return static_cast<PxRevoluteJoint *>(super.c_joint)->getDriveForceLimit();
}

- (void)setDriveGearRatio:(float)ratio {
    static_cast<PxRevoluteJoint *>(super.c_joint)->setDriveGearRatio(ratio);
}

- (float)getDriveGearRatio {
    return static_cast<PxRevoluteJoint *>(super.c_joint)->getDriveGearRatio();
}

- (void)setRevoluteJointFlag:(CPxRevoluteJointFlag)flag :(bool)value {
    static_cast<PxRevoluteJoint *>(super.c_joint)->setRevoluteJointFlag(PxRevoluteJointFlag::Enum(flag), value);
}

- (void)setProjectionLinearTolerance:(float)tolerance {
    static_cast<PxRevoluteJoint *>(super.c_joint)->setProjectionLinearTolerance(tolerance);
}

- (float)getProjectionLinearTolerance {
    return static_cast<PxRevoluteJoint *>(super.c_joint)->getProjectionLinearTolerance();
}

- (void)setProjectionAngularTolerance:(float)tolerance {
    static_cast<PxRevoluteJoint *>(super.c_joint)->setProjectionAngularTolerance(tolerance);
}

- (float)getProjectionAngularTolerance {
    return static_cast<PxRevoluteJoint *>(super.c_joint)->getProjectionAngularTolerance();
}

@end
