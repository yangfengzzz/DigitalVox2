//
//  CPxJointLinearLimit.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxJointLinearLimit.h"
#import "CPxJointLinearLimit+Internal.h"

@implementation CPxJointLinearLimit

- (instancetype)initWithLimit:(PxJointLinearLimit)c_limit {
    self = [super init];
    if (self) {
        if (_c_limit == nullptr) {
            _c_limit = new PxJointLinearLimit(PxTolerancesScale(), 0);
        }

        *_c_limit = c_limit;
    }
    return self;
}


- (instancetype)initWithHardLimit:(struct CPxTolerancesScale)scale :(float)extent :(float)contactDist {
    self = [super init];
    if (self) {
        PxTolerancesScale s;
        s.length = scale.length;
        s.speed = scale.speed;
        _c_limit = new PxJointLinearLimit(s, extent, contactDist);
    }
    return self;
}

- (instancetype)initWithSoftLimit:(float)extent :(CPxSpring *)spring {
    self = [super init];
    if (self) {
        _c_limit = new PxJointLinearLimit(extent, PxSpring(spring.stiffness, spring.damping));
    }
    return self;
}

@end
