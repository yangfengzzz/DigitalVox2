//
//  animation_optimizer.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Defines the class responsible of optimizing an offline raw animation
// instance. Optimization is performed using a key frame reduction technique. It
// deciamtes redundant / interpolable key frames, within error tolerances given
// as input. The optimizer takes into account for each joint the error
// generated on its whole child hierarchy. This allows for example to take into
// consideration the error generated on a finger when optimizing the shoulder. A
// small error on the shoulder can be magnified when propagated to the finger
// indeed.
// It's possible to override optimization settings for a joint. This implicitely
// have an effect on the whole chain, up to that joint. This allows for example
// to have aggressive optimization for a whole skeleton, except for the chain
// that leads to the hand if user wants it to be precise. Default optimization
// tolerances are set in order to favor quality over runtime performances and
// memory footprint.
class AnimationOptimizer {
    // Initializes the optimizer with default tolerances (favoring quality).
    init() {
        fatalError()
    }

    // Optimizes _input using *this parameters. _skeleton is required to evaluate
    // optimization error along joint hierarchy (see hierarchical_tolerance).
    // Returns true on success and fills _output animation with the optimized
    // version of _input animation.
    // *_output must be a valid RawAnimation instance.
    // Returns false on failure and resets _output to an empty animation.
    // See RawAnimation::Validate() for more details about failure reasons.
    func eval(_input: RawAnimation, _skeleton: Skeleton, _output: inout RawAnimation) -> Bool {
        fatalError()
    }

    // Optimization settings.
    struct Setting {
        // Default settings
        init() {
            tolerance = 1.0e-3// 1mm
            distance = 1.0e-1// 10cm
        }

        init(_ _tolerance: Float, _ _distance: Float) {
            tolerance = _tolerance
            distance = _distance
        }

        // The maximum error that an optimization is allowed to generate on a whole
        // joint hierarchy.
        var tolerance: Float

        // The distance (from the joint) at which error is measured (if bigger that
        // joint hierarchy). This allows to emulate effect on skinning.
        var distance: Float
    }

    // Global optimization settings. These settings apply to all joints of the
    // hierarchy, unless overridden by joint specific settings.
    var setting: Setting

    // Per joint override of optimization settings.
    var joints_setting_override: [Int: Setting] = [:]
}
