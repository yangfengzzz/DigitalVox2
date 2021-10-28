//
//  UpdateFlag.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation

/// Used to update tags.
class UpdateFlag {
    var flag = true
    let _flags: UpdateFlagManager

    init(_flags: UpdateFlagManager) {
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
