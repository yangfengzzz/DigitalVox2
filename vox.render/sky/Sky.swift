//
//  Sky.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/27.
//

import Foundation

class Sky {
    /// Material of the sky.
    var material: Material?
    /// Mesh of the sky. 
    var mesh: Mesh?
    internal var _matrix: Matrix = Matrix()
}
