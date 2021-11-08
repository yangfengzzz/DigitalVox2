//
//  CPxJointLimitCone+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLimitCone_Internal_h
#define CPxJointLimitCone_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxJointLimitCone ()

@property(nonatomic, readonly) PxJointLimitCone *c_limit;

- (instancetype)initWithLimit:(PxJointLimitCone)c_limit;

@end


#endif /* CPxJointLimitCone_Internal_h */
