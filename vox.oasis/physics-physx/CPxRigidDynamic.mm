//
//  CPxRigidDynamic.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxRigidDynamic.h"
#import "CPxRigidDynamic+Internal.h"
#import "CPxRigidActor+Internal.h"

@implementation CPxRigidDynamic {
}

// MARK: - Initialization

- (instancetype)initWithDynamicActor:(PxRigidDynamic *)actor {
    self = [super initWithActor:actor];
    return self;
}

@end
