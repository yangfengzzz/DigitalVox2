//
//  mesh_io.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/18.
//

#ifndef mesh_io_h
#define mesh_io_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@protocol MTLDevice, MTLBuffer;

@interface MeshIO : NSObject

- (int)triangle_index_count;

- (int)vertex_count;

- (int)max_influences_count;

- (bool)skinned;

- (int)num_joints;

- (int)highest_joint_index;

- (id <MTLBuffer>)triangle_indices:(id <MTLDevice>)device;

- (uint16_t)joint_remaps:(int)index;

- (simd_float4x4)inverse_bind_poses:(int)index;

@end

#endif /* mesh_io_h */
