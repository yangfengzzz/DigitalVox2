//
//  CPxMaterial.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxMaterial.h"
#import "CPxMaterial+Internal.h"

@implementation CPxMaterial {
    PxMaterial *_material;
}

- (instancetype)initWithMaterial:(PxMaterial *)material {
    self = [super init];
    if (self) {
        _material = material;
    }
    return self;
}

@end
