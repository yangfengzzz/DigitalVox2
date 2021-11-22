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
#include "ozz/animation/runtime/blending_job.h"
#include "ozz/animation/runtime/sampling_job.h"
#include "ozz/animation/runtime/skeleton.h"
#include "ozz/base/log.h"
#include "ozz/base/platform.h"
#include "ozz/base/memory/unique_ptr.h"
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
    // Runtime skeleton.
    ozz::animation::Skeleton skeleton_;

    // Global blend ratio in range [0,1] that controls all blend parameters and
    // synchronizes playback speeds. A value of 0 gives full weight to the first
    // animation, and 1 to the last.
    float blend_ratio_;

    // Switch to manual control of animations and blending parameters.
    bool manual_;

    // Sampler structure contains all the data required to sample a single
    // animation.
    struct Sampler {
        // Constructor, default initialization.
        Sampler() : weight(1.f) {
        }

        // Playback animation controller. This is a utility class that helps with
        // controlling animation playback time.
        ozz::skinning::PlaybackController controller;

        // Blending weight for the layer.
        float weight;

        // Runtime animation.
        ozz::animation::Animation animation;

        // Sampling cache.
        ozz::animation::SamplingCache cache;

        // Buffer of local transforms as sampled from animation_.
        ozz::vector<ozz::math::SoaTransform> locals;
    };

    ozz::vector<ozz::unique_ptr<Sampler>> samplers_;

    // Blending job bind pose threshold.
    float threshold_;

    // Buffer of local transforms which stores the blending result.
    ozz::vector<ozz::math::SoaTransform> blended_locals_;

    // Buffer of model space matrices. These are computed by the local-to-model
    // job after the blending stage.
    ozz::vector<ozz::math::Float4x4> models_;

    // Buffer of skinning matrices, result of the joint multiplication of the
    // inverse bind pose with the model space matrix.
    ozz::vector<ozz::math::Float4x4> skinning_matrices_;

    // The mesh used by the sample.
    ozz::vector<ozz::skinning::Mesh> meshes_;

    ScratchBuffer vbo_buffer_;
    ScratchBuffer uv_buffer_;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        blend_ratio_ = 0.3;
        manual_ = false;
        threshold_ = ozz::animation::BlendingJob().threshold;
    }
    return self;
}

- (void)UpdateWeight:(int)index :(float)weight {
    samplers_[index]->weight = weight;
}

// Computes blending weight and synchronizes playback speed when the "manual"
// option is off.
- (void)UpdateRuntimeParameters {
    size_t kNumLayers = samplers_.size();
    // Computes weight parameters for all samplers.
    const float kNumIntervals = kNumLayers - 1;
    const float kInterval = 1.f / kNumIntervals;
    for (int i = 0; i < kNumLayers; ++i) {
        const float med = i * kInterval;
        const float x = blend_ratio_ - med;
        const float y = ((x < 0.f ? x : -x) + kInterval) * kNumIntervals;
        samplers_[i]->weight = ozz::math::Max(0.f, y);
    }

    // Synchronizes animations.
    // First computes loop cycle duration. Selects the 2 samplers that define
    // interval that contains blend_ratio_.
    // Uses a maximum value smaller than 1.f (-epsilon) to ensure that
    // (relevant_sampler + 1) is always valid.
    const int relevant_sampler =
            static_cast<int>((blend_ratio_ - 1e-3f) * (kNumLayers - 1));
    assert(relevant_sampler + 1 < kNumLayers);
    Sampler *sampler_l = samplers_[relevant_sampler].get();
    Sampler *sampler_r = samplers_[relevant_sampler + 1].get();

    // Interpolates animation durations using their respective weights, to
    // find the loop cycle duration that matches blend_ratio_.
    const float loop_duration =
            sampler_l->animation.duration() * sampler_l->weight +
                    sampler_r->animation.duration() * sampler_r->weight;

    // Finally, finds the speed coefficient for all samplers.
    const float inv_loop_duration = 1.f / loop_duration;
    for (int i = 0; i < kNumLayers; ++i) {
        Sampler *sampler = samplers_[i].get();
        const float speed = sampler->animation.duration() * inv_loop_duration;
        sampler->controller.set_playback_speed(speed);
    }
}

