//
//  LiteUpdateFlag.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/// Used to update tags.
class LiteUpdateFlag {
    var flag = true
    let _flags: LiteUpdateFlagManager

    init(_flags: LiteUpdateFlagManager) {
        self._flags = _flags
        _flags._updateFlags.append(self)
    }

    func destroy() {
        let flags = _flags
        flags._updateFlags.removeAll { flag in
            flag === self
        }
    }
}
