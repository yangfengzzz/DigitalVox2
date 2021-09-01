//
//  RayRenderer.swift
//  vox.Render
//
//  Created by Feng Yang on 2020/7/28.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders
import SwiftUI

struct MetalKitRayView: UIViewRepresentable {
    let view: RayRenderer
    func makeUIView(context: UIViewRepresentableContext<MetalKitRayView>) -> RayRenderer {
        return view
    }
    
    func updateUIView(_ nsView: RayRenderer, context: UIViewRepresentableContext<MetalKitRayView>) {}
}

final class RayRenderer: UIView {
    let metalView = ControllerView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var library: MTLLibrary!
    
    var renderPipeline: MTLRenderPipelineState!
    
    var rayPipeline: MTLComputePipelineState!
    var rayBuffer: MTLBuffer!
    var shadowRayBuffer: MTLBuffer!
    
    var shadePipelineState: MTLComputePipelineState!
    
    var accumulatePipeline: MTLComputePipelineState!
    var accumulationTarget0: MTLTexture!
    var accumulationTarget1: MTLTexture!
    var accelerationStructure: MPSTriangleAccelerationStructure!
    var shadowPipeline: MTLComputePipelineState!
    
    var vertexPositionBuffer: MTLBuffer!
    var vertexNormalBuffer: MTLBuffer!
    var vertexColorBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    var randomBuffer: MTLBuffer!
    
    var intersectionBuffer: MTLBuffer!
    let intersectionStride =
        MemoryLayout<MPSIntersectionDistancePrimitiveIndexCoordinates>.stride
    
    var intersector: MPSRayIntersector!
    let rayStride =
        MemoryLayout<MPSRayOriginMinDistanceDirectionMaxDistance>.stride
            + MemoryLayout<SIMD3<Float>>.stride
    
