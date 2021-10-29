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
#include <functional>

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

- (CPxScene *)createSceneWith:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onContactEnter
                onContactExit:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onContactExit
                onContactStay:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onContactStay
               onTriggerEnter:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onTriggerEnter
                onTriggerExit:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onTriggerExit
                onTriggerStay:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onTriggerStay {
    class PxSimulationEventCallbackWrapper : public PxSimulationEventCallback {
    public:
        std::function<void(CPxShape *obj1, CPxShape *obj2)> onContactEnter;
        std::function<void(CPxShape *obj1, CPxShape *obj2)> onContactExit;
        std::function<void(CPxShape *obj1, CPxShape *obj2)> onContactStay;

        std::function<void(CPxShape *obj1, CPxShape *obj2)> onTriggerEnter;
        std::function<void(CPxShape *obj1, CPxShape *obj2)> onTriggerExit;
        std::function<void(CPxShape *obj1, CPxShape *obj2)> onTriggerStay;

        PxSimulationEventCallbackWrapper(std::function<void(CPxShape *obj1, CPxShape *obj2)> onContactEnter,
                std::function<void(CPxShape *obj1, CPxShape *obj2)> onContactExit,
                std::function<void(CPxShape *obj1, CPxShape *obj2)> onContactStay,
                std::function<void(CPxShape *obj1, CPxShape *obj2)> onTriggerEnter,
                std::function<void(CPxShape *obj1, CPxShape *obj2)> onTriggerExit,
                std::function<void(CPxShape *obj1, CPxShape *obj2)> onTriggerStay) :
                onContactEnter(onContactEnter), onContactExit(onContactExit), onContactStay(onContactStay),
                onTriggerEnter(onTriggerEnter), onTriggerExit(onTriggerExit), onTriggerStay(onTriggerStay) {
        }

        void onConstraintBreak(PxConstraintInfo *, PxU32) override {
        }

        void onWake(PxActor **, PxU32) override {
        }

        void onSleep(PxActor **, PxU32) override {
        }

        void onContact(const PxContactPairHeader &, const PxContactPair *pairs, PxU32 nbPairs) override {
            for (PxU32 i = 0; i < nbPairs; i++) {
                const PxContactPair &cp = pairs[i];

                if (cp.events & (PxPairFlag::eNOTIFY_TOUCH_FOUND | PxPairFlag::eNOTIFY_TOUCH_CCD)) {
                    onContactEnter([[CPxShape alloc] initWithShape:cp.shapes[0]], [[CPxShape alloc] initWithShape:cp.shapes[1]]);
                } else if (cp.events & PxPairFlag::eNOTIFY_TOUCH_LOST) {
                    onContactExit([[CPxShape alloc] initWithShape:cp.shapes[0]], [[CPxShape alloc] initWithShape:cp.shapes[1]]);
                } else if (cp.events & PxPairFlag::eNOTIFY_TOUCH_PERSISTS) {
                    onContactStay([[CPxShape alloc] initWithShape:cp.shapes[0]], [[CPxShape alloc] initWithShape:cp.shapes[1]]);
                }
            }
        }

        void onTrigger(PxTriggerPair *pairs, PxU32 count) override {
            for (PxU32 i = 0; i < count; i++) {
                const PxTriggerPair &tp = pairs[i];

                if (tp.status & PxPairFlag::eNOTIFY_TOUCH_FOUND) {
                    onTriggerEnter([[CPxShape alloc] initWithShape:tp.triggerShape], [[CPxShape alloc] initWithShape:tp.otherShape]);
                } else if (tp.status & PxPairFlag::eNOTIFY_TOUCH_LOST) {
                    onTriggerExit([[CPxShape alloc] initWithShape:tp.triggerShape], [[CPxShape alloc] initWithShape:tp.otherShape]);
                }
            }
        }

        void onAdvance(const PxRigidBody *const *, const PxTransform *, const PxU32) override {
        }
    };

    PxSimulationEventCallbackWrapper *simulationEventCallback =
            new PxSimulationEventCallbackWrapper(onContactEnter, onContactExit, onContactStay,
                    onTriggerEnter, onTriggerExit, onTriggerStay);

    PxSceneDesc sceneDesc(_physics->getTolerancesScale());
    sceneDesc.gravity = PxVec3(0.0f, -9.81f, 0.0f);
    sceneDesc.cpuDispatcher = PxDefaultCpuDispatcherCreate(1);
    sceneDesc.filterShader = PxDefaultSimulationFilterShader;
    sceneDesc.simulationEventCallback = simulationEventCallback;
    sceneDesc.kineKineFilteringMode = PxPairFilteringMode::eKEEP;
    sceneDesc.staticKineFilteringMode = PxPairFilteringMode::eKEEP;
    sceneDesc.flags |= PxSceneFlag::eENABLE_CCD;

    return [[CPxScene alloc] initWithScene:_physics->createScene(sceneDesc)];
}

@end
