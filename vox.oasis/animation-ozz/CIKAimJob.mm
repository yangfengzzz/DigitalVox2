//
//  CIKAimJob.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/2.
//

#import "CIKAimJob.h"
#import "ozz/animation/runtime/ik_aim_job.h"

@implementation CIKAimJob {
    ozz::animation::IKAimJob job;
}

- (bool)Run {
    return job.Run();
}

@end
