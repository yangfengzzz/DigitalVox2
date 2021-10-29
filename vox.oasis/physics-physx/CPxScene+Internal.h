//
//  CPxScene+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxScene_Internal_h
#define CPxScene_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxScene ()

- (instancetype)initWithScene:(PxScene *)scene;

@end

#endif /* CPxScene_Internal_h */
