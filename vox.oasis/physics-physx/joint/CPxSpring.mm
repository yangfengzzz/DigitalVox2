//
//  CPxSpring.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxSpring.h"
#import "CPxSpring+Internal.h"

using namespace physx;

@implementation CPxSpring {
}

- (instancetype)initWithSpring:(PxSpring)c_spring {
    self = [super init];
    if (self) {
        if (_c_spring == nullptr) {
            _c_spring = new PxSpring(0, 0);
        }

        *_c_spring = c_spring;
    }
    return self;
}

-(instancetype)initWithStiffness:(float) stiffness_ :(float) damping_ {
    self = [super init];
    if (self) {
        if (_c_spring != nullptr) {
            delete _c_spring;
            _c_spring = nullptr;
        }
        _c_spring = new PxSpring(stiffness_, damping_);
    }
    return self;
}

- (float)stiffness {
    return _c_spring->stiffness;
}

- (void)setStiffness:(float)stiffness {
    _c_spring->stiffness = stiffness;
}

- (float)damping {
    return _c_spring->damping;
}

- (void)setDamping:(float)damping {
    _c_spring->damping = damping;
}


@end
