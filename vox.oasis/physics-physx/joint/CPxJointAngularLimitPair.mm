//
//  CPxJointAngularLimitPair.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxJointAngularLimitPair.h"
#import "CPxJointAngularLimitPair+Internal.h"

@implementation CPxJointAngularLimitPair {

}

- (instancetype)initWithLimit:(PxJointAngularLimitPair)c_limit {
    self = [super init];
    if (self) {
        if (_c_limit == nullptr) {
            _c_limit = new PxJointAngularLimitPair(0, 0);
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
        _c_limit = new PxJointAngularLimitPair(yLimitAngle, zLimitAngle, contactDist);
    }
    return self;
}

- (instancetype)initWithSoftLimit:(float)yLimitAngle :(float)zLimitAngle :(struct CPxSpring)spring {
    self = [super init];
    if (self) {
        _c_limit = new PxJointAngularLimitPair(yLimitAngle, zLimitAngle, PxSpring(spring.stiffness, spring.damping));
    }
    return self;
}

@end
