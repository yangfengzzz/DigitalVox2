/**
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <metal_stdlib>
using namespace metal;
#import "ShaderCommon.h"

constant bool hasColorTexture [[function_constant(BASE_COLORMAP)]];

struct VertexIn {
    float3 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
    float3 normal [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float2 uv;
};

vertex VertexOut vertex_pbr(const VertexIn vertexIn [[stage_in]],
                            constant matrix_float4x4 &u_projMat [[buffer(12)]],
                            constant matrix_float4x4 &u_viewMat [[buffer(13)]],
                            constant matrix_float4x4 &u_modelMat [[buffer(14)]]) {
    VertexOut out {
        .position = u_projMat * u_viewMat * u_modelMat * float4(vertexIn.position, 1.0),
        .worldPosition = (u_modelMat * float4(vertexIn.position, 1.0)).xyz,
        .uv = vertexIn.uv
    };
    return out;
}

fragment float4 fragment_pbr(VertexOut in [[stage_in]],
                             constant float4 &u_baseColor [[buffer(1)]],
                             sampler textureSampler [[sampler(0)]],
                             texture2d<float> u_baseColorSampler [[texture(0)]]) {
    // extract color
    float3 baseColor;
    if (hasColorTexture) {
        baseColor = u_baseColorSampler.sample(textureSampler, in.uv).rgb;
    } else {
        baseColor = u_baseColor.xyz;
    }
    return float4(baseColor, 1.0);
}
