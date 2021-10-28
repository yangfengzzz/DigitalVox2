//
//  CPxBoxGeometry.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxBoxGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxBoxGeometry {
}

// MARK: - Initialization

- (instancetype)initWithHx:(float)hx hy:(float)hy hz:(float)hz {
    self = [super initWithGeometry:new PxBoxGeometry(hx, hy, hz)];
    return self;
}

- (void)sethalfExtents:(simd_float3)margin {
    static_cast<PxBoxGeometry *>(super.c_geometry)->halfExtents = PxVec3(margin.x, margin.y, margin.z);
}

- (simd_float3)halfExtents {
    PxVec3 e = static_cast<PxBoxGeometry *>(super.c_geometry)->halfExtents;
    return simd_make_float3(e.x, e.y, e.z);
}

@end
