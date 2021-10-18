//
//  ParticleRenderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/28.
//

import Metal

enum DirtyFlagType: Int {
    case Position = 0x1
    case Velocity = 0x2
    case Acceleration = 0x4
    case Color = 0x8
    case Alpha = 0x10
    case Size = 0x20
    case StartAngle = 0x40
    case StartTime = 0x80
    case LifeTime = 0x100
    case RotateVelocity = 0x200
    case Scale = 0x400
    case Everything = 0xffffffff
}

/// Blend mode enums of the particle renderer's material.
enum ParticleRendererBlendMode: Int {
    case Transparent = 0
    case Additive = 1
}

/// Particle Renderer Component.
class ParticleRenderer: MeshRenderer {
    /// The max number of indices that Uint16Array can support.
    private static var _uint16VertexLimit: Int = 65535

    private static func _getRandom() -> Float {
        Float.random(in: 0..<1) - 0.5
    }

    private var _vertexStride: Int = 0
    private var _vertices: [Float] = []
    private var _vertexBuffer: MTLBuffer?
    private var _maxCount: Int = 1000
    private var _position: Vector3 = Vector3()
    private var _positionRandomness: Vector3 = Vector3()
    private var _positionArray: [Vector3] = []
    private var _velocity: Vector3 = Vector3()
    private var _velocityRandomness: Vector3 = Vector3()
    private var _acceleration: Vector3 = Vector3()
    private var _accelerationRandomness: Vector3 = Vector3()
    private var _color: Color = Color(1, 1, 1, 1)
    private var _colorRandomness: Float = 0
    private var _size: Float = 1
    private var _sizeRandomness: Float = 0
    private var _alpha: Float = 1
    private var _alphaRandomness: Float = 0
    private var _startAngle: Float = 0
    private var _startAngleRandomness: Float = 0
    private var _rotateVelocity: Float = 0
    private var _rotateVelocityRandomness: Float = 0
    private var _lifetime: Float = 5
    private var _startTimeRandomness: Float = 0
    private var _scale: Float = 1
    private var _isOnce: Bool = false
    private var _onceTime: Float = 0
    private var _time: Float = 0
    private var _isInit: Bool = false
    private var _isStart: Bool = false
    private var _updateDirtyFlag: Int = DirtyFlagType.Everything.rawValue
    private var _isRotateToVelocity: Bool = false
    private var _isUseOriginColor: Bool = false
    private var _isScaleByLifetime: Bool = false
    private var _is2d: Bool = true
    private var _isFadeIn: Bool = false
    private var _isFadeOut: Bool = false
    private var _playOnEnable: Bool = true
    private var _blendMode: ParticleRendererBlendMode = .Transparent

    /// Sprite sheet of texture.
    public var spriteSheet: [(x: Float, y: Float, w: Float, h: Float)] = []

    /// Texture of particle.
    var texture: MTLTexture? {
        get {
            getMaterial()!.shaderData.getTexture("u_texture")
        }
        set {
            if (newValue != nil) {
                shaderData.enableMacro(particleTexture)
                getMaterial()!.shaderData.setTexture("u_texture", newValue!)
            } else {
                shaderData.disableMacro(particleTexture)
            }
        }
    }

    /// Position of particles.
    var position: Vector3 {
        get {
            _position
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Position.rawValue
            _position = newValue
        }
    }

    /// Random range of positions.
    var positionRandomness: Vector3 {
        get {
            _positionRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Position.rawValue
            _positionRandomness = newValue
        }
    }

    /// Array of fixed positions.
    var positionArray: [Vector3] {
        get {
            _positionArray
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Position.rawValue
            _positionArray = newValue
        }
    }

    /// Velocity of particles.
    var velocity: Vector3 {
        get {
            _velocity
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Velocity.rawValue
            _velocity = newValue
        }
    }


    /// Random range of velocity.
    var velocityRandomness: Vector3 {
        get {
            _velocityRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Velocity.rawValue
            _velocityRandomness = newValue
        }
    }

