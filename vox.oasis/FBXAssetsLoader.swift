//
//  FBXAssetsLoader.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/21.
//

import MetalKit

class FBXAssetsLoader {
    let loader = FBX2Mesh()
    
    private var _engine: Engine

    init(_ engine: Engine) {
        _engine = engine
    }
    
    func load(_ filename:String, _ skeleton:String)->Entity {
        guard let assetUrl = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Mesh: \(filename) not found")
        }
        guard let skelUrl = Bundle.main.url(forResource: skeleton, withExtension: nil) else {
            fatalError("Skeleton: \(skeleton) not found")
        }
        
        let modelios = loader.load(assetUrl.path, skelUrl.path);
        guard let modelios = modelios else { fatalError() }
        
        let entity = Entity(_engine, filename)
        for i in 0..<modelios.count {
            
        }
        return entity
    }
}
