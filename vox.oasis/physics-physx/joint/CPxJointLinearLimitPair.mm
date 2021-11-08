//
//  CPxJointLinearLimitPair.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxJointLinearLimitPair.h"
#import "CPxJointLinearLimitPair+Internal.h"

@implementation CPxJointLinearLimitPair {

}

- (instancetype)initWithLimit:(PxJointLinearLimitPair)c_limit {
    self = [super init];
    if (self) {
        if (_c_limit == nullptr) {
            _c_limit = new PxJointLinearLimitPair(PxTolerancesScale(), 0, 0);
        }

        *_c_limit = c_limit;
    }
    return self;
}

- (void)dealloc {
    delete _c_limit;
}

- (instancetype)initWithHardLimit:(CPxTolerancesScale)scale :(float)lowerLimit :(float)upperLimit :(float)contactDist {
    self = [super init];
    if (self) {
        PxTolerancesScale s;
        s.length = scale.length;
        s.speed = scale.speed;
        _c_limit = new PxJointLinearLimitPair(s, lowerLimit, upperLimit, contactDist);
    }
    return self;
}

- (instancetype)initWithSoftLimit:(float)lowerLimit :(float)upperLimit :(struct CPxSpring)spring {
    self = [super init];
    if (self) {
        _c_limit = new PxJointLinearLimitPair(lowerLimit, upperLimit, PxSpring(spring.stiffness, spring.damping));
    }
    return self;
}

@end
