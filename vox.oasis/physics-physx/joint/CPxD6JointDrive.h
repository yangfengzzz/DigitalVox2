//
//  CPxD6JointDrive.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxD6JointDrive_h
#define CPxD6JointDrive_h

#import "CPxSpring.h"

@interface CPxD6JointDrive : CPxSpring
//!< the force limit of the drive - may be an impulse or a force depending on PxConstraintFlag::eDRIVE_LIMITS_ARE_FORCES
@property(nonatomic, assign) float forceLimit;
//!< the joint drive flags
@property(nonatomic, assign) uint32_t flags;

- (instancetype)initWithLimitStiffness:(float)driveStiffness :(float)driveDamping :(float)driveForceLimit;

@end

#endif /* CPxD6JointDrive_h */
