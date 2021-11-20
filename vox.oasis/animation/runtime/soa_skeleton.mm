//
//  soa_skeleton.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/7.
//

#import "soa_skeleton.h"
#include "../io/archive.h"
#include "skeleton.h"
#include <iostream>

@implementation SoaSkeletonLoader {
    ozz::animation::Skeleton _skeleton;
}

- (bool)LoadSkeleton:(const NSString *)_filename {
    assert(_filename);
    const char *name = [_filename cStringUsingEncoding:NSUTF8StringEncoding];
    std::cout << "Loading skeleton archive " << name << "." << std::endl;
    ozz::io::File file(name, "rb");
    if (!file.opened()) {
        std::cerr << "Failed to open skeleton file " << name << "." << std::endl;
        return false;
    }
    ozz::io::IArchive archive(&file);

    char buf[OZZ_ARRAY_SIZE("ozz-skeleton")];
    archive.LoadBinary(buf, OZZ_ARRAY_SIZE("ozz-skeleton"));

    if (!archive.TestTag<ozz::animation::Skeleton>()) {
        std::cerr << "Failed to load skeleton instance from file "
                  << _filename << "." << std::endl;
        return false;
    }

    // Once the tag is validated, reading cannot fail.
    archive >> _skeleton;

    return true;
}

- (size_t)NumberOfNames {
    return _skeleton.joint_names().size();
}

- (NSString *_Nonnull)NameWithIndex:(size_t)index {
    return [NSString stringWithUTF8String:_skeleton.joint_names()[index]];
}

- (size_t)NumberOfParents {
    return _skeleton.joint_parents().size();
}

- (void)ParentWithIndex:(size_t)index :(size_t *_Nonnull)parent {
    *parent = _skeleton.joint_parents()[index];
}

- (size_t)NumberOfBindPose {
    return _skeleton.joint_bind_poses().size();
}

- (void)PoseWithIndex:(size_t)index :(struct SoaTransform *_Nonnull)pose {
    *pose = _skeleton.joint_bind_poses()[index];
}

@end
