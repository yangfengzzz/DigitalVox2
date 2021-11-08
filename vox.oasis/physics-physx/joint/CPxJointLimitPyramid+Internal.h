//
//  CPxJointLimitPyramid+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLimitPyramid_Internal_h
#define CPxJointLimitPyramid_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxJointLimitPyramid ()

@property(nonatomic, readonly) PxJointLimitPyramid *c_limit;

- (instancetype)initWithLimit:(PxJointLimitPyramid)c_limit;

@end

#endif /* CPxJointLimitPyramid_Internal_h */
