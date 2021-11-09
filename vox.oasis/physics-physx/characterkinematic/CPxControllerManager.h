//
//  CPxControllerManager.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxControllerManager_h
#define CPxControllerManager_h

#import <Foundation/Foundation.h>
#import "CPxController.h"
#import "CPxControllerDesc.h"
#import "CPxObstacle.h"
#import "../CPxScene.h"

@interface CPxControllerManager : NSObject

- (uint32_t)getNbControllers;

- (CPxController *)getController:(uint32_t)index;

- (CPxController *)createController:(CPxControllerDesc *)desc;

- (void)purgeControllers;

- (uint32_t)getNbObstacleContexts;

- (CPxObstacleContext *)getObstacleContext:(uint32_t)index;

- (CPxObstacleContext *)createObstacleContext;

- (void)computeInteractions:(float)elapsedTime;

- (void)setTessellation:(bool)flag :(float)maxEdgeLength;

- (void)setOverlapRecoveryModule:(bool)flag;

- (void)setPreciseSweeps:(bool)flag;

- (void)setPreventVerticalSlidingAgainstCeiling:(bool)flag;

- (void)shiftOrigin:(simd_float3)shift;

@end

#endif /* CPxControllerManager_h */
