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
        view
    }

    func updateUIView(_ nsView: RayRenderer, context: UIViewRepresentableContext<MetalKitRayView>) {
    }
}

let maxFramesInFlight = 3
let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 255) & ~255

let rayStride = MemoryLayout<MPSRayOriginMinDistanceDirectionMaxDistance>.stride
        + MemoryLayout<SIMD3<Float>>.stride

let intersectionStride = MemoryLayout<MPSIntersectionDistancePrimitiveIndexCoordinates>.stride

final class RayRenderer: UIView {
    let metalView = ControllerView(frame: .zero, device: MTLCreateSystemDefaultDevice())

    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var library: MTLLibrary!

    var accelerationStructure: MPSTriangleAccelerationStructure!
    var intersector: MPSRayIntersector!

    var vertexPositionBuffer: MTLBuffer!
    var vertexNormalBuffer: MTLBuffer!
    var vertexColorBuffer: MTLBuffer!
    var rayBuffer: MTLBuffer!
    var shadowRayBuffer: MTLBuffer!
    var intersectionBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    var triangleMaskBuffer: MTLBuffer!

    var rayPipeline: MTLComputePipelineState!
    var shadePipelineState: MTLComputePipelineState!
    var shadowPipeline: MTLComputePipelineState!
    var accumulatePipeline: MTLComputePipelineState!
    var copyPipeline: MTLRenderPipelineState!

    var accumulationTarget0: MTLTexture!
    var accumulationTarget1: MTLTexture!
    var renderTarget0: MTLTexture!
    var renderTarget1: MTLTexture!
    var randomTexture: MTLTexture!

    var semaphore: DispatchSemaphore!
    var size = CGSize.zero
    var uniformBufferOffset = 0
    var uniformBufferIndex = 0

    var frameIndex: uint = 0

    var vertices: [SIMD3<Float>] = []
    var normals: [SIMD3<Float>] = []
    var colors: [SIMD3<Float>] = []
    var masks: [UInt32] = []

    private var hasInitVals = false

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

    func buildPipelines(view: MTKView) {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = view.sampleCount
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "copyVertex")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "copyFragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat

        let computeDescriptor = MTLComputePipelineDescriptor()
        computeDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        do {
            computeDescriptor.computeFunction = library.makeFunction(
                    name: "rayKernel")
            rayPipeline = try device.makeComputePipelineState(
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
                    name: "shadowKernel")
            shadowPipeline = try device.makeComputePipelineState(
                    descriptor: computeDescriptor,
                    options: [],
                    reflection: nil)

            computeDescriptor.computeFunction = library.makeFunction(
                    name: "accumulateKernel")
            accumulatePipeline = try device.makeComputePipelineState(
                    descriptor: computeDescriptor,
                    options: [],
                    reflection: nil)

            copyPipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }

    func createScene() {
        let transform = matrix4x4_translation(0.0, 0.7, 0.0) * matrix4x4_scale(0.5, 0.5, 0.5);
        monkey(transform)
        loadAsset(name: "plane", position: [0, 0, 0], scale: 10)
        loadAsset(name: "sphere", position: [-1.9, 0.0, 0.3], scale: 1)
        loadAsset(name: "sphere", position: [2.9, 0.0, -0.5], scale: 2)
        loadAsset(name: "plane-back", position: [0, 0, -1.5], scale: 10)
    }

