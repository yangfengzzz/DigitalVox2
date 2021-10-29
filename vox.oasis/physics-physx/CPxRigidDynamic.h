//
//  CPxRigidDynamic.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxRigidDynamic_h
#define CPxRigidDynamic_h

#import "CPxRigidActor.h"
#import <simd/simd.h>

@interface CPxRigidDynamic : CPxRigidActor

- (void) addForceWith: (simd_float3)force;

- (void) addTorqueWith: (simd_float3)torque;

@end

#endif /* CPxRigidDynamic_h */
