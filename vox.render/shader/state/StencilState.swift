//
//  StencilState.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

/// Stencil state.
class StencilState {
    /// Whether to enable stencil test.
    var enabled: Bool = false
    /// Write the reference value of the stencil buffer.
    var referenceValue: Float = 0
    /// Specifying a bit-wise mask that is used to AND the reference value and the stored stencil value when the test is done.
    var mask: Int = 0xff
    /// Specifying a bit mask to enable or disable writing of individual bits in the stencil planes.
    var writeMask: Int = 0xff
    /// The comparison function of the reference value of the front face of the geometry and the current buffer storage value.
    var compareFunctionFront: CompareFunction = CompareFunction.Always
    /// The comparison function of the reference value of the back of the geometry and the current buffer storage value.
    var compareFunctionBack: CompareFunction = CompareFunction.Always
    /// specifying the function to use for front face when both the stencil test and the depth test pass.
    var passOperationFront: StencilOperation = StencilOperation.Keep
    /// specifying the function to use for back face when both the stencil test and the depth test pass.
    var passOperationBack: StencilOperation = StencilOperation.Keep
    /// specifying the function to use for front face when the stencil test fails.
    var failOperationFront: StencilOperation = StencilOperation.Keep
    /// specifying the function to use for back face when the stencil test fails.
    var failOperationBack: StencilOperation = StencilOperation.Keep
    /// specifying the function to use for front face when the stencil test passes, but the depth test fails.
    var zFailOperationFront: StencilOperation = StencilOperation.Keep
    /// specifying the function to use for back face when the stencil test passes, but the depth test fails.
    var zFailOperationBack: StencilOperation = StencilOperation.Keep
}
