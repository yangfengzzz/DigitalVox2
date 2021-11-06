//
//  animation_builder_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class AnimationBuilderTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testError() {
        // Instantiates a builder objects with default parameters.
        let builder = AnimationBuilder()

        do {  // Building an empty Animation fails because animation duration
            // must be >= 0.
            var raw_animation = RawAnimation()
            raw_animation.duration = -1.0 // Negative duration.
            XCTAssertFalse(raw_animation.validate())

            // Builds animation
            XCTAssertTrue(builder.eval(raw_animation) == nil)
        }

        do {  // Building an empty Animation fails because animation duration
            // must be >= 0.
            var raw_animation = RawAnimation()
            raw_animation.duration = 0.0  // Invalid duration.
            XCTAssertFalse(raw_animation.validate())

            // Builds animation
            XCTAssertTrue(builder.eval(raw_animation) == nil)
        }

        do {  // Building an animation with too much tracks fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(),
                    count: SoaSkeleton.Constants.kMaxJoints.rawValue + 1)
            XCTAssertFalse(raw_animation.validate())

            // Builds animation
            XCTAssertTrue(builder.eval(raw_animation) == nil)
        }

        do {  // Building default animation succeeds.
            let raw_animation = RawAnimation()
            XCTAssertEqual(raw_animation.duration, 1.0)
            XCTAssertTrue(raw_animation.validate())

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
        }

        do {  // Building an animation with max joints succeeds.
            var raw_animation = RawAnimation()
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(),
                    count: SoaSkeleton.Constants.kMaxJoints.rawValue)
            XCTAssertEqual(raw_animation.num_tracks(), SoaSkeleton.Constants.kMaxJoints.rawValue)
            XCTAssertTrue(raw_animation.validate())

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
        }
    }

    func testBuild() {
        // Instantiates a builder objects with default parameters.
        let builder = AnimationBuilder()

        do {  // Building an Animation with unsorted keys fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack()]

            // Adds 2 unordered keys
            let first_key = RawAnimation.TranslationKey(0.8, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)
            let second_key = RawAnimation.TranslationKey(0.2, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(second_key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building an Animation with invalid key frame's time fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack()]

            // Adds a key with a time greater than animation duration.
            let first_key = RawAnimation.TranslationKey(2.0, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building an Animation with unsorted key frame's time fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack(), RawAnimation.JointTrack()]

            // Adds 2 unsorted keys.
            let first_key = RawAnimation.TranslationKey(0.7, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)
            let second_key = RawAnimation.TranslationKey(0.1, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(second_key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building an Animation with equal key frame's time fails.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack(), RawAnimation.JointTrack()]

            // Adds 2 unsorted keys.
            let key = RawAnimation.TranslationKey(0.7, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(key)
            raw_animation.tracks[0].translations.append(key)

            // Builds animation
            XCTAssertFalse(builder.eval(raw_animation) != nil)
        }

        do {  // Building a valid Animation with empty tracks succeeds.
            var raw_animation = RawAnimation()
            raw_animation.duration = 46.0
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 46)

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
            guard let anim = anim else {
                return
            }
            XCTAssertEqual(anim.duration(), 46.0)
            XCTAssertEqual(anim.num_tracks(), 46)
        }

        do {  // Building a valid Animation with 1 track succeeds.
            var raw_animation = RawAnimation()
            raw_animation.duration = 46.0
            raw_animation.tracks = [RawAnimation.JointTrack()]

            let first_key = RawAnimation.TranslationKey(0.7, VecFloat3.zero())
            raw_animation.tracks[0].translations.append(first_key)

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
            guard let anim = anim else {
                return
            }
            XCTAssertEqual(anim.duration(), 46.0)
            XCTAssertEqual(anim.num_tracks(), 1)
        }
    }

    func testName() {
        // Instantiates a builder objects with default parameters.
        let builder = AnimationBuilder()

        do {  // Building an unnamed animation.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 46)

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
            guard let anim = anim else {
                return
            }

            // Should
            XCTAssertEqual(anim.name(), "")
        }

        do {  // Building an unnamed animation.
            var raw_animation = RawAnimation()
            raw_animation.duration = 1.0
            raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 46)
            raw_animation.name = "46"

            // Builds animation
            let anim = builder.eval(raw_animation)
            XCTAssertTrue(anim != nil)
            guard let anim = anim else {
                return
            }

            // Should
            XCTAssertEqual(anim.name(), "46")
        }
    }

    func testSort() {
        // Instantiates a builder objects with default parameters.
        let builder = AnimationBuilder()

        var raw_animation = RawAnimation()
        raw_animation.duration = 1.0
        raw_animation.tracks = [RawAnimation.JointTrack](repeating: RawAnimation.JointTrack(), count: 4)

        // Raw animation inputs.
        //     0              1
        // --------------------
        // 0 - A     B        |
        // 1 - C  D  E        |
        // 2 - F  G     H  I  J
        // 3 - K  L  M  N     |

        // Final animation.
        //     0              1
        // --------------------
        // 0 - 0     4       11
        // 1 - 1  5  8       12
        // 2 - 2  6     9 14 16
        // 3 - 3  7 10 13    15

        let a = RawAnimation.TranslationKey(0.0 * raw_animation.duration, VecFloat3(1.0, 0.0, 0.0))
        raw_animation.tracks[0].translations.append(a)
        let b = RawAnimation.TranslationKey(0.4 * raw_animation.duration, VecFloat3(3.0, 0.0, 0.0))
        raw_animation.tracks[0].translations.append(b)

        let c = RawAnimation.TranslationKey(0.0 * raw_animation.duration, VecFloat3(2.0, 0.0, 0.0))
        raw_animation.tracks[1].translations.append(c)
        let d = RawAnimation.TranslationKey(0.2 * raw_animation.duration, VecFloat3(6.0, 0.0, 0.0))
        raw_animation.tracks[1].translations.append(d)
        let e = RawAnimation.TranslationKey(0.4 * raw_animation.duration, VecFloat3(8.0, 0.0, 0.0))
        raw_animation.tracks[1].translations.append(e)

        let f = RawAnimation.TranslationKey(0.0 * raw_animation.duration, VecFloat3(12.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(f)
        let g = RawAnimation.TranslationKey(0.2 * raw_animation.duration, VecFloat3(11.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(g)
        let h = RawAnimation.TranslationKey(0.6 * raw_animation.duration, VecFloat3(9.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(h)
        let i = RawAnimation.TranslationKey(0.8 * raw_animation.duration, VecFloat3(7.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(i)
        let j = RawAnimation.TranslationKey(1.0 * raw_animation.duration, VecFloat3(5.0, 0.0, 0.0))
        raw_animation.tracks[2].translations.append(j)

        let k = RawAnimation.TranslationKey(0.0 * raw_animation.duration, VecFloat3(1.0, 0.0, 0.0))
        raw_animation.tracks[3].translations.append(k)
        let l = RawAnimation.TranslationKey(0.2 * raw_animation.duration, VecFloat3(2.0, 0.0, 0.0))
        raw_animation.tracks[3].translations.append(l)
        let m = RawAnimation.TranslationKey(0.4 * raw_animation.duration, VecFloat3(3.0, 0.0, 0.0))
        raw_animation.tracks[3].translations.append(m)
        let n = RawAnimation.TranslationKey(0.6 * raw_animation.duration, VecFloat3(4.0, 0.0, 0.0))
        raw_animation.tracks[3].translations.append(n)

        // Builds animation
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        // Duration must be maintained.
        XCTAssertEqual(animation.duration(), raw_animation.duration)

        // Needs to sample to test the animation.
        let job = SamplingJob()
        let cache = SamplingCache(1)
        var output = [SoaTransform.identity()]
        job.animation = animation
        job.cache = cache

        // Samples and compares the two animations
        do {  // Samples at t = 0
            job.ratio = 0.0
            _ = job.run(&output[...])
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 1.0, 2.0, 12.0, 1.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        }
        do {  // Samples at t = .2
            job.ratio = 0.2
            _ = job.run(&output[...])
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 2.0, 6.0, 11.0, 2.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        }
        do {  // Samples at t = .4
            job.ratio = 0.4
            _ = job.run(&output[...])
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 3.0, 8.0, 10.0, 3.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        }
        do {  // Samples at t = .6
            job.ratio = 0.6
            _ = job.run(&output[...])
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 3.0, 8.0, 9.0, 4.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        }
        do {  // Samples at t = .8
            job.ratio = 0.8
            _ = job.run(&output[...])
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 3.0, 8.0, 7.0, 4.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        }
        do {  // Samples at t = 1
            job.ratio = 1.0
            _ = job.run(&output[...])
            EXPECT_SOAFLOAT3_EQ_EST(output[0].translation, 3.0, 8.0, 5.0, 4.0, 0.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        }
    }
}
