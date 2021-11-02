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
    // Optimizes _input using *this parameters. _skeleton is required to evaluate
    // optimization error along joint hierarchy (see hierarchical_tolerance).
    // Returns true on success and fills _output animation with the optimized
    // version of _input animation.
    // *_output must be a valid RawAnimation instance.
    // Returns false on failure and resets _output to an empty animation.
    // See RawAnimation::Validate() for more details about failure reasons.
    func eval(_input: RawAnimation, _skeleton: Skeleton, _output: inout RawAnimation) -> Bool {
        // Reset output animation to default.
        _output = RawAnimation()

        // Validate animation.
        if (!_input.Validate()) {
            return false
        }

        let num_tracks = _input.num_tracks()

        // Validates the skeleton matches the animation.
        if (num_tracks != _skeleton.num_joints()) {
            return false
        }

        // First computes bone lengths, that will be used when filtering.
        let hierarchy = HierarchyBuilder(_input, _skeleton, self)

        // Rebuilds output animation.
        _output.name = _input.name
        _output.duration = _input.duration
        _output.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: num_tracks)

        for i in 0..<num_tracks {
            let input = _input.tracks[i]

            // Gets joint specs back.
            let joint_length = hierarchy.specs[i].length
            let parent = _skeleton.joint_parents()[i]
            let parent_scale = (parent != Skeleton.Constants.kNoParent.rawValue) ? hierarchy.specs[parent].scale : 1.0
            let tolerance = hierarchy.specs[i].tolerance

            // Filters independently T, R and S tracks.
            // This joint translation is affected by parent scale.
            let tadap = PositionAdapter(parent_scale)
            Decimate(input.translations, tadap, tolerance, &_output.tracks[i].translations)
            // This joint rotation affects children translations/length.
            let radap = RotationAdapter(joint_length)
            Decimate(input.rotations, radap, tolerance, &_output.tracks[i].rotations)
            // This joint scale affects children translations/length.
            let sadap = ScaleAdapter(joint_length)
            Decimate(input.scales, sadap, tolerance, &_output.tracks[i].scales)
        }

        // Output animation is always valid though.
        return _output.Validate()
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
    var setting = Setting()

    // Per joint override of optimization settings.
    var joints_setting_override: [Int: Setting] = [:]
}

func GetJointSetting(_ _optimizer: AnimationOptimizer, _ _joint: Int) -> AnimationOptimizer.Setting {
    var setting = _optimizer.setting
    let it = _optimizer.joints_setting_override.first { (key: Int, value: AnimationOptimizer.Setting) in
        key == _joint
    }

    if (it != nil) {
        setting = it!.value
    }
    return setting
}

class HierarchyBuilder {
    init(_ _animation: RawAnimation, _ _skeleton: Skeleton,
         _ _optimizer: AnimationOptimizer) {
        specs = [Spec](repeating: Spec(), count: _animation.tracks.count)
        animation = _animation
        optimizer = _optimizer
        assert(_animation.num_tracks() == _skeleton.num_joints())

        // Computes hierarchical scale, iterating skeleton forward (root to leaf).
        IterateJointsDF(_skeleton, ComputeScaleForward)

        // Computes hierarchical length, iterating skeleton backward (leaf to root).
        IterateJointsDFReverse(_skeleton, ComputeLengthBackward)
    }

    // Extracts maximum translations and scales for each track/joint.
    func ComputeScaleForward(_joint: Int, _parent: Int) {
        // Compute joint maximum animated scale.
        var max_scale: Float = 0.0
        let track = animation.tracks[_joint]
        if (track.scales.count != 0) {
            for j in 0..<track.scales.count {
                let scale = track.scales[j].value
                let max_element = max(max(abs(scale.x), abs(scale.y)), abs(scale.z))
                max_scale = max(max_scale, max_element)
            }
        } else {
            max_scale = 1.0  // Default scale.
        }

        // Accumulate with parent scale.
        specs[_joint].scale = max_scale
        if (_parent != Skeleton.Constants.kNoParent.rawValue) {
            let parent_spec = specs[_parent]
            specs[_joint].scale *= parent_spec.scale
        }

        // Computes self setting distance and tolerance.
        // Distance is now scaled with accumulated parent scale.
        let setting = GetJointSetting(optimizer, _joint)
        specs[_joint].length = setting.distance * specs[_joint].scale
        specs[_joint].tolerance = setting.tolerance
    }

