//
//  Renderer.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/12.
//

import Foundation

/// Renderable component.
class Renderer: Component {
    // @ignoreClone
    /// Whether it is clipped by the frustum, needs to be turned on camera.enableFrustumCulling.
    var isCulled: Bool = false;

    // @ignoreClone
    internal var _distanceForSort: Float = 0;
    // @ignoreClone
    internal var _onUpdateIndex: Int = -1;
    // @ignoreClone
    internal var _rendererIndex: Int = -1;

    // @ignoreClone
    var _overrideUpdate: Bool = false;

    // @ignoreClone
    private var _transformChangeFlag: UpdateFlag? = nil;
    // @ignoreClone
    private var _mvMatrix: Matrix = Matrix();
    // @ignoreClone
    private var _mvpMatrix: Matrix = Matrix();
    // @ignoreClone
    private var _mvInvMatrix: Matrix = Matrix();
    // @ignoreClone
    private var _normalMatrix: Matrix = Matrix();
    // @ignoreClone
    private var _materialsInstanced: [Bool] = [];

    required init(_ entity: Entity) {
        super.init(entity)
    }

    override func _onEnable() {
        let componentsManager = engine._componentsManager;
        if (_overrideUpdate) {
            componentsManager.addOnUpdateRenderers(self);
        }
        componentsManager.addRenderer(self);
    }

    override func _onDisable() {
        let componentsManager = engine._componentsManager;
        if (_overrideUpdate) {
            componentsManager.removeOnUpdateRenderers(self);
        }
        componentsManager.removeRenderer(self);
    }

    internal override func _onDestroy() {
        let flag = _transformChangeFlag;
        if (flag != nil) {
            flag!.destroy();
            _transformChangeFlag = nil;
        }
    }
}

extension Renderer {
    func update(_ deltaTime: Float) {
    }

    internal func _render(_ camera: Camera) {
    }
}
