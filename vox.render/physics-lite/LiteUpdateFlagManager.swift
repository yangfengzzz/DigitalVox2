//
//  LiteUpdateFlagManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

internal class LiteUpdateFlagManager {
    internal var _updateFlags: [LiteUpdateFlag] = []

    func register() -> LiteUpdateFlag {
        LiteUpdateFlag(_flags: self)
    }

    func distribute() {
        let updateFlags = _updateFlags
        for i in 0..<updateFlags.count {
            updateFlags[i].flag = true
        }
    }
}
