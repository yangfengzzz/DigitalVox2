//
//  skeleton_utils_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/5.
//

import XCTest
@testable import vox_oasis

class SkeletonUtilsTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJointBindPose() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint()]
        let r = raw_skeleton.roots[0]
        r.name = "r0"
        r.transform.translation = VecFloat3.x_axis()
        r.transform.rotation = VecQuaternion.identity()
        r.transform.scale = VecFloat3.zero()

        r.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        let c0 = r.children[0]
        c0.name = "j0"
        c0.transform.translation = VecFloat3.y_axis()
        c0.transform.rotation = -VecQuaternion.identity()
        c0.transform.scale = -VecFloat3.one()

        let c1 = r.children[1]
        c1.name = "j1"
        c1.transform.translation = VecFloat3.z_axis()
        c1.transform.rotation = conjugate(VecQuaternion.identity())
        c1.transform.scale = VecFloat3.one()

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 3)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }
        XCTAssertEqual(skeleton.num_joints(), 3)

        let bind_pose0 = getJointLocalBindPose(skeleton, 0)
        EXPECT_FLOAT3_EQ(bind_pose0.translation, 1.0, 0.0, 0.0)
        EXPECT_QUATERNION_EQ(bind_pose0.rotation, 0.0, 0.0, 0.0, 1.0)
        EXPECT_FLOAT3_EQ(bind_pose0.scale, 0.0, 0.0, 0.0)

        let bind_pose1 = getJointLocalBindPose(skeleton, 1)
        EXPECT_FLOAT3_EQ(bind_pose1.translation, 0.0, 1.0, 0.0)
        EXPECT_QUATERNION_EQ(bind_pose1.rotation, 0.0, 0.0, 0.0, -1.0)
        EXPECT_FLOAT3_EQ(bind_pose1.scale, -1.0, -1.0, -1.0)

        let bind_pose2 = getJointLocalBindPose(skeleton, 2)
        EXPECT_FLOAT3_EQ(bind_pose2.translation, 0.0, 0.0, 1.0)
        EXPECT_QUATERNION_EQ(bind_pose2.rotation, -0.0, -0.0, -0.0, 1.0)
        EXPECT_FLOAT3_EQ(bind_pose2.scale, 1.0, 1.0, 1.0)
    }

    class IterateDFFailTester {
        func eval(_: Int, _: Int) {
            XCTAssertTrue(false)
        }
    }

    class IterateDFTester {
        init(_ _skeleton: SoaSkeleton, _ _start: Int) {
            skeleton_ = _skeleton
            start_ = _start
            num_iterations_ = 0
        }

        func eval(_ _current: Int, _ _parent: Int) {
            let joint = start_ + num_iterations_
            XCTAssertEqual(joint, _current)
            XCTAssertEqual(skeleton_.joint_parents()[joint], _parent)
            num_iterations_ += 1
        }

        func num_iterations() -> Int {
            num_iterations_
        }

        // Iterated skeleton.
        private var skeleton_: SoaSkeleton

        // First joint to explore.
        private var start_: Int

        // Number of iterations completed.
        private var num_iterations_: Int
    }

    func testInterateDF() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        let j0 = raw_skeleton.roots[0]
        j0.name = "j0"
        let j8 = raw_skeleton.roots[1]
        j8.name = "j8"

        j0.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[0].name = "j1"
        j0.children[1].name = "j4"

        j0.children[0].children = [RawSkeleton.Joint()]
        j0.children[0].children[0].name = "j2"

        j0.children[0].children[0].children = [RawSkeleton.Joint()]
        j0.children[0].children[0].children[0].name = "j3"

        j0.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[1].children[0].name = "j5"
        j0.children[1].children[1].name = "j6"

        j0.children[1].children[1].children = [RawSkeleton.Joint()]
        j0.children[1].children[1].children[0].name = "j7"

        j8.children = [RawSkeleton.Joint()]
        j8.children[0].name = "j9"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 10)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }
        XCTAssertEqual(skeleton.num_joints(), 10)

        do {
            let fct = IterateDFTester(skeleton, 0)

            iterateJointsDF(skeleton, fct.eval, -12)
            XCTAssertEqual(fct.num_iterations(), 10)
        }

        do {
            let fct = IterateDFTester(skeleton, 0)
            iterateJointsDF(skeleton, fct.eval)
            XCTAssertEqual(fct.num_iterations(), 10)
        }
        do {
            let fct = IterateDFTester(skeleton, 0)

            iterateJointsDF(skeleton, fct.eval, SoaSkeleton.Constants.kNoParent.rawValue)
            XCTAssertEqual(fct.num_iterations(), 10)
        }
        do {
            let fct = IterateDFTester(skeleton, 0)

            iterateJointsDF(skeleton, fct.eval, 0)
            XCTAssertEqual(fct.num_iterations(), 8)
        }
        do {
            let fct = IterateDFTester(skeleton, 1)

            iterateJointsDF(skeleton, fct.eval, 1)
            XCTAssertEqual(fct.num_iterations(), 3)
        }
        do {
            let fct = IterateDFTester(skeleton, 2)

            iterateJointsDF(skeleton, fct.eval, 2)
            XCTAssertEqual(fct.num_iterations(), 2)
        }
        do {
            let fct = IterateDFTester(skeleton, 3)

            iterateJointsDF(skeleton, fct.eval, 3)
            XCTAssertEqual(fct.num_iterations(), 1)
        }
        do {
            let fct = IterateDFTester(skeleton, 4)

            iterateJointsDF(skeleton, fct.eval, 4)
            XCTAssertEqual(fct.num_iterations(), 4)
        }
        do {
            let fct = IterateDFTester(skeleton, 5)

            iterateJointsDF(skeleton, fct.eval, 5)
            XCTAssertEqual(fct.num_iterations(), 1)
        }
        do {
            let fct = IterateDFTester(skeleton, 6)

            iterateJointsDF(skeleton, fct.eval, 6)
            XCTAssertEqual(fct.num_iterations(), 2)
        }
        do {
            let fct = IterateDFTester(skeleton, 7)

            iterateJointsDF(skeleton, fct.eval, 7)
            XCTAssertEqual(fct.num_iterations(), 1)
        }
        do {
            let fct = IterateDFTester(skeleton, 8)

            iterateJointsDF(skeleton, fct.eval, 8)
            XCTAssertEqual(fct.num_iterations(), 2)
        }
        do {
            let fct = IterateDFTester(skeleton, 9)

            iterateJointsDF(skeleton, fct.eval, 9)
            XCTAssertEqual(fct.num_iterations(), 1)
        }
        let fct = IterateDFFailTester()
        iterateJointsDF(skeleton, fct.eval, 10)
        iterateJointsDF(skeleton, fct.eval, 99)
    }

    class IterateDFReverseTester {
        init(_ _skeleton: SoaSkeleton) {
            skeleton_ = _skeleton
            num_iterations_ = 0
        }

        func eval(_  _current: Int, _ _parent: Int) {
            if (num_iterations_ == 0) {
                XCTAssertTrue(isLeaf(skeleton_, _current))
            }

            // A joint is traversed once.
            let itc = processed_joints_.first { i in
                i == _current
            }
            XCTAssertTrue(itc == nil)

            // A parent can't be traversed before a child.
            let itp = processed_joints_.first { i in
                i == _parent
            }
            XCTAssertTrue(itp == nil)

            // joint processed
            processed_joints_.append(_current)

            // Validates parent id.
            XCTAssertEqual(skeleton_.joint_parents()[_current], _parent)

            num_iterations_ += 1
        }

        func num_iterations() -> Int {
            num_iterations_
        }

        // Iterated skeleton.
        private var skeleton_: SoaSkeleton

        // Number of iterations completed.
        private var num_iterations_: Int

        // Already processed joints
        private var processed_joints_: [Int] = []
    }

    func testInterateDFReverse() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        let j0 = raw_skeleton.roots[0]
        j0.name = "j0"
        let j8 = raw_skeleton.roots[1]
        j8.name = "j8"

        j0.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[0].name = "j1"
        j0.children[1].name = "j4"

        j0.children[0].children = [RawSkeleton.Joint()]
        j0.children[0].children[0].name = "j2"

        j0.children[0].children[0].children = [RawSkeleton.Joint()]
        j0.children[0].children[0].children[0].name = "j3"

        j0.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[1].children[0].name = "j5"
        j0.children[1].children[1].name = "j6"

        j0.children[1].children[1].children = [RawSkeleton.Joint()]
        j0.children[1].children[1].children[0].name = "j7"

        j8.children = [RawSkeleton.Joint()]
        j8.children[0].name = "j9"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 10)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }
        XCTAssertEqual(skeleton.num_joints(), 10)

        do {
            let fct = IterateDFReverseTester(skeleton)
            iterateJointsDFReverse(skeleton, fct.eval)
            XCTAssertEqual(fct.num_iterations(), 10)
        }
    }

    func testIsLeaf() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        let j0 = raw_skeleton.roots[0]
        j0.name = "j0"
        let j8 = raw_skeleton.roots[1]
        j8.name = "j8"

        j0.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[0].name = "j1"
        j0.children[1].name = "j4"

        j0.children[0].children = [RawSkeleton.Joint()]
        j0.children[0].children[0].name = "j2"

        j0.children[0].children[0].children = [RawSkeleton.Joint()]
        j0.children[0].children[0].children[0].name = "j3"

        j0.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        j0.children[1].children[0].name = "j5"
        j0.children[1].children[1].name = "j6"

        j0.children[1].children[1].children = [RawSkeleton.Joint()]
        j0.children[1].children[1].children[0].name = "j7"

        j8.children = [RawSkeleton.Joint()]
        j8.children[0].name = "j9"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 10)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }
        XCTAssertEqual(skeleton.num_joints(), 10)

        XCTAssertFalse(isLeaf(skeleton, 0))
        XCTAssertFalse(isLeaf(skeleton, 1))
        XCTAssertFalse(isLeaf(skeleton, 2))
        XCTAssertTrue(isLeaf(skeleton, 3))
        XCTAssertFalse(isLeaf(skeleton, 4))
        XCTAssertTrue(isLeaf(skeleton, 5))
        XCTAssertFalse(isLeaf(skeleton, 6))
        XCTAssertTrue(isLeaf(skeleton, 7))
        XCTAssertFalse(isLeaf(skeleton, 8))
        XCTAssertTrue(isLeaf(skeleton, 9))
    }
}
