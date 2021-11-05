//
//  skeleton_builder_tests.swift
//  vox.oasisTests
//
//  Created by 杨丰 on 2021/11/4.
//

import XCTest
@testable import vox_oasis

class SkeletonBuilderTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testError() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        // The default raw skeleton is valid. It has no joint.
        let raw_skeleton = RawSkeleton()
        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 0)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        XCTAssertEqual(skeleton!.num_joints(), 0)
    }

    // Tester object that ensure order (breadth-first) of joints iteration.
    class RawSkeletonIterateBFTester: SkeletonVisitor {
        private var num_joint_: Int = 0

        func visitor(_ _current: RawSkeleton.Joint, _ _parent: RawSkeleton.Joint?) {
            switch (num_joint_) {
            case 0:
                XCTAssertTrue(_current.name == "root" && _parent == nil)
                break
            case 1:
                XCTAssertTrue(_current.name == "j0" && _parent!.name == "root")
                break
            case 2:
                XCTAssertTrue(_current.name == "j1" && _parent!.name == "root")
                break
            case 3:
                XCTAssertTrue(_current.name == "j4" && _parent!.name == "root")
                break
            case 4:
                XCTAssertTrue(_current.name == "j2" && _parent!.name == "j1")
                break
            case 5:
                XCTAssertTrue(_current.name == "j3" && _parent!.name == "j1")
                break
            default:
                XCTAssertTrue(false)
                break

            }
            num_joint_ += 1
        }
    }

    // Tester object that ensure order (depth-first) of joints iteration.
    class RawSkeletonIterateDFTester: SkeletonVisitor {
        private var num_joint_: Int = 0

        func visitor(_ _current: RawSkeleton.Joint, _ _parent: RawSkeleton.Joint?) {
            switch (num_joint_) {
            case 0:
                XCTAssertTrue(_current.name == "root" && _parent == nil)
                break

            case 1:
                XCTAssertTrue(_current.name == "j0" && _parent!.name == "root")
                break

            case 2:
                XCTAssertTrue(_current.name == "j1" && _parent!.name == "root")
                break

            case 3:
                XCTAssertTrue(_current.name == "j2" && _parent!.name == "j1")
                break

            case 4:
                XCTAssertTrue(_current.name == "j3" && _parent!.name == "j1")
                break

            case 5:
                XCTAssertTrue(_current.name == "j4" && _parent!.name == "root")
                break

            default:
                XCTAssertTrue(false)
                break

            }
            num_joint_ += 1
        }
    }

    func testIterate() {
        /*
        5 joints

           *
           |
          root
          / |  \
         j0 j1 j4
            / \
           j2 j3
        */
        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint()]
        let root = raw_skeleton.roots[0]
        root.name = "root"

        root.children = [RawSkeleton.Joint(), RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[0].name = "j0"
        root.children[1].name = "j1"
        root.children[2].name = "j4"

        root.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[1].children[0].name = "j2"
        root.children[1].children[1].name = "j3"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 6)

        var dfTester = RawSkeletonIterateDFTester()
        iterateJointsDF(raw_skeleton, &dfTester)
        var bfTester = RawSkeletonIterateBFTester()
        iterateJointsBF(raw_skeleton, &bfTester)
    }

    func testBuild() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        // 1 joint: the root.
        do {
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let root = raw_skeleton.roots[0]
            root.name = "root"

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), 1)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
            XCTAssertEqual(skeleton!.num_joints(), 1)
            XCTAssertEqual(skeleton!.joint_parents()[0], SoaSkeleton.Constants.kNoParent.rawValue)
        }

        /*
         2 joints

           *
           |
          j0
           |
          j1
        */
        do {
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let root = raw_skeleton.roots[0]
            root.name = "j0"

            root.children = [RawSkeleton.Joint()]
            root.children[0].name = "j1"

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), 2)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
            XCTAssertEqual(skeleton!.num_joints(), 2)
            for i in 0..<skeleton!.num_joints() {
                let parent_index = skeleton!.joint_parents()[i]
                if (skeleton!.joint_names()[i] == "j0") {
                    XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
                } else if skeleton!.joint_names()[i] == "j1" {
                    XCTAssertTrue(skeleton!.joint_names()[parent_index] == "j0")
                } else {
                    XCTAssertTrue(false)
                }
            }
        }

        /*
         3 joints

           *
           |
          j0
          / \
         j1 j2
        */
        do {
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let root = raw_skeleton.roots[0]
            root.name = "j0"

            root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
            root.children[0].name = "j1"
            root.children[1].name = "j2"

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), 3)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
            guard let skeleton = skeleton else {
                return
            }

            XCTAssertEqual(skeleton.num_joints(), 3)
            for i in 0..<skeleton.num_joints() {
                let parent_index = skeleton.joint_parents()[i]
                if (skeleton.joint_names()[i] == "j0") {
                    XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
                } else if (skeleton.joint_names()[i] == "j1") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j2") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else {
                    XCTAssertTrue(false)
                }
            }
        }

        /*
         4 joints

           *
           |
          j0
          / \
         j1 j3
          |
         j2
        */
        do {
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let root = raw_skeleton.roots[0]
            root.name = "j0"

            root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
            root.children[0].name = "j1"
            root.children[1].name = "j3"

            root.children[0].children = [RawSkeleton.Joint()]
            root.children[0].children[0].name = "j2"

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), 4)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
            guard let skeleton = skeleton else {
                return
            }
            XCTAssertEqual(skeleton.num_joints(), 4)
            for i in 0..<skeleton.num_joints() {
                let parent_index = skeleton.joint_parents()[i]
                if (skeleton.joint_names()[i] == "j0") {
                    XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
                } else if (skeleton.joint_names()[i] == "j1") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j2") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j1")
                } else if (skeleton.joint_names()[i] == "j3") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else {
                    XCTAssertTrue(false)
                }
            }
        }

        /*
          4 joints

            *
            |
           j0
           / \
          j1 j2
              |
             j3
         */
        do {
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let root = raw_skeleton.roots[0]
            root.name = "j0"

            root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
            root.children[0].name = "j1"
            root.children[1].name = "j2"

            root.children[1].children = [RawSkeleton.Joint()]
            root.children[1].children[0].name = "j3"

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), 4)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
            guard let skeleton = skeleton else {
                return
            }
            XCTAssertEqual(skeleton.num_joints(), 4)
            for i in 0..<skeleton.num_joints() {
                let parent_index = skeleton.joint_parents()[i]
                if (skeleton.joint_names()[i] == "j0") {
                    XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
                } else if (skeleton.joint_names()[i] == "j1") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j2") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j3") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j2")
                } else {
                    XCTAssertTrue(false)
                }
            }
        }

        /*
         5 joints

           *
           |
          j0
          / \
         j1 j2
            / \
           j3 j4
        */
        do {
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let root = raw_skeleton.roots[0]
            root.name = "j0"

            root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
            root.children[0].name = "j1"
            root.children[1].name = "j2"

            root.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
            root.children[1].children[0].name = "j3"
            root.children[1].children[1].name = "j4"

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), 5)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
            guard let skeleton = skeleton else {
                return
            }
            XCTAssertEqual(skeleton.num_joints(), 5)
            for i in 0..<skeleton.num_joints() {
                let parent_index = skeleton.joint_parents()[i]
                if (skeleton.joint_names()[i] == "j0") {
                    XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
                } else if (skeleton.joint_names()[i] == "j1") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j2") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j3") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j2")
                } else if (skeleton.joint_names()[i] == "j4") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j2")
                } else {
                    XCTAssertTrue(false)
                }
            }
        }

        /*
         6 joints

           *
           |
          j0
          /  \
         j1  j3
          |  / \
         j2 j4 j5
        */
        do {
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint()]
            let root = raw_skeleton.roots[0]
            root.name = "j0"

            root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
            root.children[0].name = "j1"
            root.children[1].name = "j3"

            root.children[0].children = [RawSkeleton.Joint()]
            root.children[0].children[0].name = "j2"

            root.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
            root.children[1].children[0].name = "j4"
            root.children[1].children[1].name = "j5"

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), 6)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
            guard let skeleton = skeleton else {
                return
            }
            XCTAssertEqual(skeleton.num_joints(), 6)
            for i in 0..<skeleton.num_joints() {
                let parent_index = skeleton.joint_parents()[i]
                if (skeleton.joint_names()[i] == "j0") {
                    XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
                } else if (skeleton.joint_names()[i] == "j1") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j2") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j1")
                } else if (skeleton.joint_names()[i] == "j3") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
                } else if (skeleton.joint_names()[i] == "j4") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j3")
                } else if (skeleton.joint_names()[i] == "j5") {
                    XCTAssertEqual(skeleton.joint_names()[parent_index], "j3")
                } else {
                    XCTAssertTrue(false)
                }
            }

            // Skeleton joins should be sorted "per parent" and maintain original
            // children joint order.
            XCTAssertEqual(skeleton.joint_parents()[0], SoaSkeleton.Constants.kNoParent.rawValue)
            XCTAssertEqual(skeleton.joint_names()[0], "j0")
            XCTAssertEqual(skeleton.joint_parents()[1], 0)
            XCTAssertEqual(skeleton.joint_names()[1], "j1")
            XCTAssertEqual(skeleton.joint_parents()[2], 1)
            XCTAssertEqual(skeleton.joint_names()[2], "j2")
            XCTAssertEqual(skeleton.joint_parents()[3], 0)
            XCTAssertEqual(skeleton.joint_names()[3], "j3")
            XCTAssertEqual(skeleton.joint_parents()[4], 3)
            XCTAssertEqual(skeleton.joint_names()[4], "j4")
            XCTAssertEqual(skeleton.joint_parents()[5], 3)
            XCTAssertEqual(skeleton.joint_names()[5], "j5")
        }
    }

    func testJointOrder() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        /*
         7 joints

              *
              |
              j0
           /  |  \
         j1   j3  j7
          |  / \
         j2 j4 j5
               |
               j6
        */
        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint()]
        let root = raw_skeleton.roots[0]
        root.name = "j0"

        root.children = [RawSkeleton.Joint(), RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[0].name = "j1"
        root.children[1].name = "j3"
        root.children[2].name = "j7"

        root.children[0].children = [RawSkeleton.Joint()]
        root.children[0].children[0].name = "j2"

        root.children[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[1].children[0].name = "j4"
        root.children[1].children[1].name = "j5"

        root.children[1].children[1].children = [RawSkeleton.Joint()]
        root.children[1].children[1].children[0].name = "j6"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 8)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }
        XCTAssertEqual(skeleton.num_joints(), 8)

        // Skeleton joints should be sorted "per parent" and maintain original
        // children joint order.
        XCTAssertEqual(skeleton.joint_parents()[0], SoaSkeleton.Constants.kNoParent.rawValue)
        XCTAssertEqual(skeleton.joint_names()[0], "j0")
        XCTAssertEqual(skeleton.joint_parents()[1], 0)
        XCTAssertEqual(skeleton.joint_names()[1], "j1")
        XCTAssertEqual(skeleton.joint_parents()[3], 0)
        XCTAssertEqual(skeleton.joint_names()[3], "j3")
        XCTAssertEqual(skeleton.joint_parents()[7], 0)
        XCTAssertEqual(skeleton.joint_names()[7], "j7")
        XCTAssertEqual(skeleton.joint_parents()[2], 1)
        XCTAssertEqual(skeleton.joint_names()[2], "j2")
        XCTAssertEqual(skeleton.joint_parents()[4], 3)
        XCTAssertEqual(skeleton.joint_names()[4], "j4")
        XCTAssertEqual(skeleton.joint_parents()[5], 3)
        XCTAssertEqual(skeleton.joint_names()[5], "j5")
        XCTAssertEqual(skeleton.joint_parents()[6], 5)
        XCTAssertEqual(skeleton.joint_names()[6], "j6")
    }

    func testMultiRoots() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        /*
        6 joints (2 roots)
           *
          /  \
         j0   j2
         |    |  \
         j1  j3  j5
              |
             j4
        */
        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint(), RawSkeleton.Joint()]

        raw_skeleton.roots[0].name = "j0"
        raw_skeleton.roots[0].children = [RawSkeleton.Joint()]
        raw_skeleton.roots[0].children[0].name = "j1"

        raw_skeleton.roots[1].name = "j2"
        raw_skeleton.roots[1].children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        raw_skeleton.roots[1].children[0].name = "j3"
        raw_skeleton.roots[1].children[1].name = "j5"

        raw_skeleton.roots[1].children[0].children = [RawSkeleton.Joint()]
        raw_skeleton.roots[1].children[0].children[0].name = "j4"

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 6)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }
        XCTAssertEqual(skeleton.num_joints(), 6)
        for i in 0..<skeleton.num_joints() {
            let parent_index = skeleton.joint_parents()[i]
            if (skeleton.joint_names()[i] == "j0") {
                XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
            } else if (skeleton.joint_names()[i] == "j1") {
                XCTAssertEqual(skeleton.joint_names()[parent_index], "j0")
            } else if (skeleton.joint_names()[i] == "j2") {
                XCTAssertEqual(parent_index, SoaSkeleton.Constants.kNoParent.rawValue)
            } else if (skeleton.joint_names()[i] == "j3") {
                XCTAssertEqual(skeleton.joint_names()[parent_index], "j2")
            } else if (skeleton.joint_names()[i] == "j4") {
                XCTAssertEqual(skeleton.joint_names()[parent_index], "j3")
            } else if (skeleton.joint_names()[i] == "j5") {
                XCTAssertEqual(skeleton.joint_names()[parent_index], "j2")
            } else {
                XCTAssertTrue(false)
            }
        }
    }

    func testBindPose() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        /*
         3 joints

           *
           |
          j0
          / \
         j1 j2
        */

        var raw_skeleton = RawSkeleton()
        raw_skeleton.roots = [RawSkeleton.Joint()]
        let root = raw_skeleton.roots[0]
        root.name = "j0"
        root.transform = VecTransform.identity()
        root.transform.translation = VecFloat3(1.0, 2.0, 3.0)
        root.transform.rotation = VecQuaternion(1.0, 0.0, 0.0, 0.0)

        root.children = [RawSkeleton.Joint(), RawSkeleton.Joint()]
        root.children[0].name = "j1"
        root.children[0].transform = VecTransform.identity()
        root.children[0].transform.rotation = VecQuaternion(0.0, 1.0, 0.0, 0.0)
        root.children[0].transform.translation = VecFloat3(4.0, 5.0, 6.0)
        root.children[1].name = "j2"
        root.children[1].transform = VecTransform.identity()
        root.children[1].transform.translation = VecFloat3(7.0, 8.0, 9.0)
        root.children[1].transform.scale = VecFloat3(-27.0, 46.0, 9.0)

        XCTAssertTrue(raw_skeleton.validate())
        XCTAssertEqual(raw_skeleton.num_joints(), 3)

        let skeleton = builder.eval(raw_skeleton)
        XCTAssertTrue(skeleton != nil)
        guard let skeleton = skeleton else {
            return
        }

        // Convert bind pose back to aos.
        var translations: [SimdFloat4] = [SimdFloat4(), SimdFloat4(), SimdFloat4(), SimdFloat4()]
        var scales: [SimdFloat4] = [SimdFloat4(), SimdFloat4(), SimdFloat4(), SimdFloat4()]
        var rotations: [SimdFloat4] = [SimdFloat4(), SimdFloat4(), SimdFloat4(), SimdFloat4()]
        let bind_pose = skeleton.joint_bind_poses()[0]
        transpose3x4(bind_pose.translation, &translations)
        transpose4x4(bind_pose.rotation, &rotations)
        transpose3x4(bind_pose.scale, &scales)

        for i in 0..<skeleton.num_joints() {
            if (skeleton.joint_names()[i] == "j0") {
                EXPECT_SIMDFLOAT_EQ(translations[i], 1.0, 2.0, 3.0, 0.0)
                EXPECT_SIMDFLOAT_EQ(rotations[i], 1.0, 0.0, 0.0, 0.0)
                EXPECT_SIMDFLOAT_EQ(scales[i], 1.0, 1.0, 1.0, 0.0)
            } else if (skeleton.joint_names()[i] == "j1") {
                EXPECT_SIMDFLOAT_EQ(translations[i], 4.0, 5.0, 6.0, 0.0)
                EXPECT_SIMDFLOAT_EQ(rotations[i], 0.0, 1.0, 0.0, 0.0)
                EXPECT_SIMDFLOAT_EQ(scales[i], 1.0, 1.0, 1.0, 0.0)
            } else if (skeleton.joint_names()[i] == "j2") {
                EXPECT_SIMDFLOAT_EQ(translations[i], 7.0, 8.0, 9.0, 0.0)
                EXPECT_SIMDFLOAT_EQ(rotations[i], 0.0, 0.0, 0.0, 1.0)
                EXPECT_SIMDFLOAT_EQ(scales[i], -27.0, 46.0, 9.0, 0.0)
            } else {
                XCTAssertTrue(false)
            }
        }

        // Unused joint from the SoA structure must be properly initialized
        EXPECT_SIMDFLOAT_EQ(translations[3], 0.0, 0.0, 0.0, 0.0)
        EXPECT_SIMDFLOAT_EQ(rotations[3], 0.0, 0.0, 0.0, 1.0)
        EXPECT_SIMDFLOAT_EQ(scales[3], 1.0, 1.0, 1.0, 0.0)
    }

    func testMaxJoints() {
        // Instantiates a builder objects with default parameters.
        let builder = SkeletonBuilder()

        do {  // Inside the domain.
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint](repeating: RawSkeleton.Joint(), count: SoaSkeleton.Constants.kMaxJoints.rawValue)

            XCTAssertTrue(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), SoaSkeleton.Constants.kMaxJoints.rawValue)

            let skeleton = builder.eval(raw_skeleton)
            XCTAssertTrue(skeleton != nil)
        }

        do {  // Outside of the domain.
            var raw_skeleton = RawSkeleton()
            raw_skeleton.roots = [RawSkeleton.Joint](repeating: RawSkeleton.Joint(), count: SoaSkeleton.Constants.kMaxJoints.rawValue + 1)

            XCTAssertFalse(raw_skeleton.validate())
            XCTAssertEqual(raw_skeleton.num_joints(), SoaSkeleton.Constants.kMaxJoints.rawValue + 1)

            XCTAssertTrue(builder.eval(raw_skeleton) == nil)
        }
    }
}
