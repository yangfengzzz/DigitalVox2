//
//  soa_float.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/3.
//

#ifndef soa_float_h
#define soa_float_h

#import <simd/simd.h>

struct SoaFloat2 {
    simd_float4 x, y;
};

struct SoaFloat3 {
    simd_float4 x, y, z;
};

struct SoaFloat4 {
    simd_float4 x, y, z, w;
};

// Declare the 4x4 soa matrix type. Uses the column major convention where the
// matrix-times-vector is written v'=Mv:
// [ m.cols[0].x m.cols[1].x m.cols[2].x m.cols[3].x ]   {v.x}
// | m.cols[0].y m.cols[1].y m.cols[2].y m.cols[3].y | * {v.y}
// | m.cols[0].z m.cols[1].y m.cols[2].y m.cols[3].y |   {v.z}
// [ m.cols[0].w m.cols[1].w m.cols[2].w m.cols[3].w ]   {v.1}
struct SoaFloat4x4 {
    // Soa matrix columns.
    struct SoaFloat4 cols[4];
};

// Declare the Quaternion type.
struct SoaQuaternion {
    simd_float4 x, y, z, w;
};

// Stores an affine transformation with separate translation, rotation and scale
// attributes.
struct SoaTransform {
    struct SoaFloat3 translation;
    struct SoaQuaternion rotation;
    struct SoaFloat3 scale;
};

#endif /* soa_float_h */