// Updates current animation time and skeleton pose.
- (bool)OnUpdate:(float)_dt {
    size_t kNumLayers = samplers_.size();
    // Updates blending parameters and synchronizes animations if control mode
    // is not manual.
    if (!manual_) {
//        [self UpdateRuntimeParameters];
    }

    // Updates and samples all animations to their respective local space
    // transform buffers.
    for (int i = 0; i < kNumLayers; ++i) {
        Sampler *sampler = samplers_[i].get();

        // Updates animations time.
        sampler->controller.Update(sampler->animation, _dt);

        // Early out if this sampler weight makes it irrelevant during blending.
        if (samplers_[i]->weight <= 0.f) {
            continue;
        }

        // Setup sampling job.
        ozz::animation::SamplingJob sampling_job;
        sampling_job.animation = &sampler->animation;
        sampling_job.cache = &sampler->cache;
        sampling_job.ratio = sampler->controller.time_ratio();
        sampling_job.output = make_span(sampler->locals);

        // Samples animation.
        if (!sampling_job.Run()) {
            return false;
        }
    }

    // Blends animations.
    // Blends the local spaces transforms computed by sampling all animations
    // (1st stage just above), and outputs the result to the local space
    // transform buffer blended_locals_

    // Prepares blending layers.
    ozz::vector<ozz::animation::BlendingJob::Layer> layers(kNumLayers);
    for (int i = 0; i < kNumLayers; ++i) {
        layers[i].transform = make_span(samplers_[i]->locals);
        layers[i].weight = samplers_[i]->weight;
    }

    // Setups blending job.
    ozz::animation::BlendingJob blend_job;
    blend_job.threshold = threshold_;
    blend_job.layers = make_span(layers);
    blend_job.bind_pose = skeleton_.joint_bind_poses();
    blend_job.output = make_span(blended_locals_);

    // Blends.
    if (!blend_job.Run()) {
        return false;
    }

    // Converts from local space to model space matrices.
    // Gets the output of the blending stage, and converts it to model space.

    // Setup local-to-model conversion job.
    ozz::animation::LocalToModelJob ltm_job;
    ltm_job.skeleton = &skeleton_;
    ltm_job.input = make_span(blended_locals_);
    ltm_job.output = make_span(models_);

    // Runs ltm job.
    return ltm_job.Run();
}

- (bool)LoadAnimation:(NSString *_Nonnull)OPTIONS_animation {
    const int num_joints = skeleton_.num_joints();
    const int num_soa_joints = skeleton_.num_soa_joints();

    ozz::unique_ptr<Sampler> sampler = ozz::make_unique<Sampler>();

    if (!ozz::skinning::LoadAnimation([OPTIONS_animation cStringUsingEncoding:NSUTF8StringEncoding], &sampler->animation)) {
        return false;
    }

    // Allocates sampler runtime buffers.
    sampler->locals.resize(num_soa_joints);

    // Allocates a cache that matches animation requirements.
    sampler->cache.Resize(num_joints);

    samplers_.emplace_back(std::move(sampler));

    return true;
}