    func createBuffers() {
        // Uniform buffer contains a few small values which change from frame to frame. We will have up to 3
        // frames in flight at once, so allocate a range of the buffer for each frame. The GPU will read from
        // one chunk while the CPU writes to the next chunk. Each chunk must be aligned to 256 bytes on macOS
        // and 16 bytes on iOS.
        let uniformBufferSize = alignedUniformsSize * maxFramesInFlight

        // Vertex data should be stored in private or managed buffers on discrete GPU systems (AMD, NVIDIA).
        // Private buffers are stored entirely in GPU memory and cannot be accessed by the CPU. Managed
        // buffers maintain a copy in CPU memory and a copy in GPU memory.
        let options: MTLResourceOptions = {
            #if os(iOS)
            return .storageModeShared
            #else
            return .storageModeManaged
            #endif
        }()

        uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: options)
        // Allocate buffers for vertex positions, colors, and normals. Note that each vertex position is a
        // float3, which is a 16 byte aligned type.
        vertexPositionBuffer = device.makeBuffer(bytes: &vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: options)
        vertexColorBuffer = device.makeBuffer(bytes: &colors, length: colors.count * MemoryLayout<SIMD3<Float>>.stride, options: options)
        vertexNormalBuffer = device.makeBuffer(bytes: &normals, length: normals.count * MemoryLayout<SIMD3<Float>>.stride, options: options)
        triangleMaskBuffer = device.makeBuffer(bytes: &masks, length: masks.count * MemoryLayout<UInt32>.stride, options: options)
    }

    func buildIntersector() {
        intersector = MPSRayIntersector(device: device)
        intersector?.rayDataType = .originMaskDirectionMaxDistance
        intersector?.rayStride = rayStride
        intersector?.rayMaskOptions = .primitive

        accelerationStructure = MPSTriangleAccelerationStructure(device: device)
        accelerationStructure?.vertexBuffer = vertexPositionBuffer
        accelerationStructure?.maskBuffer = triangleMaskBuffer
        accelerationStructure?.triangleCount = vertices.count / 3
        accelerationStructure?.rebuild()
    }

    func updateUniforms() {
        uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        let pointer = uniformBuffer!.contents().advanced(by: uniformBufferOffset)
        let uniforms = pointer.bindMemory(to: Uniforms.self, capacity: 1)

        var camera = Camera()
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

        var light = AreaLight()
        light.position = SIMD3<Float>(0.0, 1.98, 0.0)
        light.forward = SIMD3<Float>(0.0, -1.0, 0.0)
        light.right = SIMD3<Float>(0.25, 0.0, 0.0)
        light.up = SIMD3<Float>(0.0, 0.0, 0.25)
        light.color = SIMD3<Float>(4.0, 4.0, 4.0)

        uniforms.pointee.camera = camera
        uniforms.pointee.light = light

        uniforms.pointee.width = uint(size.width)
        uniforms.pointee.height = uint(size.height)
        uniforms.pointee.frameIndex = frameIndex
        frameIndex += 1
        #if os(OSX)
        uniformBuffer?.didModifyRange(uniformBufferOffset..<(uniformBufferOffset + alignedUniformsSize))
        #endif

        // Advance to the next slot in the uniform buffer
        uniformBufferIndex = (uniformBufferIndex + 1) % maxFramesInFlight;
    }
}

