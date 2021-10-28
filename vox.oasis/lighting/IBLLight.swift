//
//  IBLLight.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

class IBLLight {
    private static var _skyboxDiffuseTextureProperty: ShaderProperty = Shader.getPropertyByName("u_skyboxDiffuse")
    private static var _brdfLutTextureProperty: ShaderProperty = Shader.getPropertyByName("u_brdfLut")

    private var _scene: Scene
    private var _sky: Sky

    var diffuseTexture: MTLTexture?
    var brdfLut: MTLTexture?

    init(_ scene: Scene) {
        _scene = scene
        _sky = _scene.background.sky

        do {
            diffuseTexture = try USDZAssetsLoader(_scene.engine).loadCubeTexture(imageName: "irradiance.png")
        } catch {
            fatalError(error.localizedDescription)
        }
        brdfLut = buildBRDF()
        
        _scene.shaderData.setTexture(IBLLight._skyboxDiffuseTextureProperty, diffuseTexture!)
        _scene.shaderData.setTexture(IBLLight._brdfLutTextureProperty, brdfLut!)
    }

    func buildBRDF() -> MTLTexture? {
        let size = 256
        let rhi = _scene.engine._hardwareRenderer
        guard let brdfFunction = rhi.library?.makeFunction(name: "integrateBRDF"),
              let brdfPipelineState = try? rhi.device.makeComputePipelineState(function: brdfFunction),
              let commandBuffer = rhi.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return nil
        }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rg16Float,
                width: size,
                height: size, mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        let lut = rhi.device.makeTexture(descriptor: descriptor)

        commandEncoder.setComputePipelineState(brdfPipelineState)
        commandEncoder.setTexture(lut, index: 0)
        let threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
        let threadgroups = MTLSizeMake(size / threadsPerThreadgroup.width,
                size / threadsPerThreadgroup.height, 1)
        commandEncoder.dispatchThreadgroups(threadgroups,
                threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        return lut
    }
}
