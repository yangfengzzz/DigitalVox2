//
//  CPxSpring+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxSpring_Internal_h
#define CPxSpring_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxSpring ()

@property(nonatomic, assign) PxSpring *c_spring;

- (instancetype)initWithSpring:(PxSpring)c_spring;

- (instancetype)initWithD6:(PxD6JointDrive)c_d6;

@end

#endif /* CPxSpring_Internal_h */
