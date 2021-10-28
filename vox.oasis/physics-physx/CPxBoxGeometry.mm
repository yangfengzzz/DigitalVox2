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

@end
