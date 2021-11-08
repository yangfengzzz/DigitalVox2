//
//  CPxConstraint+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxConstraint_Internal_h
#define CPxConstraint_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxConstraint ()

@property(nonatomic, readonly) PxConstraint *c_constraint;

- (instancetype)initWithConstraint:(PxConstraint *)constraint;

@end

#endif /* CPxConstraint_Internal_h */
