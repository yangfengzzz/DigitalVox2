//
//  CPxRigidDynamic.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxRigidDynamic.h"
#import "CPxRigidDynamic+Internal.h"
#import "CPxRigidActor+Internal.h"

@implementation CPxRigidDynamic {
}

// MARK: - Initialization

- (instancetype)initWithDynamicActor:(PxRigidDynamic *)actor {
    self = [super initWithActor:actor];
    return self;
}

- (void)addForceWith:(simd_float3)force {
    static_cast<PxRigidDynamic *>(super.c_actor)->addForce(PxVec3(force.x, force.y, force.z));
}

- (void)addTorqueWith:(simd_float3)torque {
    static_cast<PxRigidDynamic *>(super.c_actor)->addTorque(PxVec3(torque.x, torque.y, torque.z));
}

@end
