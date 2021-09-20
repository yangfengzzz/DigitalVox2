//
//  MacroInfo.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/20.
//

import Metal

struct MacroInfo {
    var name: MacroName
    var pointer: UnsafeRawPointer? = nil
    var type: MTLDataType? = nil

    init(_ name: MacroName) {
        self.name = name
    }

    init(_ name: MacroName, _ pointer: UnsafeRawPointer, _ type: MTLDataType) {
        self.name = name
        self.type = type
        self.pointer = pointer
    }
}

extension MacroName: Hashable {
}

extension MacroInfo: Hashable {
}
