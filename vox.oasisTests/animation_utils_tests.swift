//
//  animation_utils_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/6.
//

import XCTest
@testable import vox_oasis

class AnimationUtilsTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCountKeyframes() {
        var raw_animation = RawAnimation()
        raw_animation.duration = 1.0
        raw_animation.tracks = [RawAnimation.JointTrack(), RawAnimation.JointTrack()]

        let t_key0 = RawAnimation.TranslationKey(0.0, VecFloat3(93.0, 58.0, 46.0))
        raw_animation.tracks[0].translations.append(t_key0)
        let t_key1 = RawAnimation.TranslationKey(0.9, VecFloat3(46.0, 58.0, 93.0))
        raw_animation.tracks[0].translations.append(t_key1)
        let t_key2 = RawAnimation.TranslationKey(1.0, VecFloat3(46.0, 58.0, 99.0))
        raw_animation.tracks[0].translations.append(t_key2)

        let r_key = RawAnimation.RotationKey(0.7, VecQuaternion(0.0, 1.0, 0.0, 0.0))
        raw_animation.tracks[0].rotations.append(r_key)

        let s_key = RawAnimation.ScaleKey(0.10, VecFloat3(99.0, 26.0, 14.0))
        raw_animation.tracks[1].scales.append(s_key)

        let builder = AnimationBuilder()
        let animation = builder.eval(raw_animation)
        XCTAssertTrue(animation != nil)
        guard let animation = animation else {
            return
        }

        // 4 more tracks than expected due to SoA
        XCTAssertEqual(countTranslationKeyframes(animation, -1), 9)
        XCTAssertEqual(countTranslationKeyframes(animation, 0), 3)
        XCTAssertEqual(countTranslationKeyframes(animation, 1), 2)

        XCTAssertEqual(countRotationKeyframes(animation, -1), 8)
        XCTAssertEqual(countRotationKeyframes(animation, 0), 2)
        XCTAssertEqual(countRotationKeyframes(animation, 1), 2)

        XCTAssertEqual(countScaleKeyframes(animation, -1), 8)
        XCTAssertEqual(countScaleKeyframes(animation, 0), 2)
        XCTAssertEqual(countScaleKeyframes(animation, 1), 2)
    }
}
