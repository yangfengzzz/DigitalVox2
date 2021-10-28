//
//  CPxShape+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxShape_Internal_h
#define CPxShape_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxShape ()

- (instancetype)initWithShape:(PxShape *)shape;

@end

#endif /* CPxShape_Internal_h */
