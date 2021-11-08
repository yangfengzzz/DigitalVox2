//
//  CPxConstraint.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxConstraint.h"
#import "CPxConstraint+Internal.h"

@implementation CPxConstraint

- (instancetype)initWithConstraint:(PxConstraint *)constraint {
    self = [super init];
    if (self) {
        _c_constraint = constraint;
    }
    return self;
}

@end