    /// Acceleration of particles.
    var acceleration: Vector3 {
        get {
            _acceleration
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Acceleration.rawValue
            _acceleration = newValue
        }
    }

    /// Random range of acceleration.
    var accelerationRandomness: Vector3 {
        get {
            _accelerationRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Acceleration.rawValue
            _accelerationRandomness = newValue
        }
    }

    /// Color of particles.
    var color: Color {
        get {
            _color
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Color.rawValue
            _color = newValue
        }
    }

    /// Random range of color.
    var colorRandomness: Float {
        get {
            _colorRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Color.rawValue
            _colorRandomness = newValue
        }
    }

    /// Size of particles.
    var size: Float {
        get {
            _size
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Size.rawValue
            _size = newValue
        }
    }

    /// Random range of size.
    var sizeRandomness: Float {
        get {
            _sizeRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Size.rawValue
            _sizeRandomness = newValue
        }
    }

    /// Alpha of particles.
    var alpha: Float {
        get {
            _alpha
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Alpha.rawValue
            _alpha = newValue
        }
    }

    /// Random range of alpha.
    var alphaRandomness: Float {
        get {
            _alphaRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Alpha.rawValue
            _alphaRandomness = newValue
        }
    }

    /// Angle of particles.
    var angle: Float {
        get {
            _startAngle
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.StartAngle.rawValue
            _startAngle = newValue
        }
    }

    /// Random range of angle.
    var angleRandomness: Float {
        get {
            _startAngleRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.StartAngle.rawValue
            _startAngleRandomness = newValue
        }
    }

    /// Rotate velocity of particles.
    var rotateVelocity: Float {
        get {
            _rotateVelocity
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.RotateVelocity.rawValue
            _rotateVelocity = newValue
        }
    }

    /// Random range of rotate velocity.
    var rotateVelocityRandomness: Float {
        get {
            _rotateVelocityRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.RotateVelocity.rawValue
            _rotateVelocityRandomness = newValue
        }
    }

    /// Lifetime of particles.
    var lifetime: Float {
        get {
            _lifetime
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.LifeTime.rawValue
            _lifetime = newValue
            _onceTime = 0
        }
    }

    /// Random range of start time.
    var startTimeRandomness: Float {
        get {
            _startTimeRandomness
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.StartTime.rawValue
            _startTimeRandomness = newValue
            _onceTime = 0
        }
    }

    /// Scale factor of particles.
    var scale: Float {
        get {
            _scale
        }
        set {
            _updateDirtyFlag |= DirtyFlagType.Scale.rawValue
            _scale = newValue
        }
    }

    /// Max count of particles.
    var maxCount: Int {
        get {
            _maxCount
        }
        set {
            _isStart = false
            _isInit = false
            _maxCount = newValue
            _updateDirtyFlag = DirtyFlagType.Everything.rawValue
            mesh = _createMesh()

            _updateBuffer()

            _isInit = true
            shaderData.setFloat("u_time", 0)
        }
    }

    /// Whether play once.
    var isOnce: Bool {
        get {
            _isOnce
        }
        set {
            _time = 0
            shaderData.setInt("u_once", newValue ? 1 : 0)
            _isOnce = newValue
        }
    }

    /// Whether follow the direction of velocity.
    var isRotateToVelocity: Bool {
        get {
            _isRotateToVelocity
        }
        set {
            if (newValue) {
                shaderData.enableMacro(rotateToVelocity)
            } else {
                shaderData.disableMacro(rotateToVelocity)
            }

            _isRotateToVelocity = newValue
        }
    }

    /// Whether use origin color.
    var isUseOriginColor: Bool {
        get {
            _isUseOriginColor
        }
        set {
            if (newValue) {
                shaderData.enableMacro(useOriginColor)
            } else {
                shaderData.disableMacro(useOriginColor)
            }

            _isUseOriginColor = newValue
        }
    }

