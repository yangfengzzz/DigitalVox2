//
//  CPxScene.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxScene.h"
#import "CPxScene+Internal.h"
#import "CPxRigidActor+Internal.h"

using namespace physx;

@implementation CPxScene {
    PxScene *_scene;
}

- (instancetype)initWithScene:(PxScene *)scene {
    self = [super init];
    if (self) {
        _scene = scene;
    }
    return self;
}

- (void)setGravity:(simd_float3)vec {
    _scene->setGravity(PxVec3(vec.x, vec.y, vec.z));
}

- (void)simulate:(float)elapsedTime {
    _scene->simulate(elapsedTime);
}

- (bool)fetchResults:(bool)block {
    return _scene->fetchResults(block);
}

- (void)addActorWith:(CPxRigidActor *)actor {
    _scene->addActor(*actor.c_actor);
}

- (void)removeActorWith:(CPxRigidActor *)actor {
    _scene->removeActor(*actor.c_actor);
}


@end
