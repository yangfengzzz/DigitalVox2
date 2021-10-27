//
//  LitePhysicsMaterial.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Physics material describes how to handle colliding objects (friction, bounciness).
class LitePhysicsMaterial: IPhysicsMaterial {
    init(staticFriction: Float,
         dynamicFriction: Float,
         bounciness: Float,
         frictionCombine: Float,
         bounceCombine: Float) {
    }

    func setBounciness(_ value: Float) {
        fatalError("Physics-lite don't support physics material. Use Physics-PhysX instead!");
    }

    func setDynamicFriction(_ value: Float) {
        fatalError("Physics-lite don't support physics material. Use Physics-PhysX instead!");
    }

    func setStaticFriction(_ value: Float) {
        fatalError("Physics-lite don't support physics material. Use Physics-PhysX instead!");
    }

    func setBounceCombine(_ value: Float) {
        fatalError("Physics-lite don't support physics material. Use Physics-PhysX instead!");
    }

    func setFrictionCombine(_ value: Float) {
        fatalError("Physics-lite don't support physics material. Use Physics-PhysX instead!");
    }
}
