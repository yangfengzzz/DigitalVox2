//
//  CPxControllerDesc.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxControllerDesc_h
#define CPxControllerDesc_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "../CPxMaterial.h"
#import "../CPxShape.h"
#import "../CPxRigidActor.h"
#import "CPxObstacle.h"

enum CPxControllerNonWalkableMode {
    //!< Stops character from climbing up non-walkable slopes, but doesn't move it otherwise
    ePREVENT_CLIMBING,
    //!< Stops character from climbing up non-walkable slopes, and forces it to slide down those slopes
    ePREVENT_CLIMBING_AND_FORCE_SLIDING
};

@class CPxController;

@interface CPxBoxControllerDesc : NSObject

- (void)setToDefault;

@property(nonatomic, assign) float halfHeight;
@property(nonatomic, assign) float halfSideExtent;
@property(nonatomic, assign) float halfForwardExtent;

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

-(void)setControllerBehaviorCallback:(uint8_t (^ _Nullable)(CPxShape *_Nonnull shape, CPxRigidActor *_Nonnull actor))getShapeBehaviorFlags
                                    :(uint8_t (^ _Nullable)(CPxController *_Nonnull controller))getControllerBehaviorFlags
                                    :(uint8_t (^ _Nullable)(CPxObstacle *_Nonnull obstacle))getObstacleBehaviorFlags;

@end

#endif /* CPxControllerDesc_h */
