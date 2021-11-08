//
//  CPxBoxControllerDesc+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxBoxControllerDesc_Internal_h
#define CPxBoxControllerDesc_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxBoxControllerDesc ()

@property(nonatomic, readonly) PxBoxControllerDesc c_desc;

@end

#endif /* CPxBoxControllerDesc_Internal_h */
