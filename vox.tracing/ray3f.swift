//
//  ray3f.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

public struct ray3f {
    public var o = vec3f(0, 0, 0)
    public var d = vec3f(0, 0, 1)
    public var tmin = ray_eps
    public var tmax = Float.greatestFiniteMagnitude

    public init(_ o: vec3f = vec3f(0, 0, 0), _ d: vec3f = vec3f(0, 0, 1),
                _ tmin: Float = ray_eps, _ tmax: Float = Float.greatestFiniteMagnitude) {
        self.o = o
        self.d = d
        self.tmin = tmin
        self.tmax = tmax
    }
}

@inlinable
func ray_point(_ ray: ray3f, _ t: Float) -> vec3f {
    ray.o + ray.d * t
}
