//
//  CPxControllerManager+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/9.
//

#ifndef CPxControllerManager_Internal_h
#define CPxControllerManager_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxControllerManager ()

@property(nonatomic, readonly) PxControllerManager *c_manager;

- (instancetype)initWithManager:(PxControllerManager *)manager;

@end

#endif /* CPxControllerManager_Internal_h */
