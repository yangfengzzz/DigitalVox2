//
//  CPxCapsuleGeometry.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxCapsuleGeometry_h
#define CPxCapsuleGeometry_h

#import "CPxGeometry.h"
#import <simd/simd.h>

@interface CPxCapsuleGeometry : CPxGeometry

@property(nonatomic, assign) float radius;
@property(nonatomic, assign) float halfHeight;

- (instancetype)initWithRadius:(float)radius halfHeight:(float)halfHeight;

@end

#endif /* CPxCapsuleGeometry_h */
