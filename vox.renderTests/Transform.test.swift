//
//  Transform.test.swift
//  vox.renderTests
//
//  Created by 杨丰 on 2021/9/15.
//

import XCTest
@testable import vox_render

class TransformTests: XCTestCase {
    var canvas: Canvas!
    var engine: Engine!
    var node: Entity!

    override func setUpWithError() throws {
        canvas = Canvas()
        engine = Engine(canvas, MetalRenderer())

        let scene = engine.sceneManager.activeScene
        node = scene!.createRootEntity()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        let transform = node.transform
        XCTAssertEqual(transform!.position.elements, Vector3().elements)
        XCTAssertEqual(transform!.rotation.elements, Vector3().elements)
        XCTAssertEqual(transform!.rotationQuaternion.elements, Quaternion().elements)
        XCTAssertEqual(transform!.worldMatrix.elements, Matrix().elements)
        XCTAssertEqual(transform!.worldPosition.elements, Vector3().elements)
        XCTAssertEqual(transform!.worldRotation.elements, Vector3().elements)
    }

    func testSetPosition() {
        let transform = node.transform
        transform!.position = Vector3(10, 20, 30)
        XCTAssertEqual(transform!.position.elements, Vector3(10, 20, 30).elements)
        XCTAssertEqual(transform!.worldPosition.elements, Vector3(10, 20, 30).elements)
        let result: simd_float4x4 = simd_float4x4([SIMD4<Float>(1, 0, 0, 0),
                                                   SIMD4<Float>(0, 1, 0, 0),
                                                   SIMD4<Float>(0, 0, 1, 0),
                                                   SIMD4<Float>(10, 20, 30, 1),
        ])
        XCTAssertEqual(transform!.localMatrix.elements, result)
        XCTAssertEqual(transform!.worldMatrix.elements, result)
    }

    func testRotation() {
        let transform = node.transform
        transform!.rotation = Vector3(10, 20, 30)
        XCTAssertEqual(Vector3.equals(left: transform!.worldRotation, right: Vector3(10, 20, 30)), true)
        XCTAssertEqual(Quaternion.equals(left: transform!.rotationQuaternion,
                right: Quaternion(0.12767944069578063, 0.14487812541736914, 0.2392983377447303, 0.9515485246437885)), true)
        XCTAssertEqual(Quaternion.equals(left: transform!.worldRotationQuaternion,
                right: Quaternion(0.12767944069578063, 0.14487812541736914, 0.2392983377447303, 0.9515485246437885)), true)
        let mat = Matrix(m11: 0.8434932827949524, m12: 0.49240386486053467, m13: -0.21461017429828644, m14: 0,
                m21: -0.4184120297431946, m22: 0.8528685569763184, m23: 0.31232455372810364, m24: 0,
                m31: 0.33682408928871155, m32: -0.1736481785774231, m33: 0.9254165887832642, m34: 0,
                m41: 0, m42: 0, m43: 0, m44: 1)


        XCTAssertEqual(Matrix.equals(left: transform!.localMatrix, right: mat), true)
        XCTAssertEqual(Matrix.equals(left: transform!.worldMatrix, right: mat), true)
    }

    func testQuat() {
        let transform = node.transform
        transform!.rotationQuaternion = Quaternion(
                0.12767944069578063,
                0.14487812541736914,
                0.2392983377447303,
                0.9515485246437885
        )
        XCTAssertEqual(Vector3.equals(left: transform!.rotation, right: Vector3(10, 20, 30)), true)
        XCTAssertEqual(Vector3.equals(left: transform!.worldRotation, right: Vector3(10, 20, 30)), true)
        XCTAssertEqual(Quaternion.equals(left: transform!.worldRotationQuaternion,
                right: Quaternion(0.12767944069578063, 0.14487812541736914, 0.2392983377447303, 0.9515485246437885)), true)

        let mat = Matrix(m11: 0.8434932827949524, m12: 0.49240386486053467, m13: -0.21461017429828644, m14: 0,
                m21: -0.4184120297431946, m22: 0.8528685569763184, m23: 0.31232455372810364, m24: 0,
                m31: 0.33682408928871155, m32: -0.1736481785774231, m33: 0.9254165887832642, m34: 0,
                m41: 0, m42: 0, m43: 0, m44: 1)

        XCTAssertEqual(Matrix.equals(left: transform!.localMatrix, right: mat), true)
        XCTAssertEqual(Matrix.equals(left: transform!.worldMatrix, right: mat), true)
    }

    func testLookAt() {
        node.transform.position = Vector3(0, 0, 1)
        node.transform.lookAt(worldPosition: Vector3(), worldUp: Vector3(0, 1, 0))
        XCTAssertEqual(node.transform.worldRotation.elements, Vector3(0, 0, 0).elements)
    }
}
