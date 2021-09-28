//
//  RenderPass.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/17.
//

import Foundation

var passNum = 0

class RenderPass {
    public var name: String
    public var enabled: Bool
    public var priority: Int
    public var renderTarget: RenderTarget?
    public var replaceMaterial: Material?
    public var mask: Layer
    public var renderOverride: Bool
    public var clearFlags: CameraClearFlags?
    public var clearColor: Color?

    /// Create a RenderPass.
    /// - Parameters:
    ///   - name: Pass name
    ///   - priority: Priority, less than 0 before the default pass, greater than 0 after the default pass
    ///   - renderTarget: The specified Render Target
    ///   - replaceMaterial: Replaced material
    ///   - mask: Perform bit and operations with Entity.Layer to filter the objects that this Pass needs to render
    init(_ name: String? = nil,
         _ priority: Int = 0,
         _ renderTarget: RenderTarget? = nil,
         _ replaceMaterial: Material? = nil,
         _ mask: Layer = Layer.Everything
    ) {
        if name != nil {
            self.name = name!
        } else {
            self.name = "RENDER_PASS\(passNum)"
            passNum += 1
        }
        enabled = true
        self.priority = priority
        self.renderTarget = renderTarget
        self.replaceMaterial = replaceMaterial
        self.mask = mask
        renderOverride = false // If renderOverride is set to true, you need to implement the render method
    }

    /// Rendering callback, will be executed if renderOverride is set to true.
    /// - Parameters:
    ///   - camera: Camera
    ///   - opaqueQueue: Opaque queue
    ///   - alphaTestQueue: Alpha test queue
    ///   - transparentQueue: Transparent queue
    func render(_ camera: Camera, _ opaqueQueue: RenderQueue, _ alphaTestQueue: RenderQueue, _ transparentQueue: RenderQueue) {
    }

    /// Post rendering callback.
    /// - Parameters:
    ///   - camera: Camera
    ///   - opaqueQueue: Opaque queue
    ///   - alphaTestQueue: Alpha test queue
    ///   - transparentQueue: Transparent queue
    func preRender(_ camera: Camera, _ opaqueQueue: RenderQueue, _ alphaTestQueue: RenderQueue, _ transparentQueue: RenderQueue) {
    }

    /// Post rendering callback.
    /// - Parameters:
    ///   - camera: Camera
    ///   - opaqueQueue: Opaque queue
    ///   - alphaTestQueue: Alpha test queue
    ///   - transparentQueue: Transparent queue
    func postRender(_ camera: Camera, _ opaqueQueue: RenderQueue, _ alphaTestQueue: RenderQueue, _ transparentQueue: RenderQueue) {
    }
}
