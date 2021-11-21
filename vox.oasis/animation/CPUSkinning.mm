//
//  CPUSkinning.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/21.
//

#import "CPUSkinning.h"
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

@implementation CPUSkinning {
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


@end
