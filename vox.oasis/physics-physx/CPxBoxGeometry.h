//
//  CPxBoxGeometry.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxBoxGeometry_h
#define CPxBoxGeometry_h

#import "CPxGeometry.h"
#import <simd/simd.h>

@interface CPxBoxGeometry : CPxGeometry

@property(nonatomic, assign) simd_float3 halfExtents;

- (instancetype)initWithHx:(float)hx hy:(float)hy hz:(float)hz;

@end

#endif /* CPxBoxGeometry_h */
