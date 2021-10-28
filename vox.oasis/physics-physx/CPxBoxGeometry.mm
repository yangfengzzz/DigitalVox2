//
//  CPxBoxGeometry.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxBoxGeometry.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxBoxGeometry {
    PxBoxGeometry *_geometry;
}

// MARK: - Initialization

- (instancetype)initWithHx:(float)hx hy:(float)hy hz:(float)hz {
    self = [super init];
    if (self) {
        [self initializeGeometryWithHx:hx hy:hy hz:hz];
    }
    return self;
}

- (void)initializeGeometryWithHx:(float)hx hy:(float)hy hz:(float)hz {
    _geometry = new PxBoxGeometry(hx, hy, hz);
}

@end
