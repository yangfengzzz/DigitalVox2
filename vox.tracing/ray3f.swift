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
}

@inlinable
func ray_point(_ ray: ray3f, _ t: Float) -> vec3f {
    fatalError()
}
