//
//  CPxJointLinearLimitPair+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLinearLimitPair_Internal_h
#define CPxJointLinearLimitPair_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxJointLinearLimitPair ()

@property(nonatomic, readonly) PxJointLinearLimitPair *c_limit;

- (instancetype)initWithLimit:(PxJointLinearLimitPair)c_limit;

@end

#endif /* CPxJointLinearLimitPair_Internal_h */
