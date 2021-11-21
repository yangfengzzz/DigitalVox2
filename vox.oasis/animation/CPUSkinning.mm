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

#include "mesh.h"

@implementation CPUSkinning {
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



@end
