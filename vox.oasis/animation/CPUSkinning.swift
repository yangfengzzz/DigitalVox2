//
//  CPUSkinning.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/21.
//

import Foundation

class CPUSkinning {
    let entity:Entity
    let skinning = CCPUSkinning()
    
    init(_ entity:Entity){
        self.entity = entity
    }
    
    func load(_ skeleton:String, _ animation:String, _ mesh:String){
        guard let skeletonUrl = Bundle.main.url(forResource: skeleton, withExtension: nil) else {
            fatalError("Model: \(skeleton) not found")
        }
        guard let animationUrl = Bundle.main.url(forResource: animation, withExtension: nil) else {
            fatalError("Model: \(animation) not found")
        }
        guard let meshUrl = Bundle.main.url(forResource: mesh, withExtension: nil) else {
            fatalError("Model: \(mesh) not found")
        }
        
        skinning.onInitialize(skeletonUrl.path, animationUrl.path, meshUrl.path)
    }
}
