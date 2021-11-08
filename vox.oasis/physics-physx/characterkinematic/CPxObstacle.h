//
//  CPxObstacle.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxObstacle_h
#define CPxObstacle_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>

enum CPxGeometryType {
    eSPHERE,
    ePLANE,
    eCAPSULE,
    eBOX,
    eCONVEXMESH,
    eTRIANGLEMESH,
    eHEIGHTFIELD,
    eGEOMETRY_COUNT,    //!< internal use only!
    eINVALID = -1        //!< internal use only!
};

@interface CPxObstacle : NSObject

- (CPxGeometryType)getType;

@end

@interface CPxBoxObstacle : CPxObstacle

@property(nonatomic, assign) simd_float3 mPos;
@property(nonatomic, assign) simd_quatf mRot;

@property(nonatomic, assign) simd_float3 mHalfExtents;

@end

@interface CPxCapsuleObstacle : CPxObstacle

@property(nonatomic, assign) simd_float3 mPos;
@property(nonatomic, assign) simd_quatf mRot;

@property(nonatomic, assign) float mHalfHeight;
@property(nonatomic, assign) float mRadius;

@end

@interface CPxObstacleContext : NSObject

- (uint32_t)addObstacle:(CPxObstacle *)obstacle;

- (bool)removeObstacle:(uint32_t)handle;

- (bool)updateObstacle:(uint32_t)handle :(CPxObstacle *)obstacle;

- (uint32_t)getNbObstacles;

- (CPxObstacle *)getObstacle:(uint32_t)i;

- (CPxObstacle *)getObstacleByHandle:(uint32_t)handle;

@end

#endif /* CPxObstacle_h */
