//
//  soa_animation.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/7.
//

#ifndef soa_animation_h
#define soa_animation_h

#import <Foundation/Foundation.h>
#import "animation_keyframe.h"

@interface SoaAnimationLoader : NSObject

- (bool)LoadAnimation:(const NSString *_Nonnull)_filename;

// Duration of the animation clip.
- (float)duration;

// The number of joint tracks. Can differ from the data stored in translation/
// rotation/scale buffers because of SoA requirements.
- (size_t)num_tracks;

// Animation name.
- (NSString *_Nonnull)name;

- (size_t)NumberOfTranslations;

- (void)TranslationWithIndex:(size_t)index :(struct Float3Key *_Nonnull)value;

- (size_t)NumberOfRotations;

- (void)RotationWithIndex:(size_t)index :(struct QuaternionKey *_Nonnull)value;

- (size_t)NumberOfScales;

- (void)ScaleWithIndex:(size_t)index :(struct Float3Key *_Nonnull)value;

@end

#endif /* soa_animation_h */