    // Propagate child translations back to the root.
    func ComputeLengthBackward(_joint: Int, _parent: Int) {
        // Self translation doesn't matter if joint has no parent.
        if (_parent == Skeleton.Constants.kNoParent.rawValue) {
            return
        }

        // Compute joint maximum animated length.
        var max_length_sq: Float = 0.0
        let track = animation.tracks[_joint]
        for j in 0..<track.translations.count {
            max_length_sq = max(max_length_sq, LengthSqr(track.translations[j].value))
        }
        let max_length = sqrt(max_length_sq)

        let joint_spec = specs[_joint]

        // Set parent hierarchical spec to its most impacting child, aka max
        // length and min tolerance.
        specs[_parent].length = max(specs[_parent].length, joint_spec.length + max_length * specs[_parent].scale)
        specs[_parent].tolerance = min(specs[_parent].tolerance, joint_spec.tolerance)
    }

    struct Spec {
        var length: Float = 0  // Length of a joint hierarchy (max of all child).
        var scale: Float = 0   // Scale of a joint hierarchy (accumulated from all parents).
        var tolerance: Float = 0  // Tolerance of a joint hierarchy (min of all child).
    }

    // Defines the length of a joint hierarchy (of all child).
    var specs: [Spec] = []

    // Targeted animation.
    private var animation: RawAnimation

    // Useful to access settings and compute hierarchy length.
    private var optimizer: AnimationOptimizer
}

class PositionAdapter: DecimateType {
    init(_ _scale: Float) {
        scale_ = _scale
    }

    func Decimable(_ _: RawAnimation.TranslationKey) -> Bool {
        true
    }

    func Lerp(_ _left: RawAnimation.TranslationKey,
              _ _right: RawAnimation.TranslationKey,
              _ _ref: RawAnimation.TranslationKey) -> RawAnimation.TranslationKey {
        let alpha = (_ref.time - _left.time) / (_right.time - _left.time)
        assert(alpha >= 0.0 && alpha <= 1.0)
        return RawAnimation.TranslationKey(
                _ref.time, LerpTranslation(_left.value, _right.value, alpha))
    }

    func Distance(_ _a: RawAnimation.TranslationKey,
                  _ _b: RawAnimation.TranslationKey) -> Float {
        Length(_a.value - _b.value) * scale_
    }


    private var scale_: Float
}

class RotationAdapter: DecimateType {
    init(_ _radius: Float) {
        radius_ = _radius
    }

    func Decimable(_ _: RawAnimation.RotationKey) -> Bool {
        true
    }

    func Lerp(_ _left: RawAnimation.RotationKey,
              _ _right: RawAnimation.RotationKey,
              _ _ref: RawAnimation.RotationKey) -> RawAnimation.RotationKey {
        let alpha = (_ref.time - _left.time) / (_right.time - _left.time)
        assert(alpha >= 0.0 && alpha <= 1.0)
        let key = RawAnimation.RotationKey(_ref.time, LerpRotation(_left.value, _right.value, alpha))
        return key
    }

    func Distance(_ _left: RawAnimation.RotationKey,
                  _ _right: RawAnimation.RotationKey) -> Float {
        // Compute the shortest unsigned angle between the 2 quaternions.
        // cos_half_angle is w component of a-1 * b.
        let cos_half_angle = Dot(_left.value, _right.value)
        let sine_half_angle = sqrt(1.0 - min(1.0, cos_half_angle * cos_half_angle))
        // Deduces distance between 2 points on a circle with radius and a given
        // angle. Using half angle helps as it allows to have a right-angle
        // triangle.
        let distance = 2.0 * sine_half_angle * radius_
        return distance
    }

    private var radius_: Float
}

class ScaleAdapter: DecimateType {
    init(_ _length: Float) {
        length_ = _length
    }

    func Decimable(_ _: RawAnimation.ScaleKey) -> Bool {
        true
    }

    func Lerp(_ _left: RawAnimation.ScaleKey,
              _ _right: RawAnimation.ScaleKey,
              _ _ref: RawAnimation.ScaleKey) -> RawAnimation.ScaleKey {
        let alpha = (_ref.time - _left.time) / (_right.time - _left.time)
        assert(alpha >= 0.0 && alpha <= 1.0)
        let key = RawAnimation.ScaleKey(_ref.time, LerpScale(_left.value, _right.value, alpha))
        return key
    }

    func Distance(_ _left: RawAnimation.ScaleKey,
                  _ _right: RawAnimation.ScaleKey) -> Float {
        Length(_left.value - _right.value) * length_
    }

    private var length_: Float
}
