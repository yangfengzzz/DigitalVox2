//
//  CrossCurveData.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

internal class CrossCurveData {
    var curveOwner: AnimationCurveOwner!
    var srcCurveIndex: Int!
    var destCurveIndex: Int!

    required init() {
    }
}

extension CrossCurveData: EmptyInit {

}
