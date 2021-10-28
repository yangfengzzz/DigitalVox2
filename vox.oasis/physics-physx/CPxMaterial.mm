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

- (void)setDynamicFriction:(float)coef {
    _material->setDynamicFriction(coef);
}

- (void)setStaticFriction:(float)coef {
    _material->setStaticFriction(coef);
}

- (void)setRestitution:(float)rest {
    _material->setRestitution(rest);
}

- (void)setFrictionCombineMode:(int)combMode {
    _material->setFrictionCombineMode(PxCombineMode::Enum(combMode));
}

- (void)setRestitutionCombineMode:(int)combMode {
    _material->setRestitutionCombineMode(PxCombineMode::Enum(combMode));
}

@end
