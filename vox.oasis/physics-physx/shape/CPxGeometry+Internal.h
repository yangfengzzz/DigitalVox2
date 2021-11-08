//
//  CPxGeometry+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxGeometry_Internal_h
#define CPxGeometry_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxGeometry ()

@property(nonatomic, readonly) PxGeometry *c_geometry;

- (instancetype)initWithGeometry:(PxGeometry *)geometry;

@end

#endif /* CPxGeometry_Internal_h */
