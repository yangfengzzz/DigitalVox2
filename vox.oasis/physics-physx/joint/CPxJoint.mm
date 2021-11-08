//
//  CPxJoint.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxJoint.h"
#import "CPxJoint+Internal.h"
#import "../CPxConstraint+Internal.h"
#import "../CPxRigidActor+Internal.h"

@implementation CPxJoint

- (instancetype)initWithJoint:(PxJoint *)joint {
    self = [super init];
    if (self) {
        _c_joint = joint;
    }
    return self;
}

- (void)setActors:(CPxRigidActor *)actor0 :(CPxRigidActor *)actor1 {
    _c_joint->setActors(actor0.c_actor, actor1.c_actor);
}

- (void)setLocalPose:(CPxJointActorIndex)actor :(simd_float3)position rotation:(simd_quatf)rotation {
    _c_joint->setLocalPose(PxJointActorIndex::Enum(actor), PxTransform(PxVec3(position.x, position.y, position.z),
            PxQuat(rotation.vector.x, rotation.vector.y,
                    rotation.vector.z, rotation.vector.w)));
}

- (void)getLocalPose:(CPxJointActorIndex)actor :(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose = _c_joint->getLocalPose(PxJointActorIndex::Enum(actor));
    *position = simd_make_float3(pose.p.x, pose.p.y, pose.p.z);
    *rotation = simd_quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
}

- (void)getRelativeTransform:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose = _c_joint->getRelativeTransform();
    *position = simd_make_float3(pose.p.x, pose.p.y, pose.p.z);
    *rotation = simd_quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
}

- (simd_float3)getRelativeLinearVelocity {
    PxVec3 vel = _c_joint->getRelativeLinearVelocity();
    return simd_make_float3(vel.x, vel.y, vel.z);
}

- (simd_float3)getRelativeAngularVelocity {
    PxVec3 vel = _c_joint->getRelativeAngularVelocity();
    return simd_make_float3(vel.x, vel.y, vel.z);
}

- (void)setBreakForce:(float)force :(float)torque {
    _c_joint->setBreakForce(force, torque);
}

- (void)getBreakForce:(float *)force :(float *)torque {
    _c_joint->getBreakForce(*force, *torque);
}

- (void)setConstraintFlag:(CPxConstraintFlag)flags :(bool)value {
    _c_joint->setConstraintFlag(PxConstraintFlag::Enum(flags), value);
}

- (void)setInvMassScale0:(float)invMassScale {
    _c_joint->setInvMassScale0(invMassScale);
}

- (float)getInvMassScale0 {
    return _c_joint->getInvMassScale0();
}

- (void)setInvInertiaScale0:(float)invInertiaScale {
    _c_joint->setInvInertiaScale0(invInertiaScale);
}

- (float)getInvInertiaScale0 {
    return _c_joint->getInvInertiaScale0();
}

- (void)setInvMassScale1:(float)invMassScale {
    _c_joint->setInvMassScale1(invMassScale);
}

- (float)getInvMassScale1 {
    return _c_joint->getInvMassScale1();
}

- (void)setInvInertiaScale1:(float)invInertiaScale {
    _c_joint->setInvInertiaScale1(invInertiaScale);
}

- (float)getInvInertiaScale1 {
    return _c_joint->getInvInertiaScale1();
}

- (CPxConstraint *)getConstraint {
    return [[CPxConstraint alloc] initWithConstraint:_c_joint->getConstraint()];
}

@end
