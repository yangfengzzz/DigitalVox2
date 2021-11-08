//
//  CPxDistanceJoint.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxDistanceJoint_h
#define CPxDistanceJoint_h

#import "CPxJoint.h"

enum CPxDistanceJointFlag {
    eMAX_DISTANCE_ENABLED = 1 << 1,
    eMIN_DISTANCE_ENABLED = 1 << 2,
    eSPRING_ENABLED = 1 << 3
};

@interface CPxDistanceJoint : CPxJoint

- (float)getDistance;

- (void)setMinDistance:(float)distance;

- (float)getMinDistance;

- (void)setMaxDistance:(float)distance;

- (float)getMaxDistance;

- (void)setTolerance:(float)tolerance;

- (float)getTolerance;

- (void)setStiffness:(float)stiffness;

- (float)getStiffness;

- (void)setDamping:(float)damping;

- (float)getDamping;

- (void)setDistanceJointFlag:(CPxDistanceJointFlag)flag :(bool)value;

@end

#endif /* CPxDistanceJoint_h */
