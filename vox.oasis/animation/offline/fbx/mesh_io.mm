//
//  mesh_io.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/18.
//

#import "mesh_io.h"
#import "mesh_io+Internal.h"
#import <Metal/Metal.h>

@implementation MeshIO

- (instancetype)initWithMesh:(Mesh)mesh {
    self = [super init];
    if (self) {
        _c_mesh = mesh;
    }
    return self;
}

- (int)triangle_index_count {
    return _c_mesh.triangle_index_count();
}

- (int)vertex_count {
    return _c_mesh.vertex_count();
}

- (int)max_influences_count {
    return _c_mesh.max_influences_count();
}

- (bool)skinned {
    return _c_mesh.skinned();
}

- (int)num_joints {
    return _c_mesh.num_joints();
}

- (int)highest_joint_index {
    return _c_mesh.highest_joint_index();
}

- (id <MTLBuffer>)triangle_indices:(id <MTLDevice>)device {
    return [device newBufferWithBytes:_c_mesh.triangle_indices.data() length:_c_mesh.triangle_index_count() * sizeof(uint16_t) options:NULL];
}

- (uint16_t)joint_remaps:(int)index {
    return _c_mesh.joint_remaps[index];
}

- (simd_float4x4)inverse_bind_poses:(int)index {
    return _c_mesh.inverse_bind_poses[index];
}


@end
