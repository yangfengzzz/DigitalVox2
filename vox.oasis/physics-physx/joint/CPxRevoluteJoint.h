//
//  CPxRevoluteJoint.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxRevoluteJoint_h
#define CPxRevoluteJoint_h

#import "CPxJoint.h"
#import "CPxJointAngularLimitPair.h"

enum CPxRevoluteJointFlag {
    //!< enable the limit
    eLIMIT_ENABLED = 1 << 0,
    //!< enable the drive
    eDRIVE_ENABLED = 1 << 1,
    //!< if the existing velocity is beyond the drive velocity, do not add force
    eDRIVE_FREESPIN = 1 << 2
};

@interface CPxRevoluteJoint : CPxJoint

- (float)getAngle;

- (float)getVelocity;

- (void)setLimit:(CPxJointAngularLimitPair *)limits;

- (CPxJointAngularLimitPair *)getLimit;

- (void)setDriveVelocity:(float)velocity;

- (float)getDriveVelocity;

- (void)setDriveForceLimit:(float)limit;

- (float)getDriveForceLimit;

- (void)setDriveGearRatio:(float)ratio;

- (float)getDriveGearRatio;

- (void)setRevoluteJointFlag:(CPxRevoluteJointFlag)flag :(bool)value;

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

- (void)setProjectionAngularTolerance:(float)tolerance;

- (float)getProjectionAngularTolerance;

@end

#endif /* CPxRevoluteJoint_h */
