//
//  CPUSkinning.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/21.
//

#import "CPUSkinning.h"
#include "ozz/geometry/runtime/skinning_job.h"
#include "ozz/animation/runtime/animation.h"
#include "ozz/animation/runtime/local_to_model_job.h"
#include "ozz/animation/runtime/sampling_job.h"
#include "ozz/animation/runtime/skeleton.h"
#include "ozz/base/log.h"
#include "ozz/base/platform.h"
#include "ozz/base/containers/vector.h"
#include "ozz/base/io/archive_traits.h"
#include "ozz/base/maths/math_ex.h"
#include "ozz/base/maths/simd_math.h"
#include "ozz/base/maths/soa_transform.h"
#include "ozz/base/maths/vec_float.h"
#include "ozz/options/options.h"
#include "utils.h"
#include "mesh.h"
#import <Metal/Metal.h>
#import <ModelIO/ModelIO.h>

namespace {
    const uint8_t kDefaultColorsArray[][4] = {
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255},
            {255, 255, 255, 255}, {255, 255, 255, 255}, {255, 255, 255, 255}};

    const float kDefaultNormalsArray[][3] = {
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f},
            {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}, {0.f, 1.f, 0.f}};

    const float kDefaultUVsArray[][2] = {
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f},
            {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}, {0.f, 0.f}};
}  // namespace

// Volatile memory buffer that can be used within function scope.
// Minimum alignment is 16 bytes.
class ScratchBuffer {
public:
    ScratchBuffer() : buffer_(nullptr), size_(0) {
    }

    ~ScratchBuffer() {
        ozz::memory::default_allocator()->Deallocate(buffer_);
    }

    // Resizes the buffer to the new size and return the memory address.
    void *Resize(size_t _size) {
        if (_size > size_) {
            size_ = _size;
            ozz::memory::default_allocator()->Deallocate(buffer_);
            buffer_ = ozz::memory::default_allocator()->Allocate(_size, 16);
        }
        return buffer_;
    }

private:
    void *buffer_;
    size_t size_;
};

@implementation CCPUSkinning {
    // Playback animation controller. This is a utility class that helps with
    // controlling animation playback time.
    ozz::skinning::PlaybackController controller_;

    // Runtime skeleton.
    ozz::animation::Skeleton skeleton_;

    // Runtime animation.
    ozz::animation::Animation animation_;

    // Sampling cache.
    ozz::animation::SamplingCache cache_;

    // Buffer of local transforms as sampled from animation_.
    ozz::vector<ozz::math::SoaTransform> locals_;

    // Buffer of model space matrices.
    ozz::vector<ozz::math::Float4x4> models_;

    // Buffer of skinning matrices, result of the joint multiplication of the
    // inverse bind pose with the model space matrix.
    ozz::vector<ozz::math::Float4x4> skinning_matrices_;

    // The mesh used by the sample.
    ozz::vector<ozz::skinning::Mesh> meshes_;

    ScratchBuffer scratch_buffer_;
}


// Updates current animation time and skeleton pose.
- (bool)OnUpdate:(float)_dt {
    // Updates current animation time.
    controller_.Update(animation_, _dt);

    // Samples optimized animation at t = animation_time_.
    ozz::animation::SamplingJob sampling_job;
    sampling_job.animation = &animation_;
    sampling_job.cache = &cache_;
    sampling_job.ratio = controller_.time_ratio();
    sampling_job.output = make_span(locals_);
    if (!sampling_job.Run()) {
        return false;
    }

    // Converts from local space to model space matrices.
    ozz::animation::LocalToModelJob ltm_job;
    ltm_job.skeleton = &skeleton_;
    ltm_job.input = make_span(locals_);
    ltm_job.output = make_span(models_);
    return ltm_job.Run();
}

