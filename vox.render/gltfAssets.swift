//
//  gltfAssets.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/18.
//

import Foundation

class GLTFAssets {
    static func load(fileName: String, ext: String) {
        guard let assetURL = Bundle.main.url(forResource: fileName,
                withExtension: ext,
                subdirectory: "")
                else {
            print("Failed to find asset for URL")
            return
        }

        GLTFAsset.load(with: assetURL, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async {
                if status == .complete {
                    asyncParser(maybeAsset!)
                } else if let error = maybeError {
                    print("Failed to load glTF asset: \(error)")
                }
            }
        }
    }

    static func asyncParser(_ gltf: GLTFAsset) {
        gltf.textures.forEach { tex in
            print(tex.source!)
        }
    }
}




