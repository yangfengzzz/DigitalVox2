//
//  CPxScene.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxScene_h
#define CPxScene_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "CPxRigidActor.h"

@interface CPxScene : NSObject

- (void)setGravity:(simd_float3)vec;

- (void)simulate:(float)elapsedTime;

- (bool)fetchResults:(bool)block;

- (void)addActorWith:(CPxRigidActor *)actor;

- (void)removeActorWith:(CPxRigidActor *)actor;

- (bool)raycastSingleWith:(simd_float3)origin
                  unitDir:(simd_float3)unitDir
                 distance:(float)distance
              outPosition:(simd_float3 *)outPosition
                outNormal:(simd_float3 *)outNormal
              outDistance:(float *)outDistance
                 outIndex:(int *)outIndex;

@end

#endif /* CPxScene_h */