- (bool)OnInitialize:(NSString *)OPTIONS_skeleton :(NSString *)OPTIONS_mesh {
    // Reading skeleton.
    if (!ozz::skinning::LoadSkeleton([OPTIONS_skeleton cStringUsingEncoding:NSUTF8StringEncoding], &skeleton_)) {
        return false;
    }

    // Allocates runtime buffers.
    const int num_joints = skeleton_.num_joints();
    const int num_soa_joints = skeleton_.num_soa_joints();

    // Allocates local space runtime buffers of blended data.
    blended_locals_.resize(num_soa_joints);

    // Allocates model space runtime buffers of blended data.
    models_.resize(num_joints);

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
        :(void (^ _Nullable)(NSArray<id <MTLBuffer> > *vertexBuffer, id <MTLBuffer> _Nonnull indexBuffer, size_t indexCount,
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
        :(void (^ _Nullable)(NSArray<id <MTLBuffer> > *vertexBuffer, id <MTLBuffer> _Nonnull indexBuffer, size_t indexCount,
                MDLVertexDescriptor *descriptor))meshInfo {
    const int vertex_count = _mesh.vertex_count();

    MDLVertexDescriptor *vertexDescriptor = [[MDLVertexDescriptor alloc] init];

    // Positions and normals are interleaved to improve caching while executing
    // skinning job.
    const int32_t positions_offset = 0;
    const int32_t normals_offset = sizeof(float) * 3;
    const int32_t tangents_offset = sizeof(float) * 6;
    const int32_t positions_stride = sizeof(float) * 9;
    const int32_t normals_stride = positions_stride;
    const int32_t tangents_stride = positions_stride;
    const int32_t skinned_data_size = vertex_count * positions_stride;
    void *vbo_map = vbo_buffer_.Resize(skinned_data_size);
    vertexDescriptor.attributes[0] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition
                                                                       format:MDLVertexFormatFloat3 offset:positions_offset bufferIndex:0];
    vertexDescriptor.attributes[1] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeNormal
                                                                       format:MDLVertexFormatFloat3 offset:normals_offset bufferIndex:0];
    vertexDescriptor.attributes[2] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeTangent
                                                                       format:MDLVertexFormatFloat3 offset:tangents_offset bufferIndex:0];

    // Colors and uvs are contiguous. They aren't transformed, so they can be
    // directly copied from source mesh which is non-interleaved as-well.
    // Colors will be filled with white if _options.colors is false.
    // UVs will be skipped if _options.textured is false.
    const int32_t uvs_offset = 0;
    const int32_t uvs_stride = sizeof(float) * 2;
    const int32_t uvs_size = vertex_count * uvs_stride;
    void *uv_map = uv_buffer_.Resize(uvs_size);
    vertexDescriptor.attributes[3] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeTextureCoordinate
                                                                       format:MDLVertexFormatFloat2 offset:uvs_offset bufferIndex:1];
    vertexDescriptor.layouts[0] = [[MDLVertexBufferLayout alloc] initWithStride:positions_stride];
    vertexDescriptor.layouts[1] = [[MDLVertexBufferLayout alloc] initWithStride:uvs_stride];


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

        // Copies uvs which aren't affected by skinning.
        if (true) {
            if (part_vertex_count == part.uvs.size() / ozz::skinning::Mesh::Part::kUVsCpnts) {
                // Optimal path used when the right number of uvs is provided.
                memcpy(ozz::PointerStride(uv_map, uvs_offset + processed_vertex_count * uvs_stride),
                        array_begin(part.uvs), part_vertex_count * uvs_stride);
            } else {
                // Un-optimal path used when the right number of uvs is not provided.
                assert(sizeof(kDefaultUVsArray[0]) == uvs_stride);
                for (size_t j = 0; j < part_vertex_count;
                     j += OZZ_ARRAY_SIZE(kDefaultUVsArray)) {
                    const size_t this_loop_count = ozz::math::Min(OZZ_ARRAY_SIZE(kDefaultUVsArray), part_vertex_count - j);
                    memcpy(ozz::PointerStride(uv_map, uvs_offset + (processed_vertex_count + j) * uvs_stride),
                            kDefaultUVsArray, uvs_stride * this_loop_count);
                }
            }
        }

        // Some more vertices were processed.
        processed_vertex_count += part_vertex_count;
    }

    id <MTLBuffer> vertexBuffer = [device newBufferWithBytes:vbo_map length:skinned_data_size options:NULL];
    id <MTLBuffer> uvBuffer = [device newBufferWithBytes:uv_map length:uvs_size options:NULL];
    id <MTLBuffer> indexBuffer = [device newBufferWithBytes:_mesh.triangle_indices.data()
                                                     length:_mesh.triangle_indices.size() * sizeof(ozz::skinning::Mesh::TriangleIndices::value_type)
                                                    options:NULL];

    NSMutableArray *vertexBuffers = [[NSMutableArray alloc] initWithCapacity:2];
    [vertexBuffers addObject:vertexBuffer];
    [vertexBuffers addObject:uvBuffer];

    meshInfo(vertexBuffers, indexBuffer, _mesh.triangle_indices.size(), vertexDescriptor);

    return true;
}


@end
