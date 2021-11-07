//
//  soa_animation.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/7.
//

#import "soa_animation.h"
#import "../math/span.h"
#import "../math/allocator.h"
#import "../math/archive.h"
#include <iostream>

@implementation SoaAnimationLoader {
    // Duration of the animation clip.
    float duration_;

    // The number of joint tracks. Can differ from the data stored in translation/
    // rotation/scale buffers because of SoA requirements.
    int num_tracks_;

    // Animation name.
    char *name_;

    // Stores all translation/rotation/scale keys begin and end of buffers.
    span<Float3Key> translations_;
    span<QuaternionKey> rotations_;
    span<Float3Key> scales_;
}

- (void)Deallocate {
    default_allocator()->Deallocate(as_writable_bytes(translations_).data());

    name_ = nullptr;
    translations_ = {};
    rotations_ = {};
    scales_ = {};
}

- (void)Allocate:(size_t)_name_len :(size_t)_translation_count
        :(size_t)_rotation_count :(size_t)_scale_count {
    // Distributes buffer memory while ensuring proper alignment (serves larger
    // alignment values first).
    static_assert(alignof(Float3Key) >= alignof(QuaternionKey) &&
                    alignof(QuaternionKey) >= alignof(Float3Key) &&
                    alignof(Float3Key) >= alignof(char),
            "Must serve larger alignment values first)");

    assert(name_ == nullptr && translations_.size() == 0 &&
            rotations_.size() == 0 && scales_.size() == 0);

    // Compute overall size and allocate a single buffer for all the data.
    const size_t buffer_size = (_name_len > 0 ? _name_len + 1 : 0) +
            _translation_count * sizeof(Float3Key) +
            _rotation_count * sizeof(QuaternionKey) +
            _scale_count * sizeof(Float3Key);
    span<char> buffer = {static_cast<char *>(default_allocator()->Allocate(
            buffer_size, alignof(Float3Key))),
            buffer_size};

    // Fix up pointers. Serves larger alignment values first.
    translations_ = fill_span<Float3Key>(buffer, _translation_count);
    rotations_ = fill_span<QuaternionKey>(buffer, _rotation_count);
    scales_ = fill_span<Float3Key>(buffer, _scale_count);

    // Let name be nullptr if animation has no name. Allows to avoid allocating
    // this buffer in the constructor of empty animations.
    name_ = _name_len > 0 ? fill_span<char>(buffer, _name_len + 1).data() : nullptr;

    assert(buffer.empty() && "Whole buffer should be consumned");
}

- (void)Load:(IArchive &)_archive :(uint32_t)_version {
    // Destroy animation in case it was already used before.
    [self Deallocate];
    duration_ = 0.f;
    num_tracks_ = 0;

    // No retro-compatibility with anterior versions.
    if (_version != 6) {
        std::cerr << "Unsupported Animation version " << _version << "."
                  << std::endl;
        return;
    }

    _archive >> duration_;

    int32_t num_tracks;
    _archive >> num_tracks;
    num_tracks_ = num_tracks;

    int32_t name_len;
    _archive >> name_len;
    int32_t translation_count;
    _archive >> translation_count;
    int32_t rotation_count;
    _archive >> rotation_count;
    int32_t scale_count;
    _archive >> scale_count;

    [self Allocate:name_len :translation_count :translation_count :scale_count];

    if (name_) {  // nullptr name_ is supported.
        _archive >> MakeArray(name_, name_len);
        name_[name_len] = 0;
    }

    for (Float3Key &key: translations_) {
        _archive >> key.ratio;
        _archive >> key.track;
        _archive >> MakeArray(key.value);
    }

    for (QuaternionKey &key: rotations_) {
        _archive >> key.ratio;
        uint16_t track;
        _archive >> track;
        key.track = track;
        uint8_t largest;
        _archive >> largest;
        key.largest = largest & 3;
        bool sign;
        _archive >> sign;
        key.sign = sign & 1;
        _archive >> MakeArray(key.value);
    }

    for (Float3Key &key: scales_) {
        _archive >> key.ratio;
        _archive >> key.track;
        _archive >> MakeArray(key.value);
    }
}

- (bool)LoadAnimation:(const NSString *)_filename {
    assert(_filename);
    const char *name = [_filename cStringUsingEncoding:NSUTF8StringEncoding];

    std::cout << "Loading animation archive: " << name << "." << std::endl;
    File file(name, "rb");
    if (!file.opened()) {
        std::cerr << "Failed to open animation file " << _filename << "." << std::endl;
        return false;
    }
    IArchive archive(&file);

    char buf[OZZ_ARRAY_SIZE("ozz-animation")];
    archive.LoadBinary(buf, OZZ_ARRAY_SIZE("ozz-animation"));

    uint32_t version;
    archive >> version;

    // Once the tag is validated, reading cannot fail.
    [self Load:archive :version];

    return true;
}

// Duration of the animation clip.
- (float)duration {
    return duration_;
}

// The number of joint tracks. Can differ from the data stored in translation/
// rotation/scale buffers because of SoA requirements.
- (size_t)num_tracks {
    return num_tracks_;
}

// Animation name.
- (NSString *)name {
    return [NSString stringWithUTF8String:name_];
}

- (size_t)NumberOfTranslations {
    return translations_.size();
}

- (void)TranslationWithIndex:(size_t)index :(struct Float3Key *_Nonnull)value {
    *value = translations_[index];
}

- (size_t)NumberOfRotations {
    return rotations_.size();
}

- (void)RotationWithIndex:(size_t)index :(struct QuaternionKey *_Nonnull)value {
    *value = rotations_[index];
}

- (size_t)NumberOfScales {
    return scales_.size();
}

- (void)ScaleWithIndex:(size_t)index :(struct Float3Key *_Nonnull)value {
    *value = scales_[index];
}

@end
