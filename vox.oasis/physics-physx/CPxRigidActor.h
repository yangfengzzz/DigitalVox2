//
//  CPxRigidActor.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxRigidActor_h
#define CPxRigidActor_h

#import <Foundation/Foundation.h>
#import "CPxShape.h"

@interface CPxRigidActor : NSObject

- (bool)attachShapeWithShape:(CPxShape *)shape;

- (void)detachShapeWithShape:(CPxShape *)shape;

- (void)setGlobalPose:(simd_float3)position rotation:(simd_quatf)rotation;

- (void)getGlobalPose:(simd_float3 *)position rotation:(simd_quatf *)rotation;

@end

#endif /* CPxRigidActor_h */
