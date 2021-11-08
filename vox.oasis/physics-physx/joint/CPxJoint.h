//
//  CPxJoint.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJoint_h
#define CPxJoint_h

#import <Foundation/Foundation.h>
#import "../CPxRigidActor.h"
#import "../CPxConstraint.h"

enum CPxJointActorIndex {
    CPxJointActorIndex_eACTOR0,
    CPxJointActorIndex_eACTOR1,
    CPxJointActorIndex_COUNT
};

@interface CPxJoint : NSObject

- (void)setActors:(CPxRigidActor *)actor0 :(CPxRigidActor *)actor1;

- (void)setLocalPose:(enum CPxJointActorIndex)actor :(simd_float3)position rotation:(simd_quatf)rotation;

- (void)getLocalPose:(enum CPxJointActorIndex)actor :(simd_float3 *)position rotation:(simd_quatf *)rotation;

- (void)getRelativeTransform:(simd_float3 *)position rotation:(simd_quatf *)rotation;

- (simd_float3)getRelativeLinearVelocity;

- (simd_float3)getRelativeAngularVelocity;

- (void)setBreakForce:(float)force :(float)torque;

- (void)getBreakForce:(float *)force :(float *)torque;

- (void)setConstraintFlag:(enum CPxConstraintFlag)flags :(bool)value;

- (void)setInvMassScale0:(float)invMassScale;

- (float)getInvMassScale0;

- (void)setInvInertiaScale0:(float)invInertiaScale;

- (float)getInvInertiaScale0;

- (void)setInvMassScale1:(float)invMassScale;

- (float)getInvMassScale1;

- (void)setInvInertiaScale1:(float)invInertiaScale;

- (float)getInvInertiaScale1;

- (CPxConstraint *)getConstraint;


@end


#endif /* CPxJoint_h */
