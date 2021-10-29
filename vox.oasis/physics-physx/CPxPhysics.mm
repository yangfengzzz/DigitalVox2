//
//  CPxPhysics.m
//  vox.render
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxPhysics.h"
#import "CPxMaterial+Internal.h"
#import "CPxGeometry+Internal.h"
#import "CPxShape+Internal.h"
#import "CPxRigidStatic+Internal.h"
#import "CPxRigidDynamic+Internal.h"
#import "CPxScene+Internal.h"
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

    _physics = PxCreatePhysics(PX_PHYSICS_VERSION, *gFoundation, PxTolerancesScale(), false, nullptr);
}

- (CPxMaterial *)createMaterialWithStaticFriction:(float)staticFriction
                                  dynamicFriction:(float)dynamicFriction
                                      restitution:(float)restitution {
    return [[CPxMaterial alloc] initWithMaterial:_physics->createMaterial(staticFriction, dynamicFriction, restitution)];
}

- (CPxShape *)createShapeWithGeometry:(CPxGeometry *)geometry
                             material:(CPxMaterial *)material
                          isExclusive:(bool)isExclusive
                           shapeFlags:(uint8_t)shapeFlags {
    return [[CPxShape alloc] initWithShape:_physics->createShape(*geometry.c_geometry, *material.c_material,
            isExclusive, PxShapeFlags(shapeFlags))];
}

- (CPxRigidStatic *)createRigidStaticWithPosition:(simd_float3)position
                                         rotation:(simd_quatf)rotation {
    return [[CPxRigidStatic alloc]
            initWithStaticActor:_physics->createRigidStatic(PxTransform(PxVec3(position.x, position.y, position.z),
                    PxQuat(rotation.vector.x, rotation.vector.y,
                            rotation.vector.z, rotation.vector.w)))];
}

- (CPxRigidDynamic *)createRigidDynamicWithPosition:(simd_float3)position rotation:(simd_quatf)rotation {
    return [[CPxRigidDynamic alloc]
            initWithDynamicActor:_physics->createRigidDynamic(PxTransform(PxVec3(position.x, position.y, position.z),
                    PxQuat(rotation.vector.x, rotation.vector.y,
                            rotation.vector.z, rotation.vector.w)))];
}

- (CPxScene *)createScene {
    PxSceneDesc sceneDesc(_physics->getTolerancesScale());
    sceneDesc.gravity = PxVec3(0.0f, -9.81f, 0.0f);
    PxDefaultCpuDispatcher *gDispatcher = PxDefaultCpuDispatcherCreate(1);
    sceneDesc.cpuDispatcher = gDispatcher;
    sceneDesc.filterShader = PxDefaultSimulationFilterShader;

    return [[CPxScene alloc] initWithScene:_physics->createScene(sceneDesc)];
}

@end
