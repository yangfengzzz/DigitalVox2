//
//  soa_float.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/3.
//

#ifndef soa_float_h
#define soa_float_h

#include "simd_math.h"

struct SoaFloat2 {
    SimdFloat4 x, y;
};

struct SoaFloat3 {
  SimdFloat4 x, y, z;
};

struct SoaFloat4 {
  SimdFloat4 x, y, z, w;
};

#endif /* soa_float_h */
