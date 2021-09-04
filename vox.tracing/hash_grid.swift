//
//  hash_grid.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/3.
//

import Foundation

// A sparse grid of cells, containing list of points. Cells are stored in
// a dictionary to get sparsity. Helpful for nearest neighbor lookups.
struct hash_grid {
    var cell_size: Float = 0
    var cell_inv_size: Float = 0
    var positions: [vec3f] = []
    var cells: [vec3i: [Int]] = [:]
}

// Gets the cell index
func get_cell_index(_ grid: hash_grid, _ position: vec3f) -> vec3i {
    let scaledpos = position * grid.cell_inv_size
    return vec3i(Int(scaledpos.x), Int(scaledpos.y), Int(scaledpos.z))
}

// Create a hash_grid
func make_hash_grid(_ cell_size: Float) -> hash_grid {
    var grid = hash_grid()
    grid.cell_size = cell_size
    grid.cell_inv_size = 1 / cell_size
    return grid
}

func make_hash_grid(_ positions: [vec3f], _ cell_size: Float) -> hash_grid {
    var grid = hash_grid()
    grid.cell_size = cell_size
    grid.cell_inv_size = 1.0 / cell_size
    for position in positions {
        _ = insert_vertex(&grid, position)
    }
    return grid
}

// Inserts a point into the grid
func insert_vertex(_ grid: inout hash_grid, _  position: vec3f) -> Int {
    let vertex_id = grid.positions.count
    let cell = get_cell_index(grid, position)
    grid.cells[cell]!.append(vertex_id)
    grid.positions.append(position)
    return vertex_id
}

// Finds the nearest neighbors within a given radius
func find_neighbors(_ grid: hash_grid, _ neighbors: inout [Int],
                    _ position: vec3f, _ max_radius: Float, _ skip_id: Int) {
    let cell = get_cell_index(grid, position)
    let cell_radius = Int((max_radius * grid.cell_inv_size) + 1)
    neighbors = []
    let max_radius_squared = max_radius * max_radius
    for k in -cell_radius...cell_radius {
        for j in -cell_radius...cell_radius {
            for i in -cell_radius...cell_radius {
                let ncell = cell &+ vec3i(i, j, k)
                let cell_iterator = grid.cells.first(where: { (key: vec3i, value: [Int]) in
                    key == ncell
                })
                if (cell_iterator == nil) {
                    continue
                }
                let ncell_vertices = cell_iterator!.value
                for vertex_id in ncell_vertices {
                    if (distance_squared(grid.positions[vertex_id], position) >
                            max_radius_squared) {
                        continue
                    }
                    if (vertex_id == skip_id) {
                        continue
                    }
                    neighbors.append(vertex_id)
                }
            }
        }
    }
}

// Finds the nearest neighbors within a given radius
func find_neighbors(_ grid: hash_grid, _ neighbors: inout [Int],
                    _ position: vec3f, _ max_radius: Float) {
    find_neighbors(grid, &neighbors, position, max_radius, -1)
}

func find_neighbors(_ grid: hash_grid, _ neighbors: inout [Int], _ vertex: Int,
                    _ max_radius: Float) {
    find_neighbors(grid, &neighbors, grid.positions[vertex], max_radius, vertex)
}
