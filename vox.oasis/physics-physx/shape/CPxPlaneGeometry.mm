//
//  CPxPlaneGeometry.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxPlaneGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxPlaneGeometry {
}

// MARK: - Initialization

- (instancetype)init {
    self = [super initWithGeometry:new PxPlaneGeometry];
    return self;
}

@end
