//
//  CPxCapsuleControllerDesc.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxCapsuleControllerDesc_h
#define CPxCapsuleControllerDesc_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "../CPxMaterial.h"
#import "../CPxShape.h"
#import "../CPxRigidActor.h"
#import "CPxObstacle.h"
#import "CPxControllerDesc.h"

enum CPxCapsuleClimbingMode {
    //!< Standard mode, let the capsule climb over surfaces according to impact normal
    eEASY,
    //!< Constrained mode, try to limit climbing according to the step offset
    eCONSTRAINED,

    eLAST
};

@class CPxController;

@interface CPxCapsuleControllerDesc : CPxControllerDesc

-(enum CPxControllerShapeType) getType;

- (void)setToDefault;

@property(nonatomic, assign) float radius;
@property(nonatomic, assign) float height;
@property(nonatomic, assign) enum CPxCapsuleClimbingMode climbingMode;

@property(nonatomic, assign) simd_float3 position;
@property(nonatomic, assign) simd_float3 upDirection;
@property(nonatomic, assign) float slopeLimit;
@property(nonatomic, assign) float invisibleWallHeight;
@property(nonatomic, assign) float maxJumpHeight;
@property(nonatomic, assign) float contactOffset;
@property(nonatomic, assign) float stepOffset;
@property(nonatomic, assign) float density;
@property(nonatomic, assign) float scaleCoeff;
@property(nonatomic, assign) float volumeGrowth;
@property(nonatomic, assign) enum CPxControllerNonWalkableMode nonWalkableMode;
@property(nonatomic, assign) CPxMaterial *_Nullable material;
@property(nonatomic, assign) bool registerDeletionListener;

- (void)setControllerBehaviorCallback:(uint8_t (^ _Nullable)(CPxShape *_Nonnull shape, CPxRigidActor *_Nonnull actor))getShapeBehaviorFlags
        :(uint8_t (^ _Nullable)(CPxController *_Nonnull controller))getControllerBehaviorFlags
        :(uint8_t (^ _Nullable)(CPxObstacle *_Nonnull obstacle))getObstacleBehaviorFlags;

@end

#endif /* CPxCapsuleControllerDesc_h */