- (bool)OnInitialize:(NSString *)OPTIONS_skeleton :(NSString *)OPTIONS_animation :(NSString *)OPTIONS_mesh {
    // Reading skeleton.
    if (!ozz::skinning::LoadSkeleton([OPTIONS_skeleton cStringUsingEncoding:NSUTF8StringEncoding], &skeleton_)) {
        return false;
    }

    // Reading animation.
    if (!ozz::skinning::LoadAnimation([OPTIONS_animation cStringUsingEncoding:NSUTF8StringEncoding], &animation_)) {
        return false;
    }

    // Skeleton and animation needs to match.
    if (skeleton_.num_joints() != animation_.num_tracks()) {
        ozz::log::Err() << "The provided animation doesn't match skeleton "
                           "(joint count mismatch)."
                        << std::endl;
        return false;
    }

    // Allocates runtime buffers.
    const int num_soa_joints = skeleton_.num_soa_joints();
    locals_.resize(num_soa_joints);
    const int num_joints = skeleton_.num_joints();
    models_.resize(num_joints);

    // Allocates a cache that matches animation requirements.
    cache_.Resize(num_joints);

    // Reading skinned meshes.
    if (!ozz::skinning::LoadMeshes([OPTIONS_mesh cStringUsingEncoding:NSUTF8StringEncoding], &meshes_)) {
        return false;
    }

    // Computes the number of skinning matrices required to skin all meshes.
    // A mesh is skinned by only a subset of joints, so the number of skinning
    // matrices might be less that the number of skeleton joints.
    // Mesh::joint_remaps is used to know how to order skinning matrices. So the
    // number of matrices required is the size of joint_remaps.
    size_t num_skinning_matrices = 0;
    for (const ozz::skinning::Mesh &mesh: meshes_) {
        num_skinning_matrices =
                ozz::math::Max(num_skinning_matrices, mesh.joint_remaps.size());
    }

    // Allocates skinning matrices.
    skinning_matrices_.resize(num_skinning_matrices);

    // Check the skeleton matches with the mesh, especially that the mesh
    // doesn't expect more joints than the skeleton has.
    for (const ozz::skinning::Mesh &mesh: meshes_) {
        if (num_joints < mesh.highest_joint_index()) {
            ozz::log::Err() << "The provided mesh doesn't match skeleton "
                               "(joint count mismatch)."
                            << std::endl;
            return false;
        }
    }

    return true;
}

- (bool)FreshSkinnedMesh:(id <MTLDevice>)device
        :(void (^ _Nullable)(id <MTLBuffer> _Nonnull vertexBuffer, id <MTLBuffer> _Nonnull indexBuffer,
                MDLVertexDescriptor *descriptor))meshInfo {
    bool success = true;

    // Builds skinning matrices, based on the output of the animation stage.
    // The mesh might not use (aka be skinned by) all skeleton joints. We use
    // the joint remapping table (available from the mesh object) to reorder
    // model-space matrices and build skinning ones.
    for (const ozz::skinning::Mesh &mesh: meshes_) {
        for (size_t i = 0; i < mesh.joint_remaps.size(); ++i) {
            skinning_matrices_[i] =
                    models_[mesh.joint_remaps[i]] * mesh.inverse_bind_poses[i];
        }

        // Renders skin.
        success &= [self DrawSkinnedMesh:mesh :make_span(skinning_matrices_) :ozz::math::Float4x4::identity() :device :meshInfo];
    }

    return success;
}

