//
//  CPxSphereGeometry.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxSphereGeometry_h
#define CPxSphereGeometry_h

#import "CPxGeometry.h"
#import <simd/simd.h>

@interface CPxSphereGeometry : CPxGeometry

@property(nonatomic, assign) float radius;

- (instancetype)initWithRadius:(float)radius;

@end

#endif /* CPxSphereGeometry_h */
