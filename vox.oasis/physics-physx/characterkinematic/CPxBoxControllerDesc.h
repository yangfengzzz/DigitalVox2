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

enum PxControllerNonWalkableMode
{
    //!< Stops character from climbing up non-walkable slopes, but doesn't move it otherwise
        ePREVENT_CLIMBING,
    //!< Stops character from climbing up non-walkable slopes, and forces it to slide down those slopes
        ePREVENT_CLIMBING_AND_FORCE_SLIDING
};

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
@property(nonatomic, assign) PxControllerNonWalkableMode nonWalkableMode;
@property(nonatomic, assign) CPxMaterial* material;
@property(nonatomic, assign) bool registerDeletionListener;



@end

#endif /* CPxControllerDesc_h */
