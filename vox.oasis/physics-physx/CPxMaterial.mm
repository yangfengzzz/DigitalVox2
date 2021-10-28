//
//  CPxMaterial.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxMaterial.h"
#import "CPxMaterial+Internal.h"

@implementation CPxMaterial {
}

- (instancetype)initWithMaterial:(PxMaterial *)material {
    self = [super init];
    if (self) {
        _c_material = material;
    }
    return self;
}

- (void)setDynamicFriction:(float)coef {
    _c_material->setDynamicFriction(coef);
}

- (float)getDynamicFriction {
    return _c_material->getDynamicFriction();
}

- (void)setStaticFriction:(float)coef {
    _c_material->setStaticFriction(coef);
}

- (float)getStaticFriction {
    return _c_material->getStaticFriction();
}

- (void)setRestitution:(float)rest {
    _c_material->setRestitution(rest);
}

- (float)getRestitution {
    return _c_material->getRestitution();
}

- (void)setFrictionCombineMode:(int)combMode {
    _c_material->setFrictionCombineMode(PxCombineMode::Enum(combMode));
}

- (int)getFrictionCombineMode {
    return _c_material->getFrictionCombineMode();
}

- (void)setRestitutionCombineMode:(int)combMode {
    _c_material->setRestitutionCombineMode(PxCombineMode::Enum(combMode));
}

- (int)getRestitutionCombineMode {
    return _c_material->getRestitutionCombineMode();
}

@end
