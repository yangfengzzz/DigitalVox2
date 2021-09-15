//
//  Spherical.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/14.
//

import Foundation

class Spherical {
    public var radius: Float
    public var phi: Float
    public var theta: Float

    init(radius: Float? = nil, phi: Float? = nil, theta: Float? = nil) {
        self.radius = radius != nil ? radius! : 1.0
        self.phi = phi != nil ? phi! : 0
        self.theta = theta != nil ? theta! : 0
    }

    func set(radius: Float, phi: Float, theta: Float) -> Spherical {
        self.radius = radius
        self.phi = phi
        self.theta = theta

        return self
    }

    func makeSafe() -> Spherical {
        phi = simd_clamp(phi, MathUtil.zeroTolerance, Float.pi - MathUtil.zeroTolerance)
        return self
    }

    func setFromVec3(v3: Vector3) -> Spherical {
        radius = v3.length()
        if (radius == 0) {
            theta = 0
            phi = 0
        } else {
            theta = atan2(v3.x, v3.z)
            phi = acos(simd_clamp(v3.y / radius, -1, 1))
        }

        return self
    }

    func setToVec3(v3: Vector3) -> Spherical {
        let sinPhiRadius = sin(phi) * radius

        v3.x = sinPhiRadius * sin(theta)
        v3.y = cos(phi) * radius
        v3.z = sinPhiRadius * cos(theta)

        return self
    }
}