    let maxFramesInFlight = 3
    let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 255) & ~255
    var semaphore: DispatchSemaphore!
    var size = CGSize.zero
    var randomBufferOffset = 0
    var uniformBufferOffset = 0
    var uniformBufferIndex = 0
    var frameIndex: uint = 0
    
    var renderTarget0: MTLTexture!
    var renderTarget1: MTLTexture!
    
    private var hasInitVals = false
    
    lazy var vertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] =
            MDLVertexAttribute(name: MDLVertexAttributePosition,
                               format: .float3,
                               offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] =
            MDLVertexAttribute(name: MDLVertexAttributeNormal,
                               format: .float2,
                               offset: 0, bufferIndex: 1)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        vertexDescriptor.layouts[1] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        return vertexDescriptor
    }()
    
    var vertices: [SIMD3<Float>] = []
    var normals: [SIMD3<Float>] = []
    var colors: [SIMD3<Float>] = []
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        metalView.device = device
        metalView.colorPixelFormat = .rgba16Float
        metalView.sampleCount = 1
        metalView.drawableSize = metalView.frame.size
        
        self.device = device
        commandQueue = device.makeCommandQueue()!
        library = device.makeDefaultLibrary()
        
        metalView.device = device
        
        super.init(frame: .zero)
        self.addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        metalView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        metalView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        metalView.framebufferOnly = false
        metalView.isMultipleTouchEnabled = true
        metalView.clearColor = MTLClearColor(red: 0.7, green: 0.9,
                                             blue: 1, alpha: 1)
        metalView.delegate = self
        
        semaphore = DispatchSemaphore.init(value: maxFramesInFlight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildAccelerationStructure() {
        accelerationStructure =
            MPSTriangleAccelerationStructure(device: device)
        accelerationStructure?.vertexBuffer = vertexPositionBuffer
        accelerationStructure?.triangleCount = vertices.count / 3
        accelerationStructure?.rebuild()
    }
    
    func buildIntersector() {
        intersector = MPSRayIntersector(device: device)
        intersector?.rayDataType = .originMinDistanceDirectionMaxDistance
        intersector?.rayStride = rayStride
    }
    
    func buildPipelines(view: MTKView) {
        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = view.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        let computeDescriptor = MTLComputePipelineDescriptor()
        computeDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        do {
            computeDescriptor.computeFunction = library.makeFunction(
                name: "shadowKernel")
            shadowPipeline = try device.makeComputePipelineState(
                descriptor: computeDescriptor,
                options: [],
                reflection: nil)
            
            computeDescriptor.computeFunction = library.makeFunction(
                name: "shadeKernel")
            shadePipelineState = try device.makeComputePipelineState(
                descriptor: computeDescriptor,
                options: [],
                reflection: nil)
            
            computeDescriptor.computeFunction = library.makeFunction(
                name: "accumulateKernel")
            accumulatePipeline = try device.makeComputePipelineState(
                descriptor: computeDescriptor,
                options: [],
                reflection: nil)
            
            computeDescriptor.computeFunction = library.makeFunction(
                name: "primaryRays")
            rayPipeline = try device.makeComputePipelineState(
                descriptor: computeDescriptor,
                options: [],
                reflection: nil)
            
            renderPipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createScene() {
        loadAsset(name: "train", position: [-0.3, 0, 0.4], scale: 0.5)
        loadAsset(name: "treefir", position: [0.5, 0, -0.2], scale: 0.7)
        loadAsset(name: "plane", position: [0, 0, 0], scale: 10)
        loadAsset(name: "sphere", position: [-1.9, 0.0, 0.3], scale: 1)
        loadAsset(name: "sphere", position: [2.9, 0.0, -0.5], scale: 2)
        loadAsset(name: "plane-back", position: [0, 0, -1.5], scale: 10)
    }
    
    
    func createBuffers() {
        let uniformBufferSize = alignedUniformsSize * maxFramesInFlight
        
        let options: MTLResourceOptions = {
            #if os(iOS)
            return .storageModeShared
            #else
            return .storageModeManaged
            #endif
        } ()
        
        uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: options)
        randomBuffer = device.makeBuffer(length: 256 * MemoryLayout<SIMD2<Float>>.stride * maxFramesInFlight, options: options)
        vertexPositionBuffer = device.makeBuffer(bytes: &vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: options)
        vertexColorBuffer = device.makeBuffer(bytes: &colors, length: colors.count * MemoryLayout<SIMD3<Float>>.stride, options: options)
        vertexNormalBuffer = device.makeBuffer(bytes: &normals, length: normals.count * MemoryLayout<SIMD3<Float>>.stride, options: options)
    }
    
    func update() {
        updateUniforms()
        updateRandomBuffer()
        uniformBufferIndex = (uniformBufferIndex + 1) % maxFramesInFlight
    }
    
    func updateUniforms() {
        uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        let pointer = uniformBuffer!.contents().advanced(by: uniformBufferOffset)
        let uniforms = pointer.bindMemory(to: RayUniforms.self, capacity: 1)
        
        var camera = RayCamera()
        camera.position = SIMD3<Float>(0.0, 1.0, 3.38)
        camera.forward = SIMD3<Float>(0.0, 0.0, -1.0)
        camera.right = SIMD3<Float>(1.0, 0.0, 0.0)
        camera.up = SIMD3<Float>(0.0, 1.0, 0.0)
        
        let fieldOfView = 45.0 * (Float.pi / 180.0)
        let aspectRatio = Float(size.width) / Float(size.height)
        let imagePlaneHeight = tanf(fieldOfView / 2.0)
        let imagePlaneWidth = aspectRatio * imagePlaneHeight
        
        camera.right *= imagePlaneWidth
        camera.up *= imagePlaneHeight
        
        var light = RayAreaLight()
        light.position = SIMD3<Float>(0.0, 1.98, 0.0)
        light.forward = SIMD3<Float>(0.0, -1.0, 0.0)
        light.right = SIMD3<Float>(0.25, 0.0, 0.0)
        light.up = SIMD3<Float>(0.0, 0.0, 0.25)
        light.color = SIMD3<Float>(4.0, 4.0, 4.0)
        
        uniforms.pointee.camera = camera
        uniforms.pointee.light = light
        
        uniforms.pointee.width = uint(size.width)
        uniforms.pointee.height = uint(size.height)
        uniforms.pointee.blocksWide = ((uniforms.pointee.width) + 15) / 16
        uniforms.pointee.frameIndex = frameIndex
        frameIndex += 1
        #if os(OSX)
        uniformBuffer?.didModifyRange(uniformBufferOffset..<(uniformBufferOffset + alignedUniformsSize))
        #endif
    }
    
    func updateRandomBuffer() {
        randomBufferOffset = 256 * MemoryLayout<SIMD2<Float>>.stride * uniformBufferIndex
        let pointer = randomBuffer!.contents().advanced(by: randomBufferOffset)
        var random = pointer.bindMemory(to: SIMD2<Float>.self, capacity: 256)
        for _ in 0..<256 {
            random.pointee = SIMD2<Float>(Float(drand48()), Float(drand48()) )
            random = random.advanced(by: 1)
        }
        #if os(OSX)
        randomBuffer?.didModifyRange(randomBufferOffset..<(randomBufferOffset + 256 * MemoryLayout<float2>.stride))
        #endif
    }
}


extension RayRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size
        frameIndex = 0
        let renderTargetDescriptor = MTLTextureDescriptor()
        renderTargetDescriptor.pixelFormat = .rgba32Float
        renderTargetDescriptor.textureType = .type2D
        renderTargetDescriptor.width = Int(size.width)
        renderTargetDescriptor.height = Int(size.height)
        renderTargetDescriptor.storageMode = .private
        renderTargetDescriptor.usage = [.shaderRead, .shaderWrite]
        renderTarget0 = device.makeTexture(descriptor: renderTargetDescriptor)
        renderTarget1 = device.makeTexture(descriptor: renderTargetDescriptor)
        
        let rayCount = Int(size.width * size.height)
        rayBuffer = device.makeBuffer(length: rayStride * rayCount,
                                      options: .storageModePrivate)
        shadowRayBuffer = device.makeBuffer(length: rayStride * rayCount,
                                            options: .storageModePrivate)
        
        accumulationTarget0 = device.makeTexture(descriptor: renderTargetDescriptor)
        accumulationTarget1 = device.makeTexture(descriptor: renderTargetDescriptor)
        
        intersectionBuffer = device.makeBuffer(
            length: intersectionStride * rayCount,
            options: .storageModePrivate)
    }
    
    func draw(in view: MTKView) {
        if hasInitVals == false {
            mtkView(view, drawableSizeWillChange: view.bounds.size)
            buildPipelines(view: view)
            createScene()
            createBuffers()
            buildIntersector()
            buildAccelerationStructure()
            
            hasInitVals = true
        }
        
        semaphore.wait()
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        commandBuffer.addCompletedHandler { cb in
            self.semaphore.signal()
        }
        update()
        
        // MARK: generate rays
        let width = Int(size.width)
        let height = Int(size.height)
        let threadsPerGroup = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake((width + threadsPerGroup.width - 1)
            / threadsPerGroup.width,
                                       (height + threadsPerGroup.height - 1)
                                        / threadsPerGroup.height,
                                       1)
        var computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.label = "Generate Rays"
        computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset,
                                  index: 0)
        computeEncoder?.setBuffer(rayBuffer, offset: 0, index: 1)
        computeEncoder?.setBuffer(randomBuffer, offset: randomBufferOffset,
                                  index: 2)
        computeEncoder?.setTexture(renderTarget0, index: 0)
        computeEncoder?.setComputePipelineState(rayPipeline)
        computeEncoder?.dispatchThreadgroups(threadGroups,
                                             threadsPerThreadgroup: threadsPerGroup)
        computeEncoder?.endEncoding()
        
        for _ in 0..<3 {
            // MARK: generate intersections between rays and model triangles
            intersector?.intersectionDataType = .distancePrimitiveIndexCoordinates
            intersector?.encodeIntersection(
                commandBuffer: commandBuffer,
                intersectionType: .nearest,
                rayBuffer: rayBuffer,
                rayBufferOffset: 0,
                intersectionBuffer: intersectionBuffer,
                intersectionBufferOffset: 0,
                rayCount: width * height,
                accelerationStructure: accelerationStructure)
            
            // MARK: shading
            
            computeEncoder = commandBuffer.makeComputeCommandEncoder()
            computeEncoder?.label = "Shading"
            computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset,
                                      index: 0)
            computeEncoder?.setBuffer(rayBuffer, offset: 0, index: 1)
            computeEncoder?.setBuffer(shadowRayBuffer, offset: 0, index: 2)
            computeEncoder?.setBuffer(intersectionBuffer, offset: 0, index: 3)
            computeEncoder?.setBuffer(vertexColorBuffer, offset: 0, index: 4)
            computeEncoder?.setBuffer(vertexNormalBuffer, offset: 0, index: 5)
            computeEncoder?.setBuffer(randomBuffer, offset: randomBufferOffset,
                                      index: 6)
            computeEncoder?.setTexture(renderTarget0, index: 0)
            computeEncoder?.setComputePipelineState(shadePipelineState!)
            computeEncoder?.dispatchThreadgroups(
                threadGroups,
                threadsPerThreadgroup: threadsPerGroup)
            computeEncoder?.endEncoding()
            
            // MARK: shadows
            intersector?.label = "Shadows Intersector"
            intersector?.intersectionDataType = .distance
            intersector?.encodeIntersection(
                commandBuffer: commandBuffer,
                intersectionType: .any,
                rayBuffer: shadowRayBuffer,
                rayBufferOffset: 0,
                intersectionBuffer: intersectionBuffer,
                intersectionBufferOffset: 0,
                rayCount: width * height,
                accelerationStructure: accelerationStructure)
            
            computeEncoder = commandBuffer.makeComputeCommandEncoder()
            computeEncoder?.label = "Shadows"
            computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset,
                                      index: 0)
            computeEncoder?.setBuffer(shadowRayBuffer, offset: 0, index: 1)
            computeEncoder?.setBuffer(intersectionBuffer, offset: 0, index: 2)
            computeEncoder?.setTexture(renderTarget0, index: 0)
            computeEncoder?.setTexture(renderTarget1, index: 1)
            computeEncoder?.setComputePipelineState(shadowPipeline!)
            computeEncoder?.dispatchThreadgroups(
                threadGroups,
                threadsPerThreadgroup: threadsPerGroup)
            computeEncoder?.endEncoding()
            
            swap(&renderTarget0, &renderTarget1)
        }
        // MARK: accumulation
        
        computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.label = "Accumulation"
        computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset,
                                  index: 0)
        computeEncoder?.setTexture(renderTarget0, index: 0)
        computeEncoder?.setTexture(accumulationTarget0, index: 1)
        computeEncoder?.setTexture(accumulationTarget1, index: 2)
        computeEncoder?.setComputePipelineState(accumulatePipeline)
        computeEncoder?.dispatchThreadgroups(threadGroups,
                                             threadsPerThreadgroup: threadsPerGroup)
        computeEncoder?.endEncoding()
        
        swap(&accumulationTarget0, &accumulationTarget1)
        
        guard let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                descriptor: descriptor) else {
                    return
        }
        renderEncoder.setRenderPipelineState(renderPipeline!)
        
        // MARK: draw call
        renderEncoder.setFragmentTexture(accumulationTarget0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
