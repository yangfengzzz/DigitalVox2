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

@interface CPxPhysics : NSObject
- (CPxMaterial *)createMaterialWithStaticFriction:(float)staticFriction
                                  dynamicFriction:(float)dynamicFriction
                                      restitution:(float)restitution;

- (CPxShape *)createShapeWithGeometry:(CPxGeometry *)geometry
                             material:(CPxMaterial *)material
                          isExclusive:(bool)isExclusive
                           shapeFlags:(uint8_t)shapeFlags;

- (CPxRigidStatic *)createRigidStaticWithPosition:(simd_float3)position rotation:(simd_quatf)rotation;

- (CPxRigidDynamic *)createRigidDynamicWithPosition:(simd_float3)position rotation:(simd_quatf)rotation;

@end

#endif /* CPxPhysics_h */
