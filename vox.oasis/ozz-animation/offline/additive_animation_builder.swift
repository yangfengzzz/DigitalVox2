//
//  additive_animation_builder.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Defines the class responsible for building a delta animation from an offline
// raw animation. This is used to create animations compatible with additive
// blending.
class AdditiveAnimationBuilder {
    // Initializes the builder.
    init() {
        fatalError()
    }

    // Builds delta animation from _input..
    // Returns true on success and fills _output_animation with the delta
    // version of _input animation.
    // *_output must be a valid RawAnimation instance. Uses first frame as
    // reference pose Returns false on failure and resets _output to an empty
    // animation. See RawAnimation::Validate() for more details about failure
    // reasons.
    func eval(_ _input: RawAnimation, _ _output: inout RawAnimation) -> Bool {
        fatalError()
    }

    // Builds delta animation from _input..
    // Returns true on success and fills _output_animation with the delta
    // *_output must be a valid RawAnimation instance.
    // version of _input animation.
    // *_reference_pose used as the base pose to calculate deltas from
    // Returns false on failure and resets _output to an empty animation.
    func eval(_ _input: RawAnimation, _ _reference_pose: ArraySlice<Transform>, _ _output: inout RawAnimation) -> Bool {
        fatalError()
    }
}
