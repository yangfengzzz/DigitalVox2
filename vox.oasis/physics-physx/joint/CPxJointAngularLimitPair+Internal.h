//
//  CPxJointAngularLimitPair+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointAngularLimitPair_Internal_h
#define CPxJointAngularLimitPair_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxJointAngularLimitPair ()

@property(nonatomic, readonly) PxJointAngularLimitPair *c_limit;

- (instancetype)initWithLimit:(PxJointAngularLimitPair)c_limit;

@end

#endif /* CPxJointAngularLimitPair_Internal_h */
