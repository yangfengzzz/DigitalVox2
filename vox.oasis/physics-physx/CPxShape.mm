//
//  CPxShape.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/28.
//

#import "CPxShape.h"
#import "CPxShape+Internal.h"
#import "CPxGeometry+Internal.h"
#import "CPxMaterial+Internal.h"
#include <vector>

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

- (void)setFlags:(uint8_t)inFlags {
    _shape->setFlags(PxShapeFlags(inFlags));
}

- (void)setQueryFilterData:(uint32_t)w0 w1:(uint32_t)w1 w2:(uint32_t)w2 w3:(uint32_t)w3 {
    _shape->setQueryFilterData(PxFilterData(w0, w1, w2, w3));
}

- (void)setGeometry:(CPxGeometry *)geometry {
    _shape->setGeometry(*geometry.c_geometry);
}

- (void)setLocalPose:(simd_float3)position rotation:(simd_quatf)rotation {
    _shape->setLocalPose(PxTransform(PxVec3(position.x, position.y, position.z),
            PxQuat(rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w)));
}

- (void)setMaterial:(CPxMaterial *)material {
    std::vector<PxMaterial *> materials(1, nullptr);
    materials[0] = material.c_material;
    _shape->setMaterials(materials.data(), materials.size());
}

@end