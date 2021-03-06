//
//  CPxPhysics.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxPhysics_h
#define CPxPhysics_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "CPxMaterial.h"
#import "CPxGeometry.h"
#import "CPxShape.h"
#import "CPxRigidStatic.h"
#import "CPxRigidDynamic.h"
#import "CPxScene.h"

#import "joint/CPxFixedJoint.h"
#import "joint/CPxRevoluteJoint.h"
#import "joint/CPxSphericalJoint.h"
#import "joint/CPxDistanceJoint.h"
#import "joint/CPxPrismaticJoint.h"
#import "joint/CPxD6Joint.h"

@interface CPxPhysics : NSObject
- (bool)initExtensions;

- (CPxMaterial *_Nonnull)createMaterialWithStaticFriction:(float)staticFriction
                                          dynamicFriction:(float)dynamicFriction
                                              restitution:(float)restitution;

- (CPxShape *_Nonnull)createShapeWithGeometry:(CPxGeometry *_Nonnull)geometry
                                     material:(CPxMaterial *_Nonnull)material
                                  isExclusive:(bool)isExclusive
                                   shapeFlags:(uint8_t)shapeFlags;

- (CPxRigidStatic *_Nonnull)createRigidStaticWithPosition:(simd_float3)position rotation:(simd_quatf)rotation;

- (CPxRigidDynamic *_Nonnull)createRigidDynamicWithPosition:(simd_float3)position rotation:(simd_quatf)rotation;

- (CPxScene *_Nonnull)createSceneWith:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onContactEnter
                        onContactExit:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onContactExit
                        onContactStay:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onContactStay
                       onTriggerEnter:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onTriggerEnter
                        onTriggerExit:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onTriggerExit
                        onTriggerStay:(void (^ _Nullable)(CPxShape *_Nonnull obj1, CPxShape *_Nonnull obj2))onTriggerStay;

//MARK: - Joint
- (CPxFixedJoint *_Nonnull)createFixedJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1;

- (CPxRevoluteJoint *_Nonnull)createRevoluteJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1;

- (CPxSphericalJoint *_Nonnull)createSphericalJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1;

- (CPxDistanceJoint *_Nonnull)createDistanceJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1;

- (CPxPrismaticJoint *_Nonnull)createPrismaticJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1;

- (CPxD6Joint *_Nonnull)createD6Joint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1;


@end

#endif /* CPxPhysics_h */
