//
//  CPxMaterial+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxMaterial_Internal_h
#define CPxMaterial_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxMaterial ()

@property(nonatomic, readonly) PxMaterial *c_material;

- (instancetype)initWithMaterial:(PxMaterial *)material;

@end

#endif /* CPxMaterial_Internal_h */
