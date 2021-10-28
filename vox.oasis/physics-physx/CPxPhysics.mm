//
//  CPxPhysics.m
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxPhysics.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxPhysics {
    PxPhysics *_physics;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializePhysics];
    }
    return self;
}

- (void)initializePhysics {
    PxDefaultAllocator gAllocator;
    PxDefaultErrorCallback gErrorCallback;
    physx::PxFoundation *gFoundation = PxCreateFoundation(PX_PHYSICS_VERSION, gAllocator, gErrorCallback);

    _physics = PxCreatePhysics(PX_PHYSICS_VERSION, *gFoundation, PxTolerancesScale(), false, NULL);
}

@end
