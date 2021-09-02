//
//  IRefObject.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

protocol IRefObject {
    func _getRefCount() -> Int

    func _addRefCount(count: Int)
}
