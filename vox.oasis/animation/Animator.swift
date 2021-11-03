//
//  AnimationComponent.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/3.
//

import MetalKit

class Animator: Component {
    var animations: [String: AnimationClip] = [:]
    var currentAnimation: AnimationClip?
    var animationPaused = true
    var currentTime: Float = 0

    static func load(animation: MDLPackedJointAnimation) -> AnimationClip {
        let name = URL(string: animation.name)?.lastPathComponent ?? "Untitled"
        let animationClip = AnimationClip(name: name)
        var duration: Float = 0
        for (jointIndex, jointPath) in animation.jointPaths.enumerated() {
            var jointAnimation = Animation()

            let rotationTimes = animation.rotations.times
            if let lastTime = rotationTimes.last,
               duration < Float(lastTime) {
                duration = Float(lastTime)
            }
            jointAnimation.rotations = rotationTimes.enumerated().map {
                (index, time) in
                let startIndex = index * animation.jointPaths.count
                let endIndex = startIndex + animation.jointPaths.count

                let array = Array(animation.rotations.floatQuaternionArray[startIndex..<endIndex])
                return KeyQuaternion(time: Float(time),
                        value: array[jointIndex])
            }

            let translationTimes = animation.translations.times
            if let lastTime = translationTimes.last,
               duration < Float(lastTime) {
                duration = Float(lastTime)
            }
            jointAnimation.translations = translationTimes.enumerated().map {
                (index, time) in
                let startIndex = index * animation.jointPaths.count
                let endIndex = startIndex + animation.jointPaths.count

                let array = Array(animation.translations.float3Array[startIndex..<endIndex])
                return Keyframe(time: Float(time),
                        value: array[jointIndex])
            }

            let scaleTimes = animation.scales.times
            if let lastTime = scaleTimes.last,
               duration < Float(lastTime) {
                duration = Float(lastTime)
            }
            jointAnimation.scales = scaleTimes.enumerated().map {
                (index, time) in
                let startIndex = index * animation.jointPaths.count
                let endIndex = startIndex + animation.jointPaths.count

                let array = Array(animation.scales.float3Array[startIndex..<endIndex])
                return Keyframe(time: Float(time),
                        value: array[jointIndex])
            }

            animationClip.jointAnimation[jointPath] = jointAnimation
        }
        return animationClip
    }

    func update(_ deltaTime: Float) {
        if animationPaused == false {
            currentTime += deltaTime
        }
    }

    func runAnimation(name: String) {
        currentAnimation = animations[name]
        if currentAnimation != nil {
            animationPaused = false
            currentTime = 0
        }
    }

    func pauseAnimation() {
        animationPaused = true
    }

    func resumeAnimation() {
        animationPaused = false
    }

    func stopAnimation() {
        animationPaused = true
        currentAnimation = nil
    }
}
