//
//  CPxSphereGeometry.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxSphereGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxSphereGeometry {
}

// MARK: - Initialization

- (instancetype)initWithRadius:(float)radius {
    self = [super initWithGeometry:new PxSphereGeometry(radius)];
    return self;
}

- (void)setRadius:(float)radius {
    static_cast<PxSphereGeometry *>(super.c_geometry)->radius = radius;
}

- (float)radius {
    return static_cast<PxSphereGeometry *>(super.c_geometry)->radius;
}

@end
