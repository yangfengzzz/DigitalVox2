//
//  CPxScene.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxScene.h"
#import "CPxScene+Internal.h"

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

@end
