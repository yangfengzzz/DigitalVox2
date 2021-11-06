//
//  animation_optimizer_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class AnimationOptimizerTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testError() {
        let optimizer = AnimationOptimizer()

        do {  // nullptr output.
            let input = RawAnimation()
            XCTAssertTrue(input.validate())
        }

        do {  // Invalid input animation.
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let skeleton_builder = SkeletonBuilder()
            let skeleton = skeleton_builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)

            var input = RawAnimation()
            input.duration = -1.0
            XCTAssertFalse(input.validate())

            // Builds animation
            var output = RawAnimation()
            output.duration = -1.0
            output.tracks = [RawAnimation.JointTrack()]
            XCTAssertFalse(optimizer.eval(input, skeleton!, &output))
            XCTAssertEqual(output.duration, RawAnimation().duration)
            XCTAssertEqual(output.num_tracks(), 0)
        }

        do {  // Invalid skeleton.
            let skeleton = SoaSkeleton()

            var input = RawAnimation()
            input.tracks = [RawAnimation.JointTrack()]
            XCTAssertTrue(input.validate())

            // Builds animation
            var output = RawAnimation()
            XCTAssertFalse(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.duration, RawAnimation().duration)
            XCTAssertEqual(output.num_tracks(), 0)
        }
    }

    func testName() {
        // Prepares a skeleton.
        let raw_skeleton = RawSkeleton()
        let skeleton_builder = SkeletonBuilder()
        let skeleton = skeleton_builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)

        let optimizer = AnimationOptimizer()

        var input = RawAnimation()
        input.name = "Test_Animation"
        input.duration = 1.0

        XCTAssertTrue(input.validate())

        var output = RawAnimation()
        XCTAssertTrue(optimizer.eval(input, skeleton!, &output))
        XCTAssertEqual(output.num_tracks(), 0)
        XCTAssertEqual(output.name, "Test_Animation")
    }

    func testOptimize() {
        // Prepares a skeleton.
        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint()]
        raw_skeleton.roots[0].children = [RawSkeleton.Joint()]
        raw_skeleton.roots[0].children[0].children = [RawSkeleton.Joint()]
        raw_skeleton.roots[0].children[0].children[0].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        let skeleton_builder = SkeletonBuilder()
        let skeleton = skeleton_builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }

        // Disable non hierarchical optimizations
        let optimizer = AnimationOptimizer()

        // Disables vertex distance.
        optimizer.setting.distance = 0.0

        var input = RawAnimation()
        input.duration = 1.0
        input.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 5)

        // Translations on track 0.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(4.0, 0.0, 0.0))
            input.tracks[0].translations.append(key)
        }

        // Translations on track 1.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(0.0, 0.0, 0.0))
            input.tracks[1].translations.append(key)
        }

        // Translations on track 2.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(5.0, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }
        do {
            let key = RawAnimation.TranslationKey(0.1, VecFloat3(6.0, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }
        do {  // Creates an variation.
            let key = RawAnimation.TranslationKey(0.2, VecFloat3(7.1, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }
        do {
            let key = RawAnimation.TranslationKey(0.3, VecFloat3(8.0, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }

        // Translations on track 3.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(16.0, 0.0, 0.0))
            input.tracks[3].translations.append(key)
        }
        // Translations on track 4.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(32.0, 0.0, 0.0))
            input.tracks[4].translations.append(key)
        }

        XCTAssertTrue(input.validate())

        // Small translation tolerance -> all key maintained
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.01
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 4)
            XCTAssertEqual(translations[0].time, 0.0)
            XCTAssertEqual(translations[1].time, 0.1)
            XCTAssertEqual(translations[2].time, 0.2)
            XCTAssertEqual(translations[3].time, 0.3)
        }

        // High translation tolerance -> all key interpolated
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.1
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
            XCTAssertEqual(translations[0].time, 0.0)
            XCTAssertEqual(translations[1].time, 0.3)
        }

        // Introduces a 10x scaling upstream that amplifies error
        // Scaling on track 0
        do {
            let key = RawAnimation.ScaleKey(0.0, VecFloat3(10.0, 0.0, 0.0))
            input.tracks[0].scales.append(key)
        }

        // High translation tolerance -> keys aren't interpolated because of scale
        // effect.
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.1
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 4)
        }

        // Very high tolerance
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 1.0
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
        }

        // Introduces a -10x scaling upstream that amplifies error
        // Scaling on track 0
        do {
            input.tracks[0].scales[0].value = VecFloat3(0.0, -10.0, 0.0)
        }

        // High translation tolerance -> keys aren't interpolated because of scale
        // effect.
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.1
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 4)
            XCTAssertEqual(translations[0].time, 0.0)
            XCTAssertEqual(translations[1].time, 0.1)
            XCTAssertEqual(translations[2].time, 0.2)
            XCTAssertEqual(translations[3].time, 0.3)
        }

        // Very high tolerance
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 1.0
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
            XCTAssertEqual(translations[0].time, 0.0)
            XCTAssertEqual(translations[1].time, 0.3)
        }

        // Compenstate scale on next joint
        do {
            let key = RawAnimation.ScaleKey(0.0, VecFloat3(0.1, 0.0, 0.0))
            input.tracks[1].scales.append(key)
        }

        // High translation tolerance -> keys ar interpolated because of scale
        // compensation.
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 1.0
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
        }

        // Remove scaling compensation
        do {
            input.tracks[1].scales = []
        }

        // Introduces a .1x scaling upstream that amplifies error
        // Scaling on track 0
        do {
            input.tracks[0].scales[0].value = VecFloat3(0.0, 0.0, 0.1)
        }

        // High translation tolerance -> keys aren't interpolated because of scale
        // effect.
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.001
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 4)
            XCTAssertEqual(translations[0].time, 0.0)
            XCTAssertEqual(translations[1].time, 0.1)
            XCTAssertEqual(translations[2].time, 0.2)
            XCTAssertEqual(translations[3].time, 0.3)
        }

        // Very high translation tolerance
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.01
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
            XCTAssertEqual(translations[0].time, 0.0)
            XCTAssertEqual(translations[1].time, 0.3)
        }

        // Remove scaling
        do {
            input.tracks[0].scales = []
        }

        // Rotations on track 0.
        do {
            let key = RawAnimation.RotationKey(0.0, VecQuaternion.fromEuler(0.0, 0.0, 0.0))
            input.tracks[0].rotations.append(key)
        }
        do {                                     // Include error
            let angle_error: Float = 2.5e-3  // creates an arc of .1m at 40m.
            let key = RawAnimation.RotationKey(0.1, VecQuaternion.fromEuler(kPi_4 + angle_error, 0.0, 0.0))
            input.tracks[0].rotations.append(key)
        }
        do {
            let key = RawAnimation.RotationKey(0.2, VecQuaternion.fromEuler(kPi_2, 0.0, 0.0))
            input.tracks[0].rotations.append(key)
        }

        // Big enough tolerance -> keys rejected
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.3
            optimizer.setting.distance = 40.0
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[0].rotations
            XCTAssertEqual(rotations.count, 2)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
        }

        // Small enough tolerance -> keys rejected
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.05
            optimizer.setting.distance = 40.0
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[0].rotations
            XCTAssertEqual(rotations.count, 3)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 4)
        }

        // Back to default
        optimizer.setting = AnimationOptimizer.Setting()

        // Small translation tolerance -> all key maintained
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.01
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[0].rotations
            XCTAssertEqual(rotations.count, 3)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 4)
        }

        // Introduces a .1x scaling upstream that lowers error
        // Scaling on track 0
        do {
            let key = RawAnimation.ScaleKey(0.0, VecFloat3(0.0, 0.1, 0.0))
            input.tracks[1].scales.append(key)
        }

        // Small translation tolerance, but scaled down -> keys rejected
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.011
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[0].rotations
            XCTAssertEqual(rotations.count, 2)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
        }

        // More vertex distance -> keys are maintained (translation unaffected)
        do {
            var output = RawAnimation()
            optimizer.setting.tolerance = 0.01
            optimizer.setting.distance = 1.0
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[0].rotations
            XCTAssertEqual(rotations.count, 3)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
        }

        // Remove scaling
        do {
            input.tracks[2].scales = []
        }
    }

    func testOptimizeOverride() {
        // Prepares a skeleton.
        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint()]
        raw_skeleton.roots[0].children = [RawSkeleton.Joint()]
        raw_skeleton.roots[0].children[0].children = [RawSkeleton.Joint()]
        raw_skeleton.roots[0].children[0].children[0].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        let skeleton_builder = SkeletonBuilder()
        let skeleton = skeleton_builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }

        // Disable non hierarchical optimizations
        let optimizer = AnimationOptimizer()
        let loose_setting = AnimationOptimizer.Setting(1e-2, 1e-3)  // 1cm 1mm
        // Disables vertex distance.
        optimizer.setting.distance = 0.0

        var input = RawAnimation()
        input.duration = 1.0
        input.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 5)

        // Translations on track 0.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(0.4, 0.0, 0.0))
            input.tracks[0].translations.append(key)
        }

        // Rotations on track 0.
        do {
            let key = RawAnimation.RotationKey(0.0, VecQuaternion.fromEuler(0.0, 0.0, 0.0))
            input.tracks[1].rotations.append(key)
        }
        do {                                   // Includes an error that
            let angle_error: Float = 1e-3  // creates an arc of 1mm at 1m.
            let key = RawAnimation.RotationKey(0.1, VecQuaternion.fromEuler(kPi_4 + angle_error, 0.0, 0.0))
            input.tracks[1].rotations.append(key)
        }
        do {
            let key = RawAnimation.RotationKey(0.2, VecQuaternion.fromEuler(kPi_2, 0.0, 0.0))
            input.tracks[1].rotations.append(key)
        }

        // Translations on track 1.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(0.0, 0.0, 0.0))
            input.tracks[1].translations.append(key)
        }

        // Translations on track 2.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(0.05, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }
        do {
            let key = RawAnimation.TranslationKey(0.1, VecFloat3(0.06, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }
        do {  // Creates a variation.
            let trans_err: Float = 5e-4
            let key = RawAnimation.TranslationKey(0.2, VecFloat3(0.07 + trans_err, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }
        do {
            let key = RawAnimation.TranslationKey(0.3, VecFloat3(0.08, 0.0, 0.0))
            input.tracks[2].translations.append(key)
        }

        // Translations on track 3.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(0.16, 0.0, 0.0))
            input.tracks[3].translations.append(key)
        }
        // Translations on track 4.
        do {
            let key = RawAnimation.TranslationKey(0.0, VecFloat3(0.32, 0.0, 0.0))
            input.tracks[4].translations.append(key)
        }

        XCTAssertTrue(input.validate())

        // Default global tolerances
        do {
            var output = RawAnimation()
            optimizer.setting = loose_setting
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[1].rotations
            XCTAssertEqual(rotations.count, 2)
            XCTAssertEqual(rotations[0].time, 0.0)
            XCTAssertEqual(rotations[1].time, 0.2)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)
            XCTAssertEqual(translations[0].time, 0.0)
            XCTAssertEqual(translations[1].time, 0.3)
        }

        // Overriding root has no effect on its child, even with small tolerance.
        do {
            var output = RawAnimation()
            optimizer.setting = loose_setting
            let joint_override = AnimationOptimizer.Setting(1e-6, 1e6)
            optimizer.joints_setting_override[0] = joint_override
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[1].rotations
            XCTAssertEqual(rotations.count, 2)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)

            optimizer.joints_setting_override = [:]
        }

        // Overriding a joint has effect on itself.
        do {
            var output = RawAnimation()
            optimizer.setting = loose_setting
            let joint_override = AnimationOptimizer.Setting(1e-3, 1e-2)  // 1mm, 1cm
            optimizer.joints_setting_override[1] = joint_override
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[1].rotations
            XCTAssertEqual(rotations.count, 2)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)

            optimizer.joints_setting_override = [:]
        }

        // Overriding leaf has effect up to the root though.
        do {
            var output = RawAnimation()
            optimizer.setting = loose_setting
            let joint_override = AnimationOptimizer.Setting(1e-3, 10.0)   // 1mm, 10m
            optimizer.joints_setting_override[2] = joint_override
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[1].rotations
            XCTAssertEqual(rotations.count, 3)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)

            optimizer.joints_setting_override = [:]
        }

        // Scale at root affects rotation and translation.
        do {
            let key = RawAnimation.ScaleKey(0.0, VecFloat3(0.1, 2.0, 0.1))
            input.tracks[0].scales.append(key)

            var output = RawAnimation()
            optimizer.setting = loose_setting
            let joint_override = AnimationOptimizer.Setting(1.0e-3, 1.0)    // > 1mm 1m
            optimizer.joints_setting_override[1] = joint_override
            optimizer.joints_setting_override[2] = joint_override
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[1].rotations
            XCTAssertEqual(rotations.count, 3)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 3)

            optimizer.joints_setting_override = [:]
            input.tracks[0].scales = []
        }

        // Scale at leaf doesn't affect anything but the leaf.
        do {
            let key = RawAnimation.ScaleKey(0.0, VecFloat3(0.1, 2.0, 0.1))
            input.tracks[4].scales.append(key)

            var output = RawAnimation()
            optimizer.setting = loose_setting
            let joint_override = AnimationOptimizer.Setting(1e-3, 0.5)   // < 1mm .5m
            optimizer.joints_setting_override[1] = joint_override
            XCTAssertTrue(optimizer.eval(input, skeleton, &output))
            XCTAssertEqual(output.num_tracks(), 5)

            let rotations = output.tracks[1].rotations
            XCTAssertEqual(rotations.count, 2)

            let translations = output.tracks[2].translations
            XCTAssertEqual(translations.count, 2)

            optimizer.joints_setting_override = [:]
            input.tracks[4].scales = []
        }
    }
}
