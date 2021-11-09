//
//  CPxCapsuleController.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

#import "CPxCapsuleController.h"
#import "CPxController+Internal.h"

@implementation CPxCapsuleController

- (float)getRadius {
    return static_cast<PxCapsuleController *>(super.c_controller)->getRadius();
}

- (bool)setRadius:(float)radius {
    return static_cast<PxCapsuleController *>(super.c_controller)->setRadius(radius);
}

- (float)getHeight {
    return static_cast<PxCapsuleController *>(super.c_controller)->getHeight();
}

- (bool)setHeight:(float)height {
    return static_cast<PxCapsuleController *>(super.c_controller)->setHeight(height);
}

- (enum CPxCapsuleClimbingMode)getClimbingMode {
    return CPxCapsuleClimbingMode(static_cast<PxCapsuleController *>(super.c_controller)->getClimbingMode());
}

- (bool)setClimbingMode:(CPxCapsuleClimbingMode)mode {
    return static_cast<PxCapsuleController *>(super.c_controller)->setClimbingMode(PxCapsuleClimbingMode::Enum(mode));
}

@end