extension RayRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle window size changes by allocating a buffer large enough to contain one standard ray,
        // one shadow ray, and one ray/triangle intersection result per pixel
        let rayCount = Int(size.width * size.height)

        // We use private buffers here because rays and intersection results will be entirely produced
        // and consumed on the GPU
        rayBuffer = device.makeBuffer(length: rayStride * rayCount,
                options: .storageModePrivate)
        shadowRayBuffer = device.makeBuffer(length: rayStride * rayCount,
                options: .storageModePrivate)
        intersectionBuffer = device.makeBuffer(length: intersectionStride * rayCount,
                options: .storageModePrivate)

        let renderTargetDescriptor = MTLTextureDescriptor()
        renderTargetDescriptor.pixelFormat = .rgba32Float
        renderTargetDescriptor.textureType = .type2D
        renderTargetDescriptor.width = Int(size.width)
        renderTargetDescriptor.height = Int(size.height)
        renderTargetDescriptor.storageMode = .private
        renderTargetDescriptor.usage = [.shaderRead, .shaderWrite]
        renderTarget0 = device.makeTexture(descriptor: renderTargetDescriptor)
        renderTarget1 = device.makeTexture(descriptor: renderTargetDescriptor)
        accumulationTarget0 = device.makeTexture(descriptor: renderTargetDescriptor)
        accumulationTarget1 = device.makeTexture(descriptor: renderTargetDescriptor)

        renderTargetDescriptor.pixelFormat = .r32Uint;
        renderTargetDescriptor.usage = .shaderRead;
        #if !os(OSX)
        renderTargetDescriptor.storageMode = .managed;
        #else
        renderTargetDescriptor.storageMode = .shared;
        #endif

        // Generate a texture containing a random integer value for each pixel. This value
        // will be used to decorrelate pixels while drawing pseudorandom numbers from the
        // Halton sequence.
        randomTexture = device.makeTexture(descriptor: renderTargetDescriptor)
        var randomValues = [UInt32](repeating: 0, count: Int(size.width * size.height))
        for i in 0..<Int(size.width * size.height) {
            randomValues[i] = arc4random() % (1024 * 1024);
        }
        randomTexture.replace(region: MTLRegionMake2D(0, 0, Int(size.width), Int(size.height)),
                mipmapLevel: 0, withBytes: &randomValues, bytesPerRow: MemoryLayout<UInt32>.stride * Int(size.width))

        frameIndex = 0

        self.size = size
    }

    func draw(in view: MTKView) {
        if hasInitVals == false {
            mtkView(view, drawableSizeWillChange: view.bounds.size)
            buildPipelines(view: view)
            createScene()
            createBuffers()
            buildIntersector()

            hasInitVals = true
        }

        semaphore.wait()
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        commandBuffer.addCompletedHandler { cb in
            self.semaphore.signal()
        }
        updateUniforms()

        // MARK:- generate rays
        let width = Int(size.width)
        let height = Int(size.height)

        // We will launch a rectangular grid of threads on the GPU to generate the rays. Threads are launched in
        // groups called "threadgroups". We need to align the number of threads to be a multiple of the threadgroup
        // size. We indicated when compiling the pipeline that the threadgroup size would be a multiple of the thread
        // execution width (SIMD group size) which is typically 32 or 64 so 8x8 is a safe threadgroup size which
        // should be small to be supported on most devices. A more advanced application would choose the threadgroup
        // size dynamically.
        let threadsPerGroup = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake((width + threadsPerGroup.width - 1) / threadsPerGroup.width,
                (height + threadsPerGroup.height - 1) / threadsPerGroup.height, 1)

        // First, we will generate rays on the GPU. We create a compute command encoder which will be used to add
        // commands to the command buffer.
        var computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.label = "Generate Rays"
        computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset, index: 0)
        computeEncoder?.setBuffer(rayBuffer, offset: 0, index: 1)
        computeEncoder?.setTexture(randomTexture, index: 0)
        computeEncoder?.setTexture(renderTarget0, index: 1)
        // Bind the ray generation compute pipeline
        computeEncoder?.setComputePipelineState(rayPipeline)
        computeEncoder?.dispatchThreadgroups(threadGroups,
                threadsPerThreadgroup: threadsPerGroup)
        computeEncoder?.endEncoding()

        for bounce in 0..<3 {
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

            // MARK:- shading
            var bounce = bounce
            computeEncoder = commandBuffer.makeComputeCommandEncoder()
            computeEncoder?.label = "Shading"
            computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset, index: 0)
            computeEncoder?.setBuffer(rayBuffer, offset: 0, index: 1)
            computeEncoder?.setBuffer(shadowRayBuffer, offset: 0, index: 2)
            computeEncoder?.setBuffer(intersectionBuffer, offset: 0, index: 3)
            computeEncoder?.setBuffer(vertexColorBuffer, offset: 0, index: 4)
            computeEncoder?.setBuffer(vertexNormalBuffer, offset: 0, index: 5)
            computeEncoder?.setBuffer(triangleMaskBuffer, offset: 0, index: 6)
            computeEncoder?.setBytes(&bounce, length: MemoryLayout<Int>.stride, index: 7)
            computeEncoder?.setTexture(randomTexture, index: 0)
            computeEncoder?.setTexture(renderTarget0, index: 1)
            computeEncoder?.setComputePipelineState(shadePipelineState!)
            computeEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsPerGroup)
            computeEncoder?.endEncoding()

            // MARK:- shadows
            // We intersect rays with the scene, except this time we are intersecting shadow rays. We only need
            // to know whether the shadows rays hit anything on the way to the light source, not which triangle
            // was intersected. Therefore, we can use the "any" intersection type to end the intersection search
            // as soon as any intersection is found. This is typically much faster than finding the nearest
            // intersection. We can also use MPSIntersectionDataTypeDistance, because we don't need the triangle
            // index and barycentric coordinates.
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

            // Finally, we launch a kernel which writes the color computed by the shading kernel into the
            // output image, but only if the corresponding shadow ray does not intersect anything on the way to
            // the light. If the shadow ray intersects a triangle before reaching the light source, the original
            // intersection point was in shadow.
            computeEncoder = commandBuffer.makeComputeCommandEncoder()
            computeEncoder?.label = "Shadows"
            computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset, index: 0)
            computeEncoder?.setBuffer(shadowRayBuffer, offset: 0, index: 1)
            computeEncoder?.setBuffer(intersectionBuffer, offset: 0, index: 2)
            computeEncoder?.setTexture(renderTarget0, index: 0)
            computeEncoder?.setTexture(renderTarget1, index: 1)
            computeEncoder?.setComputePipelineState(shadowPipeline)
            computeEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsPerGroup)
            computeEncoder?.endEncoding()

            swap(&renderTarget0, &renderTarget1)
        }

        // MARK:- accumulation
        // The final kernel averages the current frame's image with all previous frames to reduce noise due
        // random sampling of the scene.
        computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.label = "Accumulation"
        computeEncoder?.setBuffer(uniformBuffer, offset: uniformBufferOffset, index: 0)
        computeEncoder?.setTexture(renderTarget0, index: 0)
        computeEncoder?.setTexture(accumulationTarget0, index: 1)
        computeEncoder?.setTexture(accumulationTarget1, index: 2)
        computeEncoder?.setComputePipelineState(accumulatePipeline)
        computeEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsPerGroup)
        computeEncoder?.endEncoding()

        swap(&accumulationTarget0, &accumulationTarget1)

        //MARK:- ShowUp
        // Copy the resulting image into our view using the graphics pipeline since we can't write directly to
        // it with a compute kernel. We need to delay getting the current render pass descriptor as long as
        // possible to avoid stalling until the GPU/compositor release a drawable. The render pass descriptor
        // may be nil if the window has moved off screen.
        guard let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                      descriptor: descriptor) else {
            return
        }
        renderEncoder.setRenderPipelineState(copyPipeline!)

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
