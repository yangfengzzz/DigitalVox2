//
//  CPxFixedJoint.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxFixedJoint.h"
#import "CPxJoint+Internal.h"

@implementation CPxFixedJoint

- (void)setProjectionLinearTolerance:(float)tolerance {
    static_cast<PxFixedJoint *>(super.c_joint)->setProjectionLinearTolerance(tolerance);
}

- (float)getProjectionLinearTolerance {
    return static_cast<PxFixedJoint *>(super.c_joint)->getProjectionLinearTolerance();
}

- (void)setProjectionAngularTolerance:(float)tolerance {
    static_cast<PxFixedJoint *>(super.c_joint)->setProjectionAngularTolerance(tolerance);
}

- (float)getProjectionAngularTolerance {
    return static_cast<PxFixedJoint *>(super.c_joint)->getProjectionAngularTolerance();
}

@end