    /// Whether scale by lifetime.
    var isScaleByLifetime: Bool {
        get {
            _isScaleByLifetime
        }
        set {
            if (newValue) {
                shaderData.enableMacro(ScaleByLifetime)
            } else {
                shaderData.disableMacro(ScaleByLifetime)
            }

            _isScaleByLifetime = newValue
        }
    }

    /// Whether 2D rendering.
    var is2d: Bool {
        get {
            _is2d
        }
        set {
            if (newValue) {
                shaderData.enableMacro(TWO_Dimension)
            } else {
                shaderData.disableMacro(TWO_Dimension)
                getMaterial()!.renderState.rasterState.cullMode = .none
            }

            _is2d = newValue
        }
    }

    /// Whether fade in.
    var isFadeIn: Bool {
        get {
            _isFadeIn
        }
        set {
            if (newValue) {
                shaderData.enableMacro(fadeIn)
            } else {
                shaderData.disableMacro(fadeIn)
            }

            _isFadeIn = newValue
        }
    }

    /// Whether fade out.
    var isFadeOut: Bool {
        get {
            _isFadeOut
        }
        set {
            if (newValue) {
                shaderData.enableMacro(fadeOut)
            } else {
                shaderData.disableMacro(fadeOut)
            }

            _isFadeOut = newValue
        }
    }

    /// Whether play on enable.
    var playOnEnable: Bool {
        get {
            _playOnEnable
        }
        set {
            _playOnEnable = newValue

            if (newValue) {
                start()
            } else {
                stop()
            }
        }
    }

    /// Blend mode of the particle renderer's material.
    var blendMode: ParticleRendererBlendMode {
        get {
            _blendMode
        }
        set {
            let blendState = getMaterial()!.renderState.blendState
            let target = blendState.targetBlendState

            if (newValue == ParticleRendererBlendMode.Transparent) {
                target.enabled = true
                target.sourceColorBlendFactor = .sourceAlpha
                target.destinationColorBlendFactor = .oneMinusSourceAlpha
                target.sourceAlphaBlendFactor = .one
                target.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            } else if (newValue == ParticleRendererBlendMode.Additive) {
                target.enabled = true
                target.sourceColorBlendFactor = .sourceAlpha
                target.destinationColorBlendFactor = .one
                target.sourceAlphaBlendFactor = .one
                target.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            }

            _blendMode = newValue
        }
    }

    internal override func update(_ deltaTime: Float) {
        if (!_isInit || !_isStart) {
            return
        }

        // Stop after play once
        if (_isOnce && _time > _onceTime) {
            return stop()
        }

        if (_updateDirtyFlag != 0) {
            _updateBuffer()
            _updateDirtyFlag = 0
        }

        _time += deltaTime / 1000
        shaderData.setFloat("u_time", _time)
    }

    internal override func _onEnable() {
        super._onEnable()

        if (_playOnEnable) {
            start()
        }
    }
}

extension ParticleRenderer {
    /// Start emitting.
    func start() {
        _isStart = true
        _time = 0
    }

    /// Stop emitting.
    func stop() {
        _isStart = false
    }

    private func _createMaterial() -> Material {
        let material = Material(engine, Shader.find("particle-shader")!)
        let renderState = material.renderState
        let target = renderState.blendState.targetBlendState

        target.enabled = true
        target.sourceColorBlendFactor = .sourceAlpha
        target.destinationColorBlendFactor = .oneMinusSourceAlpha
        target.sourceAlphaBlendFactor = .one
        target.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        renderState.depthState.writeEnabled = false

        material.renderQueueType = RenderQueueType.Transparent

        isUseOriginColor = true
        is2d = true
        isFadeOut = true

        return material
    }

    private func _createMesh() -> BufferMesh {
        fatalError()
    }

    private func _updateBuffer() {
        fatalError()
    }

    private func _updateSingleBuffer(i: Float) {
        fatalError()
    }

    private func _updateSingleUv(i: Int, k0: Float, k1: Float, k2: Float, k3: Float) {
        fatalError()
    }
}
