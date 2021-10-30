//
//  AnimatorLayerData.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

import Foundation

internal class AnimatorLayerData {
    var animatorStateDataMap: [String: AnimatorStateData] = [:]
    var srcPlayData: AnimatorStatePlayData = AnimatorStatePlayData()
    var destPlayData: AnimatorStatePlayData = AnimatorStatePlayData()
    var layerState: LayerState = LayerState.Standby
    var crossCurveMark: Int = 0
    var manuallyTransition: AnimatorStateTransition = AnimatorStateTransition()
    var crossFadeTransition: AnimatorStateTransition!

    func switchPlayData() {
        let srcPlayData = destPlayData
        let switchTemp = srcPlayData
        self.srcPlayData = srcPlayData
        destPlayData = switchTemp
    }
}
