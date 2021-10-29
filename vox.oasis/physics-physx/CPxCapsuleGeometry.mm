//
//  CPxCapsuleGeometry.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxCapsuleGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxCapsuleGeometry {
}

// MARK: - Initialization

- (instancetype)initWithRadius:(float)radius halfHeight:(float)halfHeight {
    self = [super initWithGeometry:new PxCapsuleGeometry(radius, halfHeight)];
    return self;
}

- (void)setRadius:(float)radius {
    static_cast<PxCapsuleGeometry *>(super.c_geometry)->radius = radius;
}

- (float)radius {
    return static_cast<PxCapsuleGeometry *>(super.c_geometry)->radius;
}

- (void)setHalfHeight:(float)halfHeight {
    static_cast<PxCapsuleGeometry *>(super.c_geometry)->halfHeight = halfHeight;
}

- (float)halfHeight {
    return static_cast<PxCapsuleGeometry *>(super.c_geometry)->halfHeight;
}

@end
