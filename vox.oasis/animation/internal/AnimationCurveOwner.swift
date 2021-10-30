//
//  AnimationCurveOwner.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

internal class AnimationCurveOwner {
    var crossCurveMark: Int = 0
    var crossCurveIndex: Int!

    var target: Entity
    var type: Component.Type
    var property: AnimationProperty
    var component: Component
    var defaultValue: InterpolableValue
    var fixedPoseValue: InterpolableValue

    init(target: Entity, type: Component.Type, property: AnimationProperty) {
        self.target = target
        self.type = type
        self.property = property
        switch (property) {
        case AnimationProperty.Position:
            self.defaultValue = .Vector3(Vector3())
            self.fixedPoseValue = .Vector3(Vector3())
            self.component = target.transform
            break
        case AnimationProperty.Rotation:
            self.defaultValue = .Quaternion(Quaternion())
            self.fixedPoseValue = .Quaternion(Quaternion())
            self.component = target.transform
            break
        case AnimationProperty.Scale:
            self.defaultValue = .Vector3(Vector3())
            self.fixedPoseValue = .Vector3(Vector3())
            self.component = target.transform
            break
        case AnimationProperty.BlendShapeWeights:
            self.defaultValue = .FloatArray([Float](repeating: 0, count: 4))
            self.fixedPoseValue = .FloatArray([Float](repeating: 0, count: 4))
            let skinnedMesh: SkinnedMeshRenderer = target.getComponent()
            self.component = skinnedMesh
            break
        }
    }

    func saveDefaultValue() {
        switch (property) {
        case AnimationProperty.Position:
            switch defaultValue {
            case .Vector3(let value):
                self.target.transform.position.cloneTo(target: value)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Rotation:
            switch defaultValue {
            case .Quaternion(let value):
                self.target.transform.rotationQuaternion.cloneTo(target: value)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Scale:
            switch defaultValue {
            case .Vector3(let value):
                self.target.transform.scale.cloneTo(target: value)
            default:
                fatalError()
            }
            break
        default:
            fatalError()
        }
    }

    func saveFixedPoseValue() {
        switch (property) {
        case AnimationProperty.Position:
            switch fixedPoseValue {
            case .Vector3(let value):
                self.target.transform.position.cloneTo(target: value)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Rotation:
            switch fixedPoseValue {
            case .Quaternion(let value):
                self.target.transform.rotationQuaternion.cloneTo(target: value)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Scale:
            switch fixedPoseValue {
            case .Vector3(let value):
                self.target.transform.scale.cloneTo(target: value)
            default:
                fatalError()
            }
            break
        default:
            fatalError()
        }
    }
}
