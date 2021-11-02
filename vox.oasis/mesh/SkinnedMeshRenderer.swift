//
//  SkinnedMeshRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Metal

class SkinnedMeshRenderer: MeshRenderer {
    private static var _jointCountProperty = Shader.getPropertyByName("u_jointCount")
    private static var _jointSamplerProperty = Shader.getPropertyByName("u_jointSampler")
    private static var _jointMatrixProperty = Shader.getPropertyByName("u_jointMatrix")
    private static var _blendShapeWeightsProperty = Shader.getPropertyByName("u_blendShapeWeights")

    private static var _maxJoints: Int = 0

    // @ignoreClone
    public var matrixPalette: [Float] = []
    // @ignoreClone
    public var jointNodes: [Entity?] = []
    // @ignoreClone
    public var jointTexture: MTLTexture?
    public var jointSampler: MTLSamplerState?

    // @ignoreClone
    private var _hasInitJoints: Bool = false
    // @ignoreClone
    private var _mat: Matrix = Matrix()
    // @ignoreClone
    /// Whether to use joint texture. Automatically used when the device can't support the maximum number of bones. */
    private var _useJointTexture: Bool = false
    private var _skin: Skin? = nil
    private var _blendShapeWeights: [Float] = []

    /// The weights of the BlendShapes.
    /// - Remark: Array index is BlendShape index.
    var blendShapeWeights: [Float] {
        get {
            _blendShapeWeights
        }
        set {
            _blendShapeWeights = newValue
        }
    }

    /// Skin Object.
    var skin: Skin? {
        get {
            _skin
        }
        set {
            _skin = newValue
        }
    }

    internal func _updateShaderData(context: RenderContext) {
        super._updateShaderData(context)

        if (!_useJointTexture && !matrixPalette.isEmpty) {
            shaderData.setBytes(SkinnedMeshRenderer._jointMatrixProperty, matrixPalette)
        }

        let mesh = mesh as! ModelMesh
        if (mesh._hasBlendShape) {
            shaderData.setBytes(SkinnedMeshRenderer._blendShapeWeightsProperty, _blendShapeWeights)
            shaderData.enableMacro(HAS_BLENDSHAPE)

            if (mesh._useBlendShapeNormal) {
                shaderData.enableMacro(HAS_BLENDSHAPE_NORMAL)
            } else {
                shaderData.disableMacro(HAS_BLENDSHAPE_NORMAL)
            }
            if (mesh._useBlendShapeTangent) {
                shaderData.enableMacro(HAS_BLENDSHAPE_TANGENT)
            } else {
                shaderData.disableMacro(HAS_BLENDSHAPE_TANGENT)
            }
        } else {
            shaderData.disableMacro(HAS_BLENDSHAPE)
        }
    }

    func _initJoints() {
        if _skin == nil {
            return
        }
        let skin = _skin!

        let joints = skin.joints
        var jointNodes = [Entity?](repeating: nil, count: joints.count)
        for i in 0..<joints.count {
            jointNodes[i] = findByNodeName(entity, joints[i])
        } // end of for
        matrixPalette = [Float](repeating: 0, count: jointNodes.count * 16)
        self.jointNodes = jointNodes

        /// Whether to use a skeleton texture
        // let rhi = entity.engine._hardwareRenderer
        let maxAttribUniformVec4 = 60 // TODO Capability
        let maxJoints = (maxAttribUniformVec4 - 20) / 4
        let jointCount = self.jointNodes.count
        if (jointCount != 0) {
            shaderData.enableMacro(HAS_SKIN)
            shaderData.setBytes(SkinnedMeshRenderer._jointCountProperty, jointCount)
            if (joints.count > maxJoints) {
                _useJointTexture = true
            } else {
                let maxJoints = max(SkinnedMeshRenderer._maxJoints, joints.count)
                SkinnedMeshRenderer._maxJoints = maxJoints
                shaderData.disableMacro(HAS_JOINT_TEXTURE)
                shaderData.enableMacro(JOINTS_COUNT, (SkinnedMeshRenderer._maxJoints, .int))
            }
        } else {
            shaderData.disableMacro(HAS_SKIN)
        }
    }

    private func findByNodeName(_ entity: Entity?, _ nodeName: String) -> Entity? {
        if entity == nil {
            return nil
        }

        let n = entity!.findByName(nodeName)

        if (n != nil) {
            return n
        }

        return findByNodeName(entity!.parent, nodeName)
    }


    internal func update() {
        if (!_hasInitJoints) {
            _initJoints()
            _hasInitJoints = true
        }
        if (_skin != nil) {
            let joints = jointNodes
            let ibms = _skin!.inverseBindMatrices
            let worldToLocal = entity.getInvModelMatrix()

            let mat = _mat
            for i in 0..<joints.count {
                _ = mat.identity()
                if (joints[i] != nil) {
                    Matrix.multiply(left: joints[i]!.transform.worldMatrix, right: ibms[i], out: mat)
                } else {
                    ibms[i].cloneTo(target: mat)
                }
                Matrix.multiply(left: worldToLocal, right: mat, out: mat)

                matrixPalette[i * 16] = mat.elements.columns.0[0]
                matrixPalette[i * 16 + 1] = mat.elements.columns.0[1]
                matrixPalette[i * 16 + 2] = mat.elements.columns.0[2]
                matrixPalette[i * 16 + 3] = mat.elements.columns.0[3]

                matrixPalette[i * 16 + 4] = mat.elements.columns.1[0]
                matrixPalette[i * 16 + 5] = mat.elements.columns.1[1]
                matrixPalette[i * 16 + 6] = mat.elements.columns.1[2]
                matrixPalette[i * 16 + 7] = mat.elements.columns.1[3]

                matrixPalette[i * 16 + 8] = mat.elements.columns.2[0]
                matrixPalette[i * 16 + 9] = mat.elements.columns.2[1]
                matrixPalette[i * 16 + 10] = mat.elements.columns.2[2]
                matrixPalette[i * 16 + 11] = mat.elements.columns.2[3]

                matrixPalette[i * 16 + 12] = mat.elements.columns.3[0]
                matrixPalette[i * 16 + 13] = mat.elements.columns.3[1]
                matrixPalette[i * 16 + 14] = mat.elements.columns.3[2]
                matrixPalette[i * 16 + 15] = mat.elements.columns.3[3]
            }
            if (_useJointTexture) {
                createJointTexture()
            }
        }
    }

    /// Generate joint texture.
    /// Format: (4 * RGBA) * jointCont
    func createJointTexture() {
        if jointTexture == nil {
            let descriptor = MTLTextureDescriptor()
            descriptor.width = 4
            descriptor.height = jointNodes.count
            descriptor.pixelFormat = .rgba32Sint
            jointTexture = engine._hardwareRenderer.device.makeTexture(descriptor: descriptor)
            jointTexture!.replace(region: MTLRegionMake2D(0, 0, descriptor.width, descriptor.height),
                    mipmapLevel: 1, withBytes: matrixPalette,
                    bytesPerRow: descriptor.width * MemoryLayout<Int32>.stride * 4)

            let sampler = MTLSamplerDescriptor()
            sampler.minFilter = .nearest
            jointSampler = engine._hardwareRenderer.device.makeSamplerState(descriptor: sampler)

            shaderData.enableMacro(HAS_JOINT_TEXTURE)
            shaderData.setTexture(SkinnedMeshRenderer._jointSamplerProperty, self.jointTexture!)
        }
    }
}
