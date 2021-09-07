//
//  camera_data.swift
//  vox.tracing
//
//  Created by 杨丰 on 2021/9/7.
//

import Foundation

// Camera based on a simple lens model. The camera is placed using a frame.
// Camera projection is described in photographic terms. In particular,
// we specify film size (35mm by default), film aspect ration,
// the lens' focal length, the focus distance and the lens aperture.
// All values are in meters. Here are some common aspect ratios used in video
// and still photography.
// 3:2    on 35 mm:  0.036 x 0.024
// 16:9   on 35 mm:  0.036 x 0.02025 or 0.04267 x 0.024
// 2.35:1 on 35 mm:  0.036 x 0.01532 or 0.05640 x 0.024
// 2.39:1 on 35 mm:  0.036 x 0.01506 or 0.05736 x 0.024
// 2.4:1  on 35 mm:  0.036 x 0.015   or 0.05760 x 0.024 (approx. 2.39 : 1)
// To compute good apertures, one can use the F-stop number from photography
// and set the aperture to focal length over f-stop.
struct camera_data {
    var frame: frame3f = identity3x4f
    var orthographic: Bool = false
    var lens: Float = 0.050
    var film: Float = 0.036
    var aspect: Float = 1.500
    var focus: Float = 10000
    var aperture: Float = 0
}

// Generates a ray from a camera.
func eval_camera(_ camera: camera_data, _ image_uv: vec2f, _ lens_uv: vec2f) -> ray3f {
    let film = camera.aspect >= 1
            ? vec2f(camera.film, camera.film / camera.aspect)
            : vec2f(camera.film * camera.aspect, camera.film)
    if (!camera.orthographic) {
        let q = vec3f(film.x * (0.5 - image_uv.x), film.y * (image_uv.y - 0.5), camera.lens)
        // ray direction through the lens center
        let dc = -normalize(q)
        // point on the lens
        let e = vec3f(lens_uv.x * camera.aperture / 2, lens_uv.y * camera.aperture / 2, 0)
        // point on the focus plane
        let p = dc * camera.focus / abs(dc.z)
        // correct ray direction to account for camera focusing
        let d = normalize(p - e)
        // done
        return ray3f(transform_point(camera.frame, e), transform_direction(camera.frame, d))
    } else {
        let scale = 1 / camera.lens
        let q = vec3f(film.x * (0.5 - image_uv.x) * scale, film.y * (image_uv.y - 0.5) * scale, camera.lens)
        // point on the lens
        let e = vec3f(-q.x, -q.y, 0) + vec3f(lens_uv.x * camera.aperture / 2, lens_uv.y * camera.aperture / 2, 0)
        // point on the focus plane
        let p = vec3f(-q.x, -q.y, -camera.focus)
        // correct ray direction to account for camera focusing
        let d = normalize(p - e)
        // done
        return ray3f(transform_point(camera.frame, e), transform_direction(camera.frame, d))
    }
}
