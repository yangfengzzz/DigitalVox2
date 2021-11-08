//
//  CPxPrismaticJoint.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxPrismaticJoint_h
#define CPxPrismaticJoint_h

#import "CPxJoint.h"
#import "CPxJointLinearLimitPair.h"

enum CPxPrismaticJointFlag {
    eLIMIT_ENABLED = 1 << 1
};

@interface CPxPrismaticJoint : CPxJoint

- (float)getPosition;

- (float)getVelocity;

- (void)setLimit:(CPxJointLinearLimitPair *)limit;

- (CPxJointLinearLimitPair *)getLimit;

- (void)setPrismaticJointFlag:(CPxPrismaticJointFlag)flag :(bool)value;

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

- (void)setProjectionAngularTolerance:(float)tolerance;

- (float)getProjectionAngularTolerance;

@end

#endif /* CPxPrismaticJoint_h */
