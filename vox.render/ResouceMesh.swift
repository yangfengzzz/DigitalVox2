//
//  ResouceMesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/6.
//

import MetalKit

struct ResouceMesh {
    let mtkMesh: MTKMesh
    let submeshes: [ResouceSubmesh]

    init(mdlMesh: MDLMesh, mtkMesh: MTKMesh) {
        self.mtkMesh = mtkMesh
        submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
            ResouceSubmesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1)
        }
    }
}
