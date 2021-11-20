//
//  soa_animation.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/7.
//

#import "soa_animation.h"
#include "../io/archive.h"
#include "animation.h"
#include <iostream>

@implementation SoaAnimationLoader {
    ozz::animation::Animation _animation;
}

- (bool)LoadAnimation:(const NSString *)_filename {
    assert(_filename);
    const char *name = [_filename cStringUsingEncoding:NSUTF8StringEncoding];

    std::cout << "Loading animation archive: " << name << "." << std::endl;
    ozz::io::File file(name, "rb");
    if (!file.opened()) {
        std::cerr << "Failed to open animation file " << _filename << "." << std::endl;
        return false;
    }
    ozz::io::IArchive archive(&file);
    if (!archive.TestTag<ozz::animation::Animation>()) {
        std::cerr << "Failed to load animation instance from file "
                  << _filename << "." << std::endl;
        return false;
    }

    // Once the tag is validated, reading cannot fail.
    archive >> _animation;

    return true;
}

// Duration of the animation clip.
- (float)duration {
    return _animation.duration();
}

// The number of joint tracks. Can differ from the data stored in translation/
// rotation/scale buffers because of SoA requirements.
- (size_t)num_tracks {
    return _animation.num_tracks();
}

// Animation name.
- (NSString *)name {
    return [NSString stringWithUTF8String:_animation.name()];
}

- (size_t)NumberOfTranslations {
    return _animation.translations().size();
}

- (void)TranslationWithIndex:(size_t)index :(struct Float3Key *_Nonnull)value {
    *value = _animation.translations()[index];
}

- (size_t)NumberOfRotations {
    return _animation.rotations().size();
}

- (void)RotationWithIndex:(size_t)index :(struct QuaternionKey *_Nonnull)value {
    *value = _animation.rotations()[index];
}

- (size_t)NumberOfScales {
    return _animation.scales().size();
}

- (void)ScaleWithIndex:(size_t)index :(struct Float3Key *_Nonnull)value {
    *value = _animation.scales()[index];
}

@end
