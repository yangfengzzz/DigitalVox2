//
//  CPxRigidActor+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxRigidActor_Internal_h
#define CPxRigidActor_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxRigidActor ()

@property(nonatomic, readonly) PxRigidActor *c_actor;

- (instancetype)initWithActor:(PxRigidActor *)actor;

@end

#endif /* CPxRigidActor_Internal_h */
