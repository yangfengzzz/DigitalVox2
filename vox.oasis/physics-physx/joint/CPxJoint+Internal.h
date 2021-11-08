//
//  CPxJoint+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJoint_Internal_h
#define CPxJoint_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxJoint ()

@property(nonatomic, readonly) PxJoint *c_joint;

- (instancetype)initWithJoint:(PxJoint *)joint;

@end

#endif /* CPxJoint_Internal_h */
