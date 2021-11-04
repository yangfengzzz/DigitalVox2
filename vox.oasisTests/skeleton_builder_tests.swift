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
    }
}
