//
//  AnimatorUtils.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

internal class AnimatorUtils {
    private static var _tempVector30: Vector3 = Vector3()
    private static var _tempVector31: Vector3 = Vector3()

    static func scaleWeight(_ s: Vector3, _ w: Float, _ out: Vector3) {
        let sX = s.x
        let sY = s.y
        let sZ = s.z
        out.x = sX > 0 ? pow(abs(sX), w) : -pow(abs(sX), w)
        out.y = sY > 0 ? pow(abs(sY), w) : -pow(abs(sY), w)
        out.z = sZ > 0 ? pow(abs(sZ), w) : -pow(abs(sZ), w)
    }

    static func scaleBlend(_ sa: Vector3, _ sb: Vector3, _ w: Float, _ out: Vector3) {
        let saw = AnimatorUtils._tempVector30
        let sbw = AnimatorUtils._tempVector31
        AnimatorUtils.scaleWeight(sa, 1.0 - w, saw)
        AnimatorUtils.scaleWeight(sb, w, sbw)
        let sng = w > 0.5 ? sb : sa
        out.x = sng.x > 0 ? abs(saw.x * sbw.x) : -abs(saw.x * sbw.x)
        out.y = sng.y > 0 ? abs(saw.y * sbw.y) : -abs(saw.y * sbw.y)
        out.z = sng.z > 0 ? abs(saw.z * sbw.z) : -abs(saw.z * sbw.z)
    }

    static func quaternionWeight(_ s: Quaternion, _ w: Float, _ out: Quaternion) {
        out.x = s.x * w
        out.y = s.y * w
        out.z = s.z * w
        out.w = s.w
    }
}
