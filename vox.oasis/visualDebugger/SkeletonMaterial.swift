//
//  SkeletonMaterial.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/5.
//

import Foundation

class BoneMaterial: BaseMaterial {
    private static var _jointProp = Shader.getPropertyByName("u_joint")

    /// Tiling and offset of main textures.
    var joint: Matrix {
        get {
            shaderData.getBytes(BoneMaterial._jointProp) as! Matrix
        }
        set {
            let joint = shaderData.getBytes(BoneMaterial._jointProp) as! Matrix
            if (newValue !== joint) {
                newValue.cloneTo(target: joint)
            }
        }
    }


    /// Create a pbr base material instance.
    /// - Parameter engine: Engine to which the material belongs
    init(_ engine: Engine) {
        super.init(engine, Shader.find("bone")!)

        shaderData.setBytes(BoneMaterial._jointProp, Matrix())
    }
}

class JointMaterial: BaseMaterial {
    private static var _jointProp = Shader.getPropertyByName("u_joint")

    /// Tiling and offset of main textures.
    var joint: Matrix {
        get {
            shaderData.getBytes(JointMaterial._jointProp) as! Matrix
        }
        set {
            let joint = shaderData.getBytes(JointMaterial._jointProp) as! Matrix
            if (newValue !== joint) {
                newValue.cloneTo(target: joint)
            }
        }
    }


    /// Create a pbr base material instance.
    /// - Parameter engine: Engine to which the material belongs
    init(_ engine: Engine) {
        super.init(engine, Shader.find("joint")!)

        shaderData.setBytes(JointMaterial._jointProp, Matrix())
    }
}
