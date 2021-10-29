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

@interface CPxPhysics : NSObject
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


@end

#endif /* CPxPhysics_h */
