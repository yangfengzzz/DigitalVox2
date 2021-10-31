//
//  soa_float4x4.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/31.
//

import Foundation

// Declare the 4x4 soa matrix type. Uses the column major convention where the
// matrix-times-vector is written v'=Mv:
// [ m.cols[0].x m.cols[1].x m.cols[2].x m.cols[3].x ]   {v.x}
// | m.cols[0].y m.cols[1].y m.cols[2].y m.cols[3].y | * {v.y}
// | m.cols[0].z m.cols[1].y m.cols[2].y m.cols[3].y |   {v.z}
// [ m.cols[0].w m.cols[1].w m.cols[2].w m.cols[3].w ]   {v.1}
struct SoaFloat4x4 {
  // Soa matrix columns.
    var cols:(SoaFloat4, SoaFloat4, SoaFloat4, SoaFloat4);
    
    init(_ cols:(SoaFloat4, SoaFloat4, SoaFloat4, SoaFloat4)) {
        self.cols = cols
    }
}
