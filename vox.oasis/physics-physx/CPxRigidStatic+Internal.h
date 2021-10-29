//
//  CPxRigidStatic+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxRigidStatic_Internal_h
#define CPxRigidStatic_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxRigidStatic ()

- (instancetype)initWithStaticActor:(PxRigidStatic *)actor;

@end

#endif /* CPxRigidStatic_Internal_h */
