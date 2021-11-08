//
//  CPxGeometry.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxGeometry.h"
#import "CPxGeometry+Internal.h"

@implementation CPxGeometry {
}

// MARK: - Initialization

- (instancetype)initWithGeometry:(PxGeometry *)geometry {
    self = [super init];
    if (self) {
        _c_geometry = geometry;
    }
    return self;
}

@end
