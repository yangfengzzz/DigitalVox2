//
//  ray2f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

// Ray epsilon
public let ray_eps: Float = 1e-4

public struct ray2f {
    public var o = vec2f(0, 0)
    public var d = vec2f(0, 1)
    public var tmin = ray_eps
    public var tmax = Float.greatestFiniteMagnitude
}

@inlinable
func ray_point(_ ray: ray2f, _ t: Float) -> vec2f {
    ray.o + ray.d * t
}
