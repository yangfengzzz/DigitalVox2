//
//  CPxJointLinearLimit+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLinearLimit_Internal_h
#define CPxJointLinearLimit_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxJointLinearLimit ()

@property(nonatomic, readonly) PxJointLinearLimit *c_limit;

- (instancetype)initWithLimit:(PxJointLinearLimit)c_limit;

@end

#endif /* CPxJointLinearLimit_Internal_h */
