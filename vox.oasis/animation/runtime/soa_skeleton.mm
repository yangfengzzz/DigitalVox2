//
//  soa_skeleton.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/7.
//

#import "soa_skeleton.h"
#import "../maths/csoa_float.h"
#import "../span.h"
#import "../memory/allocator.h"
#import "../io/archive.h"
#import "../maths/soa_math_archive.h"
#include <iostream>

@implementation SoaSkeletonLoader {
    // Bind pose of every joint in local space.
    span<SoaTransform> joint_bind_poses_;

    // Array of joint parent indexes.
    span<int16_t> joint_parents_;

    // Stores the name of every joint in an array of c-strings.
    span<char *> joint_names_;
}

- (void)Deallocate {
    default_allocator()->Deallocate(as_writable_bytes(joint_bind_poses_).data());
    joint_bind_poses_ = {};
    joint_names_ = {};
    joint_parents_ = {};
}

- (char *)Allocate:(size_t)_chars_size :(size_t)_num_joints {
    // Distributes buffer memory while ensuring proper alignment (serves larger
    // alignment values first).
    static_assert(alignof(SoaTransform) >= alignof(char *) &&
                    alignof(char *) >= alignof(int16_t) &&
                    alignof(int16_t) >= alignof(char),
            "Must serve larger alignment values first)");

    assert(joint_bind_poses_.size() == 0 && joint_names_.size() == 0 &&
            joint_parents_.size() == 0);

    // Early out if no joint.
    if (_num_joints == 0) {
        return nullptr;
    }

    // Bind poses have SoA format
    const size_t num_soa_joints = (_num_joints + 3) / 4;
    const size_t joint_bind_poses_size =
            num_soa_joints * sizeof(SoaTransform);
    const size_t names_size = _num_joints * sizeof(char *);
    const size_t joint_parents_size = _num_joints * sizeof(int16_t);
    const size_t buffer_size =
            names_size + _chars_size + joint_parents_size + joint_bind_poses_size;

    // Allocates whole buffer.
    span<char> buffer = {static_cast<char *>(default_allocator()->Allocate(
            buffer_size, alignof(SoaTransform))),
            buffer_size};

    // Serves larger alignment values first.
    // Bind pose first, biggest alignment.
    joint_bind_poses_ = fill_span<SoaTransform>(buffer, num_soa_joints);

    // Then names array, second biggest alignment.
    joint_names_ = fill_span<char *>(buffer, _num_joints);

    // Parents, third biggest alignment.
    joint_parents_ = fill_span<int16_t>(buffer, _num_joints);

    // Remaning buffer will be used to store joint names.
    assert(buffer.size_bytes() == _chars_size &&
            "Whole buffer should be consumned");
    return buffer.data();
}

- (void)Load:(IArchive &)_archive :(uint32_t)_version {
    // Deallocate skeleton in case it was already used before.
    [self Deallocate];

    if (_version != 2) {
        std::cerr << "Unsupported Skeleton version " << _version << "." << std::endl;
        return;
    }

    int32_t num_joints;
    _archive >> num_joints;

    // Early out if skeleton's empty.
    if (!num_joints) {
        return;
    }

    // Read names.
    int32_t chars_count;
    _archive >> chars_count;

    // Allocates all skeleton data members.
    char *cursor = [self Allocate:chars_count :num_joints];

    // Reads name's buffer, they are all contiguous in the same buffer.
    _archive >> MakeArray(cursor, chars_count);

    // Fixes up array of pointers. Stops at num_joints - 1, so that it doesn't
    // read memory past the end of the buffer.
    for (int i = 0; i < num_joints - 1; ++i) {
        joint_names_[i] = cursor;
        cursor += std::strlen(joint_names_[i]) + 1;
    }
    // num_joints is > 0, as this was tested at the beginning of the function.
    joint_names_[num_joints - 1] = cursor;

    _archive >> MakeArray(joint_parents_);
    _archive >> MakeArray(joint_bind_poses_);
}

- (bool)LoadSkeleton:(const NSString *)_filename {
    assert(_filename);
    const char *name = [_filename cStringUsingEncoding:NSUTF8StringEncoding];
    std::cout << "Loading skeleton archive " << name << "." << std::endl;
    File file(name, "rb");
    if (!file.opened()) {
        std::cerr << "Failed to open skeleton file " << name << "." << std::endl;
        return false;
    }
    IArchive archive(&file);

    char buf[OZZ_ARRAY_SIZE("ozz-skeleton")];
    archive.LoadBinary(buf, OZZ_ARRAY_SIZE("ozz-skeleton"));

    uint32_t version;
    archive >> version;

    // Once the tag is validated, reading cannot fail.
    [self Load:archive :version];

    return true;
}

-(size_t) NumberOfNames {
    return joint_names_.size();
}

-(NSString *_Nonnull) NameWithIndex:(size_t)index {
    return [NSString stringWithUTF8String:joint_names_[index]];
}

-(size_t) NumberOfParents {
    return joint_parents_.size();
}

-(void) ParentWithIndex:(size_t)index :(size_t *_Nonnull) parent {
    *parent = joint_parents_[index];
}

-(size_t) NumberOfBindPose {
    return joint_bind_poses_.size();
}

-(void) PoseWithIndex:(size_t)index :(struct SoaTransform *_Nonnull) pose {
    *pose = joint_bind_poses_[index];
}

@end
