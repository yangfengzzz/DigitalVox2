//
//  CPxRigidDynamic+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxRigidDynamic_Internal_h
#define CPxRigidDynamic_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxRigidDynamic ()

- (instancetype)initWithDynamicActor:(PxRigidDynamic *)actor;

@end

#endif /* CPxRigidDynamic_Internal_h */
