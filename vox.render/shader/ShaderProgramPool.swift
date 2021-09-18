//
//  ShaderProgramPool.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/18.
//

import Foundation

/// Shader program pool.
internal class ShaderProgramPool {
    private var _cacheHierarchy: Int = 1
    private var _cacheMap: [Int: ShaderProgram] = [:]
    private var _lastQueryMap: [Int: ShaderProgram] = [:]
    private var _lastQueryKey: Int = 0

    ///  Get shader program by macro collection.
    /// - Returns: shader program
    func get() -> ShaderProgram? {
        nil
    }

    /// Cache the shader program.
    /// - Parameter shaderProgram:  shader program
    /// - Remark: The method must return an empty value after calling get() to run normally.
    func cache(_ shaderProgram: ShaderProgram) {
        _lastQueryMap[_lastQueryKey] = shaderProgram
    }

    private func _resizeCacheMapHierarchy(_ cacheMap: [Int: ShaderProgram], _ hierarchy: Int, _ resizeLength: Int) {
    }
}
