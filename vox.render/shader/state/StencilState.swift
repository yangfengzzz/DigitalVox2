//
//  StencilState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Metal

/// Stencil state.
class StencilState {
    /// Whether to enable stencil test.
    var enabled: Bool = false
    /// Write the reference value of the stencil buffer.
    var referenceValue: UInt32 = 0
    /// Specifying a bit-wise mask that is used to AND the reference value and the stored stencil value when the test is done.
    var mask: UInt32 = 0xff
    /// Specifying a bit mask to enable or disable writing of individual bits in the stencil planes.
    var writeMask: UInt32 = 0xff
    /// The comparison function of the reference value of the front face of the geometry and the current buffer storage value.
    var compareFunctionFront: MTLCompareFunction = .always
    /// The comparison function of the reference value of the back of the geometry and the current buffer storage value.
    var compareFunctionBack: MTLCompareFunction = .always
    /// specifying the function to use for front face when both the stencil test and the depth test pass.
    var passOperationFront: MTLStencilOperation = .keep
    /// specifying the function to use for back face when both the stencil test and the depth test pass.
    var passOperationBack: MTLStencilOperation = .keep
    /// specifying the function to use for front face when the stencil test fails.
    var failOperationFront: MTLStencilOperation = .keep
    /// specifying the function to use for back face when the stencil test fails.
    var failOperationBack: MTLStencilOperation = .keep
    /// specifying the function to use for front face when the stencil test passes, but the depth test fails.
    var zFailOperationFront: MTLStencilOperation = .keep
    /// specifying the function to use for back face when the stencil test passes, but the depth test fails.
    var zFailOperationBack: MTLStencilOperation = .keep

    internal func _apply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                         _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                         _ hardwareRenderer: MetalRenderer) {
        _platformApply(pipelineDescriptor, depthStencilDescriptor, hardwareRenderer)
    }

    internal func _platformApply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                                 _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                                 _ hardwareRenderer: MetalRenderer) {
        if (enabled) {
            // apply stencil func.
            depthStencilDescriptor.frontFaceStencil.stencilCompareFunction = compareFunctionFront
            depthStencilDescriptor.frontFaceStencil.readMask = mask

            depthStencilDescriptor.backFaceStencil.stencilCompareFunction = compareFunctionBack
            depthStencilDescriptor.backFaceStencil.readMask = mask

            hardwareRenderer.setStencilReferenceValue(referenceValue)
        }

        // apply stencil operation.
        depthStencilDescriptor.frontFaceStencil.stencilFailureOperation = failOperationFront
        depthStencilDescriptor.frontFaceStencil.depthFailureOperation = zFailOperationFront
        depthStencilDescriptor.frontFaceStencil.depthStencilPassOperation = passOperationFront

        depthStencilDescriptor.backFaceStencil.stencilFailureOperation = failOperationBack
        depthStencilDescriptor.backFaceStencil.depthFailureOperation = zFailOperationBack
        depthStencilDescriptor.backFaceStencil.depthStencilPassOperation = passOperationBack

        // apply write mask.
        depthStencilDescriptor.frontFaceStencil.writeMask = writeMask
        depthStencilDescriptor.backFaceStencil.writeMask = writeMask
    }
}
