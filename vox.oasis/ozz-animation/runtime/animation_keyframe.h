//
//  animation_keyframe.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/31.
//

#ifndef animation_keyframe_h
#define animation_keyframe_h

// Define animation key frame types (translation, rotation, scale). Every type
// as the same base made of the key time ratio and it's track index. This is
// required as key frames are not sorted per track, but sorted by ratio to favor
// cache coherency. Key frame values are compressed, according on their type.
// Decompression is efficient because it's done on SoA data and cached during
// sampling.

// Defines the float3 key frame type, used for translations and scales.
// Translation values are stored as half precision floats with 16 bits per
// component.
struct Float3Key {
    float ratio;
    uint16_t track;
    uint16_t value[3];
};

// Defines the rotation key frame type.
// Rotation value is a quaternion. Quaternion are normalized, which means each
// component is in range [0:1]. This property allows to quantize the 3
// components to 3 signed integer 16 bits values. The 4th component is restored
// at runtime, using the knowledge that |w| = sqrt(1 - (a^2 + b^2 + c^2)).
// The sign of this 4th component is stored using 1 bit taken from the track
// member.
//
// In more details, compression algorithm stores the 3 smallest components of
// the quaternion and restores the largest. The 3 smallest can be pre-multiplied
// by sqrt(2) to gain some precision indeed.
//
// Quantization could be reduced to 11-11-10 bits as often used for animation
// key frames, but in this case RotationKey structure would induce 16 bits of
// padding.
struct QuaternionKey {
    float ratio;
    uint16_t track: 13;   // The track this key frame belongs to.
    uint16_t largest: 2;  // The largest component of the quaternion.
    uint16_t sign: 1;     // The sign of the largest component. 1 for negative.
    int16_t value[3];      // The quantized value of the 3 smallest components.
};

#endif /* animation_keyframe_h */
