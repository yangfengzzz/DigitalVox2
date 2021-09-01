//
//  IClone.swift
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

import Foundation

/// Clone interface.
protocol IClone {
    associatedtype Object;
    
    /// Clone and return object.
    func clone() -> Object;

    /// Clone to the target object.
    /// - Parameter target: Target object
    func cloneTo(target: Object) -> Void;
}
