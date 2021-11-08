//
//  CPxFixedJoint.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxFixedJoint_h
#define CPxFixedJoint_h

#import "CPxJoint.h"

@interface CPxFixedJoint : CPxJoint

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

- (void)setProjectionAngularTolerance:(float)tolerance;

- (float)getProjectionAngularTolerance;

@end

#endif /* CPxFixedJoint_h */
