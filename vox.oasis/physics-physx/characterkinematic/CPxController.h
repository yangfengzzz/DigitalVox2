//
//  CPxController.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxController_h
#define CPxController_h

#import "CPxControllerDesc.h"
#import "CPxObstacle.h"
#import "../CPxRigidDynamic.h"

enum CPxControllerCollisionFlag {
    //!< Character is colliding to the sides.
    eCOLLISION_SIDES = (1 << 0),
    //!< Character has collision above.
    eCOLLISION_UP = (1 << 1),
    //!< Character has collision below.
    eCOLLISION_DOWN = (1 << 2)
};

@interface CPxController : NSObject

- (enum CPxControllerShapeType)getType;

- (uint8_t)move:(simd_float3)disp :(float)minDist :(float)elapsedTime;

- (bool)setPosition:(simd_float3)position;

- (simd_float3)getPosition;

- (void)setFootPosition:(simd_float3)position;

- (simd_float3)getFootPosition;

- (CPxRigidDynamic *_Nonnull)getActor;

- (void)setStepOffset:(float)offset;

- (float)getStepOffset;

- (void)setNonWalkableMode:(enum CPxControllerNonWalkableMode)flag;

- (enum CPxControllerNonWalkableMode)getNonWalkableMode;

- (float)getContactOffset;

- (void)setContactOffset:(float)offset;

- (simd_float3)getUpDirection;

- (void)setUpDirection:(simd_float3)up;

- (float)getSlopeLimit;

- (void)setSlopeLimit:(float)slopeLimit;

- (void)invalidateCache;

- (void)resize:(float)height;

@end

#endif /* CPxController_h */
