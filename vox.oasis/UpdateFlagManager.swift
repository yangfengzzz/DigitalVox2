//
//  UpdateFlagManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

class UpdateFlagManager {
    internal var _updateFlags: [UpdateFlag] = []

    func register() -> UpdateFlag {
        return UpdateFlag(_flags: self)
    }

    func distribute() {
        let updateFlags = _updateFlags
        for i in 0..<updateFlags.count {
            updateFlags[i].flag = true
        }
    }
}
