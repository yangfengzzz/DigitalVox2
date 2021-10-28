//
//  CPxShape.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxShape.h"
#import "CPxShape+Internal.h"

@implementation CPxShape {
    PxShape *_shape;
}

- (instancetype)initWithShape:(PxShape *)shape {
    self = [super init];
    if (self) {
        _shape = shape;
    }
    return self;
}

@end
