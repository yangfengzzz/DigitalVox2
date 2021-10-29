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

@end

#endif /* CPxScene_h */
