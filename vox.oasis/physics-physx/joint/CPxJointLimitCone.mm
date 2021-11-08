//
//  CPxJointLimitCone.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxJointLimitCone.h"
#import "CPxJointLimitCone+Internal.h"

@implementation CPxJointLimitCone {

}

- (instancetype)initWithLimit:(PxJointLimitCone)c_limit {
    self = [super init];
    if (self) {
        if (_c_limit == nullptr) {
            _c_limit = new PxJointLimitCone(0, 0);
        }

        *_c_limit = c_limit;
    }
    return self;
}

- (void)dealloc {
    delete _c_limit;
}

- (instancetype)initWithHardLimit:(float)yLimitAngle :(float)zLimitAngle :(float)contactDist {
    self = [super init];
    if (self) {
        _c_limit = new PxJointLimitCone(yLimitAngle, zLimitAngle, contactDist);
    }
    return self;
}

- (instancetype)initWithSoftLimit:(float)yLimitAngle :(float)zLimitAngle :(CPxSpring*)spring {
    self = [super init];
    if (self) {
        _c_limit = new PxJointLimitCone(yLimitAngle, zLimitAngle, PxSpring(spring.stiffness, spring.damping));
    }
    return self;
}

@end
