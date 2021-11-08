//
//  CPxController+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxController_Internal_h
#define CPxController_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxController ()

@property(nonatomic, readonly) PxController *c_controller;

- (instancetype)initWithController:(PxController *)controller;

@end

#endif /* CPxController_Internal_h */
