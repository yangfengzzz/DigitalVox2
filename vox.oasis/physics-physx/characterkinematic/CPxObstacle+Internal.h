//
//  PxObstacle+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef PxObstacle_Internal_h
#define PxObstacle_Internal_h

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxBoxObstacle ()

@property(nonatomic, assign) PxBoxObstacle c_obstacle;

@end

@interface CPxCapsuleObstacle ()

@property(nonatomic, assign) PxCapsuleObstacle c_obstacle;

@end

@interface CPxObstacleContext ()

@property(nonatomic, readonly) PxObstacleContext* c_context;

- (instancetype)initWithContext:(PxObstacleContext *)context;

@end

#endif /* PxObstacle_Internal_h */
