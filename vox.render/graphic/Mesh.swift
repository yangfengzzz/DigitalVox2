//
//  Mesh.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

class Mesh: RefObject {
    /// Name.
    var name: String?
    /// The bounding volume of the mesh.
    var bounds: BoundingBox = BoundingBox()

    /**
     * Create mesh.
     * @param engine - Engine
     * @param name - Mesh name
     */
    init(engine: Engine, name: String?) {
        super.init(engine: engine)
        self.name = name
    }
}
