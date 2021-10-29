//
//  CPxRigidStatic.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/29.
//

#import "CPxRigidStatic.h"
#import "CPxRigidStatic+Internal.h"
#import "CPxRigidActor+Internal.h"

@implementation CPxRigidStatic {
}

// MARK: - Initialization

- (instancetype)initWithStaticActor:(PxRigidStatic *)actor {
    self = [super initWithActor:actor];
    return self;
}

@end