- (bool)DrawSkinnedMesh:(const ozz::skinning::Mesh &)_mesh
        :(const ozz::span<ozz::math::Float4x4>)_skinning_matrices
        :(const ozz::math::Float4x4 &)_transform
        :(id <MTLDevice>)device
        :(void (^ _Nullable)(id <MTLBuffer> _Nonnull vertexBuffer, id <MTLBuffer> _Nonnull indexBuffer,
                MDLVertexDescriptor *descriptor))meshInfo {
    const int vertex_count = _mesh.vertex_count();

    MDLVertexDescriptor* vertexDescriptor = [[MDLVertexDescriptor alloc]init];

    // Positions and normals are interleaved to improve caching while executing
    // skinning job.
    const int32_t positions_offset = 0;
    const int32_t normals_offset = sizeof(float) * 3;
    const int32_t tangents_offset = sizeof(float) * 6;
    const int32_t positions_stride = sizeof(float) * 9;
    const int32_t normals_stride = positions_stride;
    const int32_t tangents_stride = positions_stride;
    const int32_t skinned_data_size = vertex_count * positions_stride;
    vertexDescriptor.attributes[0] = [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributePosition
                                                                      format:MDLVertexFormatFloat3 offset:positions_offset bufferIndex:0];
    vertexDescriptor.attributes[1] = [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeNormal
                                                                      format:MDLVertexFormatFloat3 offset:normals_offset bufferIndex:0];
    vertexDescriptor.attributes[2] = [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTangent
                                                                      format:MDLVertexFormatFloat3 offset:tangents_offset bufferIndex:0];
    
    // Colors and uvs are contiguous. They aren't transformed, so they can be
    // directly copied from source mesh which is non-interleaved as-well.
    // Colors will be filled with white if _options.colors is false.
    // UVs will be skipped if _options.textured is false.
    const int32_t colors_offset = skinned_data_size;
    const int32_t colors_stride = sizeof(uint8_t) * 4;
    const int32_t colors_size = vertex_count * colors_stride;
    const int32_t uvs_offset = colors_offset + colors_size;
    const int32_t uvs_stride = sizeof(float) * 2;
    const int32_t uvs_size = vertex_count * uvs_stride;
    const int32_t fixed_data_size = colors_size + uvs_size;
    vertexDescriptor.attributes[4] = [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeColor
                                                                      format:MDLVertexFormatUInt4 offset:colors_offset bufferIndex:0];
    vertexDescriptor.attributes[5] = [[MDLVertexAttribute alloc]initWithName:MDLVertexAttributeTextureCoordinate
                                                                      format:MDLVertexFormatFloat2 offset:uvs_offset bufferIndex:0];
    vertexDescriptor.layouts[0] = [[MDLVertexBufferLayout alloc]initWithStride: positions_stride + colors_stride + uvs_stride];
    
    // Reallocate vertex buffer.
    const int32_t vbo_size = skinned_data_size + fixed_data_size;
    void *vbo_map = scratch_buffer_.Resize(vbo_size);

    // Iterate mesh parts and fills vbo.
    // Runs a skinning job per mesh part. Triangle indices are shared
    // across parts.
    size_t processed_vertex_count = 0;
    for (size_t i = 0; i < _mesh.parts.size(); ++i) {
        const ozz::skinning::Mesh::Part &part = _mesh.parts[i];

        // Skip this iteration if no vertex.
        const size_t part_vertex_count = part.positions.size() / 3;
        if (part_vertex_count == 0) {
            continue;
        }

        // Fills the job.
        ozz::geometry::SkinningJob skinning_job;
        skinning_job.vertex_count = static_cast<int>(part_vertex_count);
        const int part_influences_count = part.influences_count();

        // Clamps joints influence count according to the option.
        skinning_job.influences_count = part_influences_count;

        // Setup skinning matrices, that came from the animation stage before being
        // multiplied by inverse model-space bind-pose.
        skinning_job.joint_matrices = _skinning_matrices;

        // Setup joint's indices.
        skinning_job.joint_indices = make_span(part.joint_indices);
        skinning_job.joint_indices_stride =
                sizeof(uint16_t) * part_influences_count;

        // Setup joint's weights.
        if (part_influences_count > 1) {
            skinning_job.joint_weights = make_span(part.joint_weights);
            skinning_job.joint_weights_stride =
                    sizeof(float) * (part_influences_count - 1);
        }

        // Setup input positions, coming from the loaded mesh.
        skinning_job.in_positions = make_span(part.positions);
        skinning_job.in_positions_stride =
                sizeof(float) * ozz::skinning::Mesh::Part::kPositionsCpnts;

        // Setup output positions, coming from the rendering output mesh buffers.
        // We need to offset the buffer every loop.
        float *out_positions_begin = reinterpret_cast<float *>(ozz::PointerStride(
                vbo_map, positions_offset + processed_vertex_count * positions_stride));
        float *out_positions_end = ozz::PointerStride(
                out_positions_begin, part_vertex_count * positions_stride);
        skinning_job.out_positions = {out_positions_begin, out_positions_end};
        skinning_job.out_positions_stride = positions_stride;

        // Setup normals if input are provided.
        float *out_normal_begin = reinterpret_cast<float *>(ozz::PointerStride(
                vbo_map, normals_offset + processed_vertex_count * normals_stride));
        float *out_normal_end = ozz::PointerStride(
                out_normal_begin, part_vertex_count * normals_stride);

        if (part.normals.size() / ozz::skinning::Mesh::Part::kNormalsCpnts ==
                part_vertex_count) {
            // Setup input normals, coming from the loaded mesh.
            skinning_job.in_normals = make_span(part.normals);
            skinning_job.in_normals_stride =
                    sizeof(float) * ozz::skinning::Mesh::Part::kNormalsCpnts;

            // Setup output normals, coming from the rendering output mesh buffers.
            // We need to offset the buffer every loop.
            skinning_job.out_normals = {out_normal_begin, out_normal_end};
            skinning_job.out_normals_stride = normals_stride;
        } else {
            // Fills output with default normals.
            for (float *normal = out_normal_begin; normal < out_normal_end;
                 normal = ozz::PointerStride(normal, normals_stride)) {
                normal[0] = 0.f;
                normal[1] = 1.f;
                normal[2] = 0.f;
            }
        }

        // Setup tangents if input are provided.
        float *out_tangent_begin = reinterpret_cast<float *>(ozz::PointerStride(
                vbo_map, tangents_offset + processed_vertex_count * tangents_stride));
        float *out_tangent_end = ozz::PointerStride(
                out_tangent_begin, part_vertex_count * tangents_stride);

        if (part.tangents.size() / ozz::skinning::Mesh::Part::kTangentsCpnts ==
                part_vertex_count) {
            // Setup input tangents, coming from the loaded mesh.
            skinning_job.in_tangents = make_span(part.tangents);
            skinning_job.in_tangents_stride =
                    sizeof(float) * ozz::skinning::Mesh::Part::kTangentsCpnts;

            // Setup output tangents, coming from the rendering output mesh buffers.
            // We need to offset the buffer every loop.
            skinning_job.out_tangents = {out_tangent_begin, out_tangent_end};
            skinning_job.out_tangents_stride = tangents_stride;
        } else {
            // Fills output with default tangents.
            for (float *tangent = out_tangent_begin; tangent < out_tangent_end;
                 tangent = ozz::PointerStride(tangent, tangents_stride)) {
                tangent[0] = 1.f;
                tangent[1] = 0.f;
                tangent[2] = 0.f;
            }
        }

        // Execute the job, which should succeed unless a parameter is invalid.
        if (!skinning_job.Run()) {
            return false;
        }

        // Handles colors which aren't affected by skinning.
        if (true && part_vertex_count == part.colors.size() / ozz::skinning::Mesh::Part::kColorsCpnts) {
            // Optimal path used when the right number of colors is provided.
            memcpy(ozz::PointerStride(vbo_map, colors_offset + processed_vertex_count * colors_stride),
                    array_begin(part.colors), part_vertex_count * colors_stride);
        } else {
            // Un-optimal path used when the right number of colors is not provided.
            static_assert(sizeof(kDefaultColorsArray[0]) == colors_stride,
                    "Stride mismatch");

            for (size_t j = 0; j < part_vertex_count; j += OZZ_ARRAY_SIZE(kDefaultColorsArray)) {
                const size_t this_loop_count = ozz::math::Min(OZZ_ARRAY_SIZE(kDefaultColorsArray), part_vertex_count - j);
                memcpy(ozz::PointerStride(vbo_map, colors_offset + (processed_vertex_count + j) * colors_stride),
                        kDefaultColorsArray, colors_stride * this_loop_count);
            }
        }

        // Copies uvs which aren't affected by skinning.
        if (true) {
            if (part_vertex_count == part.uvs.size() / ozz::skinning::Mesh::Part::kUVsCpnts) {
                // Optimal path used when the right number of uvs is provided.
                memcpy(ozz::PointerStride(vbo_map, uvs_offset + processed_vertex_count * uvs_stride),
                        array_begin(part.uvs), part_vertex_count * uvs_stride);
            } else {
                // Un-optimal path used when the right number of uvs is not provided.
                assert(sizeof(kDefaultUVsArray[0]) == uvs_stride);
                for (size_t j = 0; j < part_vertex_count;
                     j += OZZ_ARRAY_SIZE(kDefaultUVsArray)) {
                    const size_t this_loop_count = ozz::math::Min(OZZ_ARRAY_SIZE(kDefaultUVsArray), part_vertex_count - j);
                    memcpy(ozz::PointerStride(vbo_map, uvs_offset + (processed_vertex_count + j) * uvs_stride),
                            kDefaultUVsArray, uvs_stride * this_loop_count);
                }
            }
        }

        // Some more vertices were processed.
        processed_vertex_count += part_vertex_count;
    }

    id <MTLBuffer> vertexBuffer = [device newBufferWithBytes:vbo_map length:vbo_size options:NULL];
    id <MTLBuffer> indexBuffer = [device newBufferWithBytes:_mesh.triangle_indices.data()
                                                     length:_mesh.triangle_indices.size() * sizeof(ozz::skinning::Mesh::TriangleIndices::value_type)
                                                    options:NULL];
    meshInfo(vertexBuffer, indexBuffer, vertexDescriptor);

    return true;
}


@end
